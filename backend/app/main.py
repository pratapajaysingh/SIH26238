import logging
import os
from pathlib import Path
import sys
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request, Response, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import text

from app.core.config import get_cors_origins
from app.core.database import engine
from app.api.auth import router as auth_router
from app.api.student import router as student_router
from app.api.user import router as user_router
from app.api.scholarship import router as scholarship_router
from app.api.application import router as application_router
from app.api.document import router as document_router
from app.api.eligibility import router as eligibility_router
from app.api.verification import router as verification_router
from app.api.manual_review import router as manual_review_router
from app.api.digilocker import router as digilocker_router
from app.api.jago import router as jago_router
from app.api.notification import router as notification_router
from app.api.analytics import router as analytics_router

logger = logging.getLogger("tribalsetu")


def init_db_schema(force: bool = False) -> None:
    """Ensure database schema is up-to-date and seed data is present on startup."""
    # Skip during automated test execution unless forced
    if not force and ("pytest" in sys.modules or os.getenv("TESTING") == "1"):
        logger.info("Skipping auto-migration and seed (AUTO_INIT_DB is not 1)")
        return

    app_dir = Path(__file__).resolve().parent.parent
    if str(app_dir) not in sys.path:
        sys.path.insert(0, str(app_dir))

    # 1. Run migrations / create tables
    try:
        from alembic.config import Config
        from alembic import command

        ini_candidates = [
            app_dir / "alembic.ini",
            Path.cwd() / "alembic.ini",
            Path.cwd() / "backend" / "alembic.ini",
        ]
        alembic_run = False
        for ini_path in ini_candidates:
            if ini_path.is_file():
                alembic_cfg = Config(str(ini_path))
                alembic_cfg.set_main_option("script_location", str(ini_path.parent / "alembic"))
                command.upgrade(alembic_cfg, "head")
                logger.info(f"Database migrations applied successfully via {ini_path}")
                alembic_run = True
                break

        if not alembic_run:
            from app.core.database import Base
            import app.models  # noqa: F401
            Base.metadata.create_all(bind=engine)
            logger.info("Database tables created via Base.metadata.create_all")
    except Exception as exc:
        logger.warning(f"Alembic auto-migration notice: {exc}; ensuring tables with create_all fallback")
        try:
            from app.core.database import Base
            import app.models  # noqa: F401
            Base.metadata.create_all(bind=engine)
            logger.info("Database tables ensured via Base.metadata.create_all fallback")
        except Exception as e2:
            logger.error(f"Schema creation error: {e2}")

    # 2. Seed database idempotently (creates demo users, scholarships, apps if missing)
    try:
        from app.core.database import SessionLocal
        from app.seed import seed_database

        db = SessionLocal()
        try:
            results = seed_database(db, reset=False)
            logger.info(f"Database seeded successfully: {results}")
        finally:
            db.close()
    except Exception as exc:
        logger.error(f"Database auto-seed notice: {exc}")


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup tasks
    pass
    yield
    # Shutdown tasks


app = FastAPI(title="TribalSetu API", lifespan=lifespan)

from app.core.config import assert_production_config

@app.on_event("startup")
def _validate_config() -> None:
    assert_production_config()

# Safe CORS configuration for development
app.add_middleware(
    CORSMiddleware,
    allow_origins=get_cors_origins(),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled error on {request.method} {request.url.path}: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error", "message": str(exc)},
    )


# Core API routes
from app.api import auth_otp
app.include_router(auth_otp.router)
app.include_router(auth_router, prefix="/api/v1")
app.include_router(student_router, prefix="/api/v1")
app.include_router(user_router, prefix="/api/v1")
app.include_router(scholarship_router, prefix="/api/v1")
app.include_router(application_router, prefix="/api/v1")
app.include_router(document_router, prefix="/api/v1")
app.include_router(eligibility_router, prefix="/api/v1")
app.include_router(verification_router, prefix="/api/v1")
app.include_router(manual_review_router, prefix="/api/v1")
app.include_router(digilocker_router, prefix="/api/v1")
app.include_router(jago_router, prefix="/api/v1")
app.include_router(notification_router, prefix="/api/v1")
app.include_router(analytics_router, prefix="/api/v1")



@app.get("/")
def root():
    return {
        "status": "ok",
        "message": "TribalSetu API is running",
    }


@app.get("/health")
def health():
    return {
        "status": "ok",
    }


@app.get("/health/db")
def health_db(response: Response):
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
            return {
                "status": "ok",
                "database": "connected",
            }
    except Exception:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        return {
            "status": "error",
            "database": "disconnected",
        }


# Retained for backward compatibility
@app.get("/db-test")
def db_test(response: Response):
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
            return {"status": "ok", "database": "connected"}
    except Exception:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        return {"status": "error", "database": "disconnected"}


@app.get("/api/v1/health")
def api_v1_health():
    return {"status": "ok"}


@app.get("/api/v1/health/tables")
def health_tables():
    from sqlalchemy import inspect
    inspector = inspect(engine)
    tables = inspector.get_table_names()
    return {
        "status": "ok",
        "tables_count": len(tables),
        "tables": tables,
    }


@app.get("/api/v1/health/jago")
def health_jago():
    from app.services.jago_llm_service import JagoLLMService, GENAI_AVAILABLE
    llm = JagoLLMService()
    return {
        "status": "ok",
        "llm_configured": llm.is_configured(),
        "genai_available": GENAI_AVAILABLE,
        "model": llm.model_name,
    }


@app.post("/api/v1/admin/init-db")
def admin_init_db():
    try:
        init_db_schema(force=True)
        from sqlalchemy import inspect
        inspector = inspect(engine)
        tables = inspector.get_table_names()
        return {
            "status": "ok",
            "message": "Database schema and seed initialized successfully",
            "tables_count": len(tables),
            "tables": tables,
        }
    except Exception as exc:
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": str(exc)},
        )


if __name__ == "__main__":
    import uvicorn
    from app.core.config import HOST, PORT

    uvicorn.run("app.main:app", host=HOST, port=PORT, reload=False)

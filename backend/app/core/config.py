import os
from pathlib import Path


def load_env_file() -> None:
    """Load key-value pairs from .env file into os.environ if not already set."""
    search_paths = [
        Path.cwd() / ".env",
        Path(__file__).resolve().parent.parent.parent / ".env",
        Path(__file__).resolve().parent.parent.parent.parent / ".env",
    ]
    for env_path in search_paths:
        if env_path.is_file():
            try:
                with open(env_path, "r", encoding="utf-8") as f:
                    for line in f:
                        line = line.strip()
                        if not line or line.startswith("#") or "=" not in line:
                            continue
                        key, val = line.split("=", 1)
                        key = key.strip()
                        val = val.strip().strip("'\"")
                        if key and key not in os.environ:
                            os.environ[key] = val
                break
            except Exception:
                pass


# Initialize environment on import
load_env_file()

HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8000"))

DEFAULT_DATABASE_URL = "postgresql+psycopg2://postgres:postgres@localhost:5432/tribalsetu"


def normalize_database_url(url: str) -> str:
    """Normalize database connection URL to ensure compatibility with SQLAlchemy."""
    if not url:
        return DEFAULT_DATABASE_URL
    if url.startswith("postgres://"):
        return url.replace("postgres://", "postgresql://", 1)
    return url


DATABASE_URL = normalize_database_url(os.getenv("DATABASE_URL", DEFAULT_DATABASE_URL))

DEFAULT_CORS_ORIGINS = [
    "http://localhost",
    "http://localhost:3000",
    "http://localhost:5000",
    "http://localhost:8000",
    "http://localhost:8080",
    "http://127.0.0.1",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:5000",
    "http://127.0.0.1:8000",
    "http://127.0.0.1:8080",
]


def get_cors_origins() -> list[str]:
    raw_origins = os.getenv("CORS_ORIGINS", "")
    if raw_origins.strip():
        if raw_origins.strip() == "*":
            return ["*"]
        parsed = [origin.strip() for origin in raw_origins.split(",") if origin.strip()]
        if parsed:
            return parsed
    return DEFAULT_CORS_ORIGINS


# JWT Authentication Configuration
JWT_SECRET = os.getenv("JWT_SECRET", "")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60"))

# Gemini LLM Configuration
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")

ENVIRONMENT = os.getenv("ENVIRONMENT", "development")  # development|test|production

# ---- OTP engine --------------------------------------------------------------
OTP_TTL_SECONDS = int(os.getenv("OTP_TTL_SECONDS", "300"))
OTP_MAX_ATTEMPTS = int(os.getenv("OTP_MAX_ATTEMPTS", "5"))
OTP_HMAC_SECRET = os.getenv("OTP_HMAC_SECRET", "")
OTP_DELIVERY_CHANNEL = os.getenv("OTP_DELIVERY_CHANNEL", "console")  # console|email|sms
REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", "7"))

# ---- Email delivery (Resend free tier, no card required) ---------------------
RESEND_API_KEY = os.getenv("RESEND_API_KEY", "")
OTP_EMAIL_SENDER = os.getenv("OTP_EMAIL_SENDER", "TribalSetu <onboarding@resend.dev>")


def assert_production_config() -> None:
    """Fail fast on an unsafe production deploy. Call from main.py startup."""
    if ENVIRONMENT != "production":
        return
    problems = []
    if not JWT_SECRET or len(JWT_SECRET) < 32:
        problems.append("JWT_SECRET must be set to at least 32 random characters")
    if not OTP_HMAC_SECRET or len(OTP_HMAC_SECRET) < 32:
        problems.append("OTP_HMAC_SECRET must be set to at least 32 random characters")
    if OTP_DELIVERY_CHANNEL == "console":
        problems.append("OTP_DELIVERY_CHANNEL=console leaks codes to the server log")
    if problems:
        raise RuntimeError("Unsafe production configuration: " + "; ".join(problems))



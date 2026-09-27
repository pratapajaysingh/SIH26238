from sqlalchemy.orm import Session
from app.models.application_timeline import ApplicationTimeline


def create_timeline_entry(
    db: Session,
    entry: ApplicationTimeline,
) -> ApplicationTimeline:
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return entry


def get_timeline_by_application_id(
    db: Session,
    application_id: str,
) -> list[ApplicationTimeline]:
    return (
        db.query(ApplicationTimeline)
        .filter(ApplicationTimeline.application_id == application_id)
        .order_by(ApplicationTimeline.created_at.asc())
        .all()
    )

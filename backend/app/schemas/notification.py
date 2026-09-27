from datetime import datetime
from pydantic import BaseModel, Field, model_validator


class NotificationCreate(BaseModel):
    student_id: str
    application_id: str | None = None
    title: str
    message: str
    category: str = Field(
        default="APPLICATION_UPDATE",
        description="APPLICATION_UPDATE, DEFICIENCY, VERIFICATION, PAYMENT",
    )


class NotificationResponse(BaseModel):
    id: str
    student_id: str
    application_id: str | None = None
    title: str
    message: str
    category: str
    notification_type: str = ""
    is_read: bool
    created_at: datetime | str

    class Config:
        from_attributes = True

    @model_validator(mode="after")
    def sync_notification_type(self):
        if not self.notification_type:
            self.notification_type = self.category
        return self

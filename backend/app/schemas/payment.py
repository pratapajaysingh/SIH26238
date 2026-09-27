from pydantic import BaseModel


class PaymentStatusResponse(BaseModel):
    application_id: str
    status: str
    message: str
    disbursement_mode: str
    payment_reference: str | None = None
    evaluation_mode: str = "MOCK"

    class Config:
        from_attributes = True

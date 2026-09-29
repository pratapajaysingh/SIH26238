from pydantic import BaseModel


class PaymentStatusResponse(BaseModel):
    application_id: str
    status: str
    message: str
    disbursement_mode: str
    payment_reference: str | None = None
    amount: str | None = None
    transaction_id: str | None = None
    initiated_date: str | None = None
    processed_date: str | None = None
    credited_date: str | None = None
    failure_reason: str | None = None
    evaluation_mode: str = "MOCK"

    class Config:
        from_attributes = True


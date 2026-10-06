from pydantic import BaseModel


class UserResponse(BaseModel):
    id: str
    name: str
    email: str
    role: str = "STUDENT"

    class Config:
        from_attributes = True
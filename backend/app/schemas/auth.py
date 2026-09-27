from pydantic import BaseModel, Field


class AuthLoginRequest(BaseModel):
    username: str | None = None
    email: str | None = None
    password: str = Field(..., min_length=1)

    @property
    def identifier(self) -> str | None:
        return self.email or self.username


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

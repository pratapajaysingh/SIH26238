from sqlalchemy.orm import Session

from app.core.security import create_access_token, verify_password
from app.models.user import User
from app.schemas.auth import AuthLoginRequest, TokenResponse


def authenticate_user(db: Session, login_data: AuthLoginRequest) -> TokenResponse | None:
    """Authenticate user credentials and return a signed JWT token response."""
    identifier = login_data.identifier
    if not identifier:
        return None

    # Match by email or username/name
    user = (
        db.query(User)
        .filter((User.email == identifier) | (User.name == identifier))
        .first()
    )

    if user is None:
        return None

    if not verify_password(login_data.password, user.password):
        return None

    access_token = create_access_token(
        data={"sub": user.id, "email": user.email}
    )

    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
    )

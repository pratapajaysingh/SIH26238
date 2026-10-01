"""add otp_tokens

Revision ID: 9a12ea8962c3
Revises: 8e93ea8962c2
Create Date: 2026-10-01 14:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '9a12ea8962c3'
down_revision: Union[str, Sequence[str], None] = '8e93ea8962c2'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        'otp_tokens',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('identifier', sa.String(length=255), nullable=False),
        sa.Column('purpose', sa.String(length=32), nullable=False, server_default='login'),
        sa.Column('otp_hash', sa.String(length=64), nullable=False),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('consumed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('attempt_count', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('request_ip', sa.String(length=64), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_otp_identifier_created', 'otp_tokens', ['identifier', 'created_at'], unique=False)
    op.create_index('ix_otp_ip_created', 'otp_tokens', ['request_ip', 'created_at'], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index('ix_otp_ip_created', table_name='otp_tokens')
    op.drop_index('ix_otp_identifier_created', table_name='otp_tokens')
    op.drop_table('otp_tokens')

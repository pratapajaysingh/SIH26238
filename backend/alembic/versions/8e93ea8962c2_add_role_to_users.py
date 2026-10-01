"""add role to users

Revision ID: 8e93ea8962c2
Revises: 7d92da7951b1
Create Date: 2026-09-30 23:50:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '8e93ea8962c2'
down_revision: Union[str, Sequence[str], None] = '7d92da7951b1'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.add_column('users', sa.Column('role', sa.String(), nullable=False, server_default='STUDENT'))


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column('users', 'role')

"""create application_timeline table

Revision ID: 6c92da7951a0
Revises: 5b83ca6940a9
Create Date: 2026-09-28 00:50:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '6c92da7951a0'
down_revision: Union[str, Sequence[str], None] = '5b83ca6940a9'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        'application_timeline',
        sa.Column('id', sa.String(), nullable=False),
        sa.Column('application_id', sa.String(), nullable=False),
        sa.Column('status', sa.String(), nullable=False),
        sa.Column('message', sa.String(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(['application_id'], ['applications.id']),
        sa.PrimaryKeyConstraint('id')
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_table('application_timeline')

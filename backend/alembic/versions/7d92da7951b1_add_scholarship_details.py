"""add scholarship details
 
Revision ID: 7d92da7951b1
Revises: 6c92da7951a0
Create Date: 2026-09-29 19:15:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '7d92da7951b1'
down_revision: Union[str, Sequence[str], None] = '6c92da7951a0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.add_column('scholarships', sa.Column('description', sa.String(), nullable=True))
    op.add_column('scholarships', sa.Column('ministry', sa.String(), nullable=True))
    op.add_column('scholarships', sa.Column('benefit_amount', sa.String(), nullable=True))
    op.add_column('scholarships', sa.Column('education_level', sa.String(), nullable=True))


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column('scholarships', 'education_level')
    op.drop_column('scholarships', 'benefit_amount')
    op.drop_column('scholarships', 'ministry')
    op.drop_column('scholarships', 'description')

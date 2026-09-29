"""Local Manual Verification Script for JAGO 10 Test Queries.

Tests all 10 required prompt scenarios using isolated test database:
1. "Hi JAGO"
2. "mera application status kya hai?"
3. "mere documents me kya missing hai?"
4. "my payment status?"
5. "main NFST ke liye eligible hoon?"
6. "bhai mera application verified hai but paisa kyu nahi aaya?"
7. "मेरी स्कॉलरशिप का स्टेटस क्या है?"
8. "what documents do I need for NFST?"
9. Follow-up: "when was it last updated?" after asking application status
10. Unrelated: "How are you?"
"""

import sys
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.database import Base
from app.core.dependencies import get_db
from app.main import app as fastapi_app
import app.models
from app.seed import seed_database

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")


def main():
    test_engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    TestingSession = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)
    Base.metadata.create_all(bind=test_engine)

    session = TestingSession()
    seed_database(session, reset=False)

    def override_get_db():
        try:
            yield session
        finally:
            pass

    fastapi_app.dependency_overrides[get_db] = override_get_db
    client = TestClient(fastapi_app)
    conv_id = "manual-verification-conv-101"

    test_queries = [
        ("1. Greeting", "Hi JAGO"),
        ("2. Hinglish Application Status", "mera application status kya hai?"),
        ("3. Hinglish Missing Documents", "mere documents me kya missing hai?"),
        ("4. Payment Status Query", "my payment status?"),
        ("5. Hinglish Eligibility Query", "main NFST ke liye eligible hoon?"),
        ("6. Multi-intent / In-depth", "bhai mera application verified hai but paisa kyu nahi aaya?"),
        ("7. Hindi (Devanagari) Status", "मेरी स्कॉलरशिप का स्टेटस क्या है?"),
        ("8. Scheme Documents Guidance", "what documents do I need for NFST?"),
        ("9. Follow-up Question", "when was it last updated?"),
        ("10. Unrelated Question", "How are you?"),
    ]

    print("=" * 70)
    print("RUNNING JAGO 10 TEST QUERIES")
    print("=" * 70)

    for label, query in test_queries:
        resp = client.post(
            f"/api/v1/jago/conversations/{conv_id}/messages",
            json={"message": query},
        )
        assert resp.status_code == 200, f"Failed on {label}: {resp.status_code}"
        data = resp.json()
        print(f"\n[{label}]")
        print(f"USER:    {query}")
        print(f"INTENT:  {data.get('intent')}")
        print(f"SOURCE:  {data.get('source')}")
        print(f"LANG:    {data.get('language')}")
        print(f"JAGO:    {data.get('message')}")
        if data.get("data"):
            print(f"DATA:    {str(data.get('data'))[:120]}...")

    print("\n" + "=" * 70)
    print("ALL 10 MANUAL VERIFICATION QUERIES COMPLETED SUCCESSFULLY!")
    print("=" * 70)


if __name__ == "__main__":
    main()

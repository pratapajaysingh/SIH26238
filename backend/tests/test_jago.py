from unittest.mock import patch
from app.seed import DEMO_APPLICATION_ID, DEMO_STUDENT_ID, DEMO_SCHOLARSHIPS


def test_jago_status_intent_success(client, seeded_db):
    conv_id = "test-conv-1"
    response = client.post(
        f"/api/v1/jago/conversations/{conv_id}/messages",
        json={"message": f"What is the status of application {DEMO_APPLICATION_ID}?"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["conversation_id"] == conv_id
    assert data["intent"] == "APPLICATION_STATUS"
    assert "DRAFT" in data["message"]
    assert data["data"]["id"] == DEMO_APPLICATION_ID
    assert data["data"]["status"] == "DRAFT"
    assert data["source"] == "application_service.get_application_status"


def test_jago_status_intent_missing_application_id(client, seeded_db):
    conv_id = "test-conv-2"
    response = client.post(
        f"/api/v1/jago/conversations/{conv_id}/messages",
        json={"message": "Please check my application status"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["intent"] == "APPLICATION_STATUS"
    assert "provide your Application ID" in data["message"]
    assert data["data"]["error"] == "APPLICATION_ID_REQUIRED"


def test_jago_status_intent_nonexistent_application(client, seeded_db):
    conv_id = "test-conv-3"
    fake_id = "ffffffff-ffff-ffff-ffff-ffffffffffff"
    response = client.post(
        f"/api/v1/jago/conversations/{conv_id}/messages",
        json={"message": f"Check status for {fake_id}"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["intent"] == "APPLICATION_STATUS"
    assert "No application found" in data["message"]
    assert data["data"]["found"] is False


def test_jago_deficiencies_intent_success(client, seeded_db):
    conv_id = "test-conv-4"
    response = client.post(
        f"/api/v1/jago/conversations/{conv_id}/messages",
        json={"message": f"Are there any deficiencies in my application {DEMO_APPLICATION_ID}?"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["conversation_id"] == conv_id
    assert data["intent"] == "APPLICATION_DEFICIENCIES"
    assert data["data"]["application_id"] == DEMO_APPLICATION_ID
    assert isinstance(data["data"]["deficiencies"], list)
    assert data["source"] == "application_service.get_application_deficiencies"


def test_jago_deficiencies_intent_missing_application_id(client, seeded_db):
    conv_id = "test-conv-5"
    response = client.post(
        f"/api/v1/jago/conversations/{conv_id}/messages",
        json={"message": "What documents are missing?"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["intent"] == "APPLICATION_DEFICIENCIES"
    assert "provide your Application ID" in data["message"]
    assert data["data"]["error"] == "APPLICATION_ID_REQUIRED"


def test_jago_deficiencies_intent_nonexistent_application(client, seeded_db):
    conv_id = "test-conv-6"
    fake_id = "ffffffff-ffff-ffff-ffff-ffffffffffff"
    response = client.post(
        f"/api/v1/jago/conversations/{conv_id}/messages",
        json={"message": f"What are the deficiencies for {fake_id}?"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["intent"] == "APPLICATION_DEFICIENCIES"
    assert "No application found" in data["message"]
    assert data["data"]["found"] is False


def test_jago_eligibility_intent_success(client, seeded_db):
    conv_id = "test-conv-7"
    response = client.post(
        f"/api/v1/jago/conversations/{conv_id}/messages",
        json={"message": "Am I eligible for this scholarship?"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["conversation_id"] == conv_id
    assert data["intent"] == "ELIGIBILITY"
    assert data["data"]["eligible"] is True
    assert data["data"]["evaluation_mode"] == "MOCK"
    assert data["source"] == "eligibility_service.check_eligibility"


def test_jago_unknown_intent(client, seeded_db):
    conv_id = "test-conv-8"
    response = client.post(
        f"/api/v1/jago/conversations/{conv_id}/messages",
        json={"message": "What is the weather in Delhi today?"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["conversation_id"] == conv_id
    assert data["intent"] == "UNKNOWN"
    assert "could not determine" in data["message"].lower()
    assert len(data["suggestions"]) >= 3
    assert "Check my application status" in data["suggestions"]


def test_jago_uses_approved_services_not_direct_db(client, seeded_db):
    conv_id = "test-conv-9"

    # Verify status intent delegates to get_application_status
    with patch("app.services.jago_service.get_application_status") as mock_status:
        mock_status.return_value = {"id": DEMO_APPLICATION_ID, "status": "DRAFT"}
        response = client.post(
            f"/api/v1/jago/conversations/{conv_id}/messages",
            json={"message": f"Check status of {DEMO_APPLICATION_ID}"},
        )
        assert response.status_code == 200
        mock_status.assert_called_once()

    # Verify deficiencies intent delegates to get_application_deficiencies
    with patch("app.services.jago_service.get_application_deficiencies") as mock_def:
        mock_def.return_value = []
        response = client.post(
            f"/api/v1/jago/conversations/{conv_id}/messages",
            json={"message": f"Check deficiencies for {DEMO_APPLICATION_ID}"},
        )
        assert response.status_code == 200
        mock_def.assert_called_once()

    # Verify eligibility intent delegates to check_eligibility
    with patch("app.services.jago_service.check_eligibility") as mock_elig:
        from app.schemas.eligibility import EligibilityCheckResponse
        mock_elig.return_value = EligibilityCheckResponse(
            student_id=DEMO_STUDENT_ID,
            scholarship_id=DEMO_SCHOLARSHIPS[0]["id"],
            eligible=True,
            reasons=["Mock test reason"],
            evaluation_mode="MOCK",
        )
        response = client.post(
            f"/api/v1/jago/conversations/{conv_id}/messages",
            json={"message": "Am I eligible?"},
        )
        assert response.status_code == 200
        mock_elig.assert_called_once()

    # Verify payment intent delegates to get_payment_status
    with patch("app.services.jago_service.get_payment_status") as mock_pay:
        mock_pay.return_value = {
            "application_id": DEMO_APPLICATION_ID,
            "status": "NOT_INITIATED",
            "message": "Payment has not been initiated.",
            "disbursement_mode": "MOCK_DBT",
            "payment_reference": None,
            "evaluation_mode": "MOCK",
        }
        response = client.post(
            f"/api/v1/jago/conversations/{conv_id}/messages",
            json={"message": f"What is my payment status for {DEMO_APPLICATION_ID}?"},
        )
        assert response.status_code == 200
        mock_pay.assert_called_once()


def test_jago_payment_intent_success(client, seeded_db):
    conv_id = "test-conv-10"
    response = client.post(
        f"/api/v1/jago/conversations/{conv_id}/messages",
        json={"message": f"What is my payment status for application {DEMO_APPLICATION_ID}?"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["conversation_id"] == conv_id
    assert data["intent"] == "PAYMENT_STATUS"
    assert data["data"]["application_id"] == DEMO_APPLICATION_ID
    assert data["data"]["status"] == "NOT_INITIATED"
    assert data["data"]["disbursement_mode"] == "MOCK_DBT"
    assert data["source"] == "payment_service.get_payment_status"


def test_jago_payment_intent_missing_application_id(client, seeded_db):
    conv_id = "test-conv-11"
    response = client.post(
        f"/api/v1/jago/conversations/{conv_id}/messages",
        json={"message": "Has my scholarship amount been disbursed?"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["intent"] == "PAYMENT_STATUS"
    assert "provide your Application ID" in data["message"]
    assert data["data"]["error"] == "APPLICATION_ID_REQUIRED"


def test_jago_payment_intent_nonexistent_application(client, seeded_db):
    conv_id = "test-conv-12"
    fake_id = "ffffffff-ffff-ffff-ffff-ffffffffffff"
    response = client.post(
        f"/api/v1/jago/conversations/{conv_id}/messages",
        json={"message": f"What happened to my scholarship payment for {fake_id}?"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["intent"] == "PAYMENT_STATUS"
    assert "No application found" in data["message"]
    assert data["data"]["found"] is False


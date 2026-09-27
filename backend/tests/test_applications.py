from app.seed import DEMO_STUDENT_ID, DEMO_SCHOLARSHIPS, DEMO_DOCUMENTS, DEMO_APPLICATION_ID


def test_list_applications_seeded(client, seeded_db):
    response = client.get("/api/v1/applications")
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 1
    assert data[0]["status"] in ["DRAFT", "SUBMITTED", "IN_VERIFICATION"]


def test_create_application_success(client, seeded_db):
    response = client.post(
        "/api/v1/applications",
        json={
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": DEMO_SCHOLARSHIPS[1]["id"],
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "id" in data
    assert data["student_id"] == DEMO_STUDENT_ID
    assert data["scholarship_id"] == DEMO_SCHOLARSHIPS[1]["id"]
    assert data["status"] == "DRAFT"


def test_create_application_student_not_found(client, seeded_db):
    response = client.post(
        "/api/v1/applications",
        json={
            "student_id": "non-existent-student",
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    assert response.status_code == 404
    assert response.json()["detail"] == "Student not found"


def test_create_application_scholarship_not_found(client, seeded_db):
    response = client.post(
        "/api/v1/applications",
        json={
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": "non-existent-scholarship",
        },
    )
    assert response.status_code == 404
    assert response.json()["detail"] == "Scholarship not found"


def test_link_document_to_application_and_list(client, seeded_db):
    # Create fresh application
    app_res = client.post(
        "/api/v1/applications",
        json={
            "student_id": DEMO_STUDENT_ID,
            "scholarship_id": DEMO_SCHOLARSHIPS[0]["id"],
        },
    )
    app_id = app_res.json()["id"]

    # Link existing document
    doc_id = DEMO_DOCUMENTS[0]["id"]
    link_res = client.post(
        f"/api/v1/applications/{app_id}/documents",
        json={"document_id": doc_id},
    )
    assert link_res.status_code == 200
    assert link_res.json() == {"application_id": app_id, "document_id": doc_id}

    # Attempt duplicate link
    dup_res = client.post(
        f"/api/v1/applications/{app_id}/documents",
        json={"document_id": doc_id},
    )
    assert dup_res.status_code == 409
    assert dup_res.json()["detail"] == "Document already linked to application"

    # List linked documents
    list_res = client.get(f"/api/v1/applications/{app_id}/documents")
    assert list_res.status_code == 200
    docs = list_res.json()
    assert len(docs) == 1
    assert docs[0]["id"] == doc_id


def test_get_application_status_success(client, seeded_db):
    list_res = client.get("/api/v1/applications")
    assert list_res.status_code == 200
    apps = list_res.json()
    assert len(apps) >= 1
    existing_app = apps[0]

    response = client.get(f"/api/v1/applications/{existing_app['id']}/status")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == existing_app["id"]
    assert data["status"] == existing_app["status"]


def test_get_application_status_not_found(client, seeded_db):
    response = client.get("/api/v1/applications/non-existent-app-id/status")
    assert response.status_code == 404
    assert response.json()["detail"] == "Application not found"


def test_get_application_deficiencies_empty(client, seeded_db):
    # Seeded application initially has only a PENDING verification, so no deficiencies
    response = client.get(f"/api/v1/applications/{DEMO_APPLICATION_ID}/deficiencies")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert data == []


def test_get_application_deficiencies_with_issues(client, seeded_db):
    # Link DEMO_DOCUMENTS[2] (TEST_MISMATCH) to DEMO_APPLICATION_ID
    doc_id = DEMO_DOCUMENTS[2]["id"]
    link_res = client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/documents",
        json={"document_id": doc_id},
    )
    assert link_res.status_code == 200

    # Create verification record
    v_res = client.post(
        f"/api/v1/applications/{DEMO_APPLICATION_ID}/verifications",
        json={"document_id": doc_id},
    )
    assert v_res.status_code == 200
    verif_id = v_res.json()["id"]

    # Execute verification -> transitions to MISMATCH
    exec_res = client.post(f"/api/v1/verifications/{verif_id}/execute")
    assert exec_res.status_code == 200
    assert exec_res.json()["status"] == "MISMATCH"

    # Query deficiencies
    response = client.get(f"/api/v1/applications/{DEMO_APPLICATION_ID}/deficiencies")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1

    item = next((d for d in data if d["verification_id"] == verif_id), None)
    assert item is not None
    assert item["application_id"] == DEMO_APPLICATION_ID
    assert item["deficiency_type"] == "DOCUMENT_MISMATCH"
    assert item["type"] == "DOCUMENT_MISMATCH"
    assert item["category"] == "VERIFICATION"
    assert item["document_id"] == doc_id
    assert item["status"] == "MISMATCH"
    assert item["severity"] == "HIGH"
    assert "Income Certificate Demo" in item["message"]
    assert item["reason"] == item["message"]


def test_get_application_deficiencies_not_found(client, seeded_db):
    response = client.get("/api/v1/applications/non-existent-app-id/deficiencies")
    assert response.status_code == 404
    assert response.json()["detail"] == "Application not found"



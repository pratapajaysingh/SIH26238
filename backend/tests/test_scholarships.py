def test_list_scholarships_empty(client):
    response = client.get("/api/v1/scholarships")
    assert response.status_code == 200
    assert response.json() == []


def test_list_scholarships_seeded(client, seeded_db):
    response = client.get("/api/v1/scholarships")
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 5  # All 5 SIH schemes

    codes = [s["code"] for s in data]
    # Verify all 5 MoTA schemes are present
    assert "POST_MATRIC" in codes
    assert "PRE_MATRIC" in codes
    assert "NATIONAL_OVERSEAS" in codes
    assert "TOP_CLASS_EDUCATION" in codes
    assert "NATIONAL_FELLOWSHIP_ST" in codes

    # Verify response schema contract
    item = data[0]
    assert "id" in item
    assert "code" in item
    assert "name" in item
    # Note: 'eligible' is intentionally separated from catalogue contract per docs/api/scholarships.md
    assert "eligible" not in item

# TribalSetu Backend - Frontend Integration Contract

**Document Version:** 2.0.0  
**Target Client:** Flutter Mobile & Web Application  
**Base URL (Local Development):** `http://localhost:8000` (or `http://10.0.2.2:8000` for Android Emulator)  
**API Documentation (Swagger UI):** `http://localhost:8000/docs`  
**OpenAPI Specification:** `http://localhost:8000/openapi.json`  

---

## 1. Authentication Status & JWT Integration

> [!NOTE]  
> **Current Authentication Implementation Status:**  
> - **JWT Authentication:** Implemented using standard RFC 7519 HMAC-SHA256 (`HS256`) tokens.  
> - **Login:** Clients authenticate via `POST /api/v1/auth/login` and receive a standard Bearer access token: `{"access_token": "...", "token_type": "bearer"}`.  
> - **Bearer Token Usage:** Send the header `Authorization: Bearer <access_token>` on protected and context-aware endpoints.  
> - **Profile Access:** Use `GET /api/v1/auth/me`, `GET /api/v1/users/me`, or `GET /api/v1/students/me` to retrieve the active user and student profile.  
> - **Protected Endpoints:** Automatically identify the caller and return `401 Unauthorized` for missing, expired, or malformed tokens.  
> - **JAGO & Notifications Integration:** Authenticated requests automatically resolve student and application context without forcing the frontend to manually provide IDs.

---

## 2. Health & Infrastructure Endpoints

### 2.1 API Greeting / Root
- **METHOD:** `GET`
- **PATH:** `/`
- **REQUEST:** None
- **RESPONSE (`200 OK`):**
  ```json
  {
    "status": "ok",
    "message": "TribalSetu API is running"
  }
  ```

### 2.2 Liveness Health Check
- **METHOD:** `GET`
- **PATH:** `/health`
- **REQUEST:** None
- **RESPONSE (`200 OK`):**
  ```json
  {
    "status": "ok"
  }
  ```

### 2.3 Database Connectivity Health Check
- **METHOD:** `GET`
- **PATH:** `/health/db`
- **REQUEST:** None
- **RESPONSE (`200 OK` when connected):**
  ```json
  {
    "status": "ok",
    "database": "connected"
  }
  ```
- **RESPONSE (`503 Service Unavailable` when disconnected):**
  ```json
  {
    "status": "error",
    "database": "disconnected"
  }
  ```

---

## 3. Authentication & User APIs

### 3.1 Authenticate & Obtain Token (JWT Login)
- **METHOD:** `POST`
- **PATH:** `/api/v1/auth/login`
- **REQUEST:** Accepts `email` or `username` along with `password`:
  ```json
  {
    "email": "demo.student@example.com",
    "password": "DemoPassword123!"
  }
  ```
- **RESPONSE (`200 OK`):**
  ```json
  {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer"
  }
  ```
- **COMMON ERRORS:**
  - `401 Unauthorized`: `{"detail": "Invalid credentials"}`
  - `422 Unprocessable Entity`: Missing required fields.

### 3.2 Get Current User Profile
- **METHOD:** `GET`
- **PATH:** `/api/v1/auth/me` (or `/api/v1/users/me`)
- **HEADERS:** `Authorization: Bearer <token>`
- **RESPONSE (`200 OK`):**
  ```json
  {
    "id": "00000000-0000-0000-0000-000000000001",
    "name": "Demo Student User",
    "email": "demo.student@example.com"
  }
  ```
- **COMMON ERRORS:**
  - `401 Unauthorized`: `{"detail": "Missing Authorization header"}` / `{"detail": "Token has expired"}`

### 3.3 Register User
- **METHOD:** `POST`
- **PATH:** `/api/v1/users`
- **REQUEST:**
  ```json
  {
    "name": "Ravi Kumar",
    "email": "ravi.kumar@example.com",
    "password": "SecurePassword123!"
  }
  ```
- **RESPONSE (`200 OK`):**
  ```json
  {
    "id": "11111111-2222-3333-4444-555555555555",
    "name": "Ravi Kumar",
    "email": "ravi.kumar@example.com"
  }
  ```
- **COMMON ERRORS:**
  - `409 Conflict`: `{"detail": "Email already exists"}`
  - `422 Unprocessable Entity`: Invalid email format or missing fields.

### 3.4 Legacy User Login
- **METHOD:** `POST`
- **PATH:** `/api/v1/users/login`
- **REQUEST:**
  ```json
  {
    "email": "ravi.kumar@example.com",
    "password": "SecurePassword123!"
  }
  ```
- **RESPONSE (`200 OK`):**
  ```json
  {
    "id": "11111111-2222-3333-4444-555555555555",
    "name": "Ravi Kumar",
    "email": "ravi.kumar@example.com"
  }
  ```

---

## 4. Student Profile APIs

### 4.1 Get Authenticated Student Profile
- **METHOD:** `GET`
- **PATH:** `/api/v1/students/me`
- **HEADERS:** `Authorization: Bearer <token>`
- **RESPONSE (`200 OK`):**
  ```json
  {
    "id": "00000000-0000-0000-0000-000000000002",
    "user_id": "00000000-0000-0000-0000-000000000001",
    "name": "Demo Student User",
    "email": "demo.student@example.com"
  }
  ```
- **COMMON ERRORS:**
  - `401 Unauthorized`: Missing or invalid token.
  - `404 Not Found`: `{"detail": "Student profile not found for authenticated user"}`

### 4.2 Create Student Profile
- **METHOD:** `POST`
- **PATH:** `/api/v1/students`
- **REQUEST:**
  ```json
  {
    "user_id": "11111111-2222-3333-4444-555555555555",
    "name": "Ravi Kumar",
    "email": "ravi.kumar@example.com"
  }
  ```
- **RESPONSE (`200 OK`):**
  ```json
  {
    "id": "22222222-3333-4444-5555-666666666666",
    "user_id": "11111111-2222-3333-4444-555555555555",
    "name": "Ravi Kumar",
    "email": "ravi.kumar@example.com"
  }
  ```
- **COMMON ERRORS:**
  - `404 Not Found`: `{"detail": "User not found"}`
  - `409 Conflict`: `{"detail": "Student profile already exists for this user"}`
  - `409 Conflict`: `{"detail": "Email already registered for another student"}`

### 4.3 List Students
- **METHOD:** `GET`
- **PATH:** `/api/v1/students`
- **REQUEST:** None
- **RESPONSE (`200 OK`):**
  ```json
  [
    {
      "id": "22222222-3333-4444-5555-666666666666",
      "user_id": "11111111-2222-3333-4444-555555555555",
      "name": "Ravi Kumar",
      "email": "ravi.kumar@example.com"
    }
  ]
  ```

---

## 5. Scholarships Catalogue

### 5.1 List Schemes
- **METHOD:** `GET`
- **PATH:** `/api/v1/scholarships`
- **REQUEST:** None
- **RESPONSE (`200 OK`):**
  ```json
  [
    {
      "id": "00000000-0000-0000-0000-000000000010",
      "code": "POST_MATRIC",
      "name": "Post-Matric Scholarship"
    },
    {
      "id": "00000000-0000-0000-0000-000000000011",
      "code": "PRE_MATRIC",
      "name": "Pre-Matric Scholarship"
    }
  ]
  ```

---

## 6. Eligibility Evaluation

### 6.1 Check Scheme Eligibility
- **METHOD:** `POST`
- **PATH:** `/api/v1/eligibility/check`
- **REQUEST:**
  ```json
  {
    "student_id": "22222222-3333-4444-5555-666666666666",
    "scholarship_id": "00000000-0000-0000-0000-000000000010"
  }
  ```
- **RESPONSE (`200 OK`):**
  ```json
  {
    "student_id": "22222222-3333-4444-5555-666666666666",
    "scholarship_id": "00000000-0000-0000-0000-000000000010",
    "eligible": true,
    "reasons": [
      "Mock eligibility evaluation only; official scheme rules are not configured"
    ],
    "evaluation_mode": "MOCK"
  }
  ```
- **COMMON ERRORS:**
  - `404 Not Found`: `{"detail": "Student not found"}`
  - `404 Not Found`: `{"detail": "Scholarship not found"}`

---

## 7. Applications & Tracking APIs

### 7.1 Get My Applications (Authenticated)
- **METHOD:** `GET`
- **PATH:** `/api/v1/applications/me`
- **HEADERS:** `Authorization: Bearer <token>`
- **RESPONSE (`200 OK`):**
  ```json
  [
    {
      "id": "00000000-0000-0000-0000-000000000020",
      "student_id": "00000000-0000-0000-0000-000000000002",
      "scholarship_id": "00000000-0000-0000-0000-000000000010",
      "status": "DRAFT"
    }
  ]
  ```

### 7.2 Create Application
- **METHOD:** `POST`
- **PATH:** `/api/v1/applications`
- **REQUEST:**
  ```json
  {
    "student_id": "22222222-3333-4444-5555-666666666666",
    "scholarship_id": "00000000-0000-0000-0000-000000000010"
  }
  ```
- **RESPONSE (`200 OK`):**
  ```json
  {
    "id": "33333333-4444-5555-6666-777777777777",
    "student_id": "22222222-3333-4444-5555-666666666666",
    "scholarship_id": "00000000-0000-0000-0000-000000000010",
    "status": "DRAFT"
  }
  ```

### 7.3 Get Application Status
- **METHOD:** `GET`
- **PATH:** `/api/v1/applications/{application_id}/status`
- **RESPONSE (`200 OK`):**
  ```json
  {
    "id": "00000000-0000-0000-0000-000000000020",
    "status": "DRAFT"
  }
  ```
- **COMMON ERRORS:**
  - `404 Not Found`: `{"detail": "Application not found"}`

### 7.4 Get Application Deficiencies
- **METHOD:** `GET`
- **PATH:** `/api/v1/applications/{application_id}/deficiencies`
- **RESPONSE (`200 OK`):**
  ```json
  [
    {
      "id": "def-rec-00000000-0000-0000-0000-000000000040",
      "application_id": "00000000-0000-0000-0000-000000000020",
      "deficiency_type": "DOCUMENT_MISMATCH",
      "type": "DOCUMENT_MISMATCH",
      "category": "VERIFICATION",
      "document_id": "00000000-0000-0000-0000-000000000030",
      "document_name": "ST Certificate",
      "document_type": "MOCK_ST_CERTIFICATE",
      "verification_id": "00000000-0000-0000-0000-000000000040",
      "status": "MISMATCH",
      "severity": "HIGH",
      "message": "Document verification mismatch requires correction or review",
      "reason": "Document verification mismatch requires correction or review"
    }
  ]
  ```

### 7.5 Get Payment / DBT Status
- **METHOD:** `GET`
- **PATH:** `/api/v1/applications/{application_id}/payment-status`
- **RESPONSE (`200 OK`):**
  ```json
  {
    "application_id": "00000000-0000-0000-0000-000000000020",
    "status": "PENDING_VERIFICATION",
    "message": "Application is pending document verification before sanction",
    "disbursement_mode": "MOCK_DBT",
    "payment_reference": null,
    "evaluation_mode": "MOCK"
  }

  ```
- **NOTE ON PAYMENT:** Uses synthetic DBT status derivation based on scholarship application lifecycle state (`DRAFT`, `SUBMITTED`, `VERIFIED`, `APPROVED`, `DISBURSED`, `DEFICIENCY`). No real banking or payment gateways are touched in prototype mode.

---

## 8. Notifications APIs

### 8.1 Get Current Student Notifications (Authenticated)
- **METHOD:** `GET`
- **PATH:** `/api/v1/notifications/me` (or `/api/v1/notifications` with Bearer token)
- **HEADERS:** `Authorization: Bearer <token>`
- **QUERY PARAMS:** `unread_only` (boolean, optional, default: `false`)
- **RESPONSE (`200 OK`):**
  ```json
  [
    {
      "id": "00000000-0000-0000-0000-000000000050",
      "student_id": "00000000-0000-0000-0000-000000000002",
      "application_id": "00000000-0000-0000-0000-000000000020",
      "title": "Application Initialized",
      "message": "Your scholarship application for Post-Matric Scholarship has been created as a draft.",
      "category": "APPLICATION_UPDATE",
      "notification_type": "APPLICATION_UPDATE",
      "is_read": true,
      "created_at": "2026-09-27T18:00:00"
    }
  ]
  ```

### 8.2 Mark Notification as Read
- **METHOD:** `PATCH` (or `POST`)
- **PATH:** `/api/v1/notifications/{notification_id}/read`
- **RESPONSE (`200 OK`):**
  ```json
  {
    "id": "00000000-0000-0000-0000-000000000051",
    "is_read": true
  }
  ```

### 8.3 Create Notification (Admin / System)
- **METHOD:** `POST`
- **PATH:** `/api/v1/notifications`
- **REQUEST:**
  ```json
  {
    "student_id": "00000000-0000-0000-0000-000000000002",
    "application_id": "00000000-0000-0000-0000-000000000020",
    "title": "Document Verification Required",
    "message": "Please re-upload your income certificate.",
    "category": "DEFICIENCY"
  }
  ```
- **RESPONSE (`201 Created`):** Returns the created `NotificationResponse`.

---

## 9. JAGO Conversational Assistant

### 9.1 Send Inquiry Message
- **METHOD:** `POST`
- **PATH:** `/api/v1/jago/conversations/{conversation_id}/messages`
- **HEADERS:** `Authorization: Bearer <token>` (optional, enables automatic student/application context resolution)
- **REQUEST:**
  ```json
  {
    "message": "What is my payment status?"
  }
  ```
  *(Note: If authenticated, `application_id` and `student_id` are automatically deduced from the caller's active application and student profile! If unauthenticated, `application_id` can be supplied in the body, in `context`, or inline in the message text).*
- **RESPONSE (`200 OK`):**
  ```json
  {
    "conversation_id": "conv-101",
    "intent": "PAYMENT_STATUS",
    "message": "Your DBT payment status is 'PENDING_VERIFICATION': Application is pending document verification before sanction (Simulated prototype mode)",
    "data": {
      "application_id": "00000000-0000-0000-0000-000000000020",
      "status": "PENDING_VERIFICATION",
      "message": "Application is pending document verification before sanction",
      "disbursement_mode": "DIRECT_BENEFIT_TRANSFER",
      "payment_reference": null,
      "evaluation_mode": "MOCK"
    },
    "source": "payment_service.get_payment_status",
    "suggestions": [
      "Check status for 00000000-0000-0000-0000-000000000020",
      "Check deficiencies for 00000000-0000-0000-0000-000000000020"
    ]
  }
  ```
- **SUPPORTED INTENTS:**
  - `APPLICATION_STATUS`: Inquires about current stage and lifecycle status.
  - `APPLICATION_DEFICIENCIES`: Inquires about document mismatches or flagged defects.
  - `PAYMENT_STATUS`: Inquires about DBT release and sanction state.
  - `ELIGIBILITY`: Assesses scheme eligibility for student schemes.
  - `UNKNOWN`: Graceful fallback providing recommended inquiry suggestions.

---

## 10. Documents & Verification Pipeline

### 10.1 Link Document to Application
- **METHOD:** `POST`
- **PATH:** `/api/v1/applications/{application_id}/documents`
- **REQUEST:** `{"document_id": "44444444-5555-6666-7777-888888888888"}`

### 10.2 Create Verification Record
- **METHOD:** `POST`
- **PATH:** `/api/v1/applications/{application_id}/verifications`
- **REQUEST:** `{"document_id": "44444444-5555-6666-7777-888888888888"}`

### 10.3 Execute Verification (Mock Engine)
- **METHOD:** `POST`
- **PATH:** `/api/v1/verifications/{verification_id}/execute`
- **DETERMINISTIC SIMULATION BEHAVIOR:**
  - `document_type == "TEST_VERIFIED"` -> `status: "VERIFIED"`
  - `document_type == "TEST_MISMATCH"` -> `status: "MISMATCH"`
  - `document_type == "TEST_FAILED"` -> `status: "FAILED"`

### 10.4 Enqueue Manual Review
- **METHOD:** `POST`
- **PATH:** `/api/v1/verifications/{verification_id}/manual-review`
- **RESTRICTION:** Verification status must be `MISMATCH`.

---

## 11. Pre-Seeded Development Demo Data
When the database is seeded (`python -m app.seed`), the following deterministic test records are available:

| Entity | ID / Value | Purpose |
| :--- | :--- | :--- |
| **Demo User** | `00000000-0000-0000-0000-000000000001`<br>`demo.student@example.com` / `DemoPassword123!` | Test login (`POST /api/v1/auth/login`) & user lookup |
| **Demo Student** | `00000000-0000-0000-0000-000000000002`<br>`Demo Student User` | Attached to Demo User |
| **Scholarships** | `00000000-0000-0000-0000-000000000010` (`POST_MATRIC`)<br>`00000000-0000-0000-0000-000000000011` (`PRE_MATRIC`)<br>`00000000-0000-0000-0000-000000000012` (`NATIONAL_OVERSEAS`)<br>`00000000-0000-0000-0000-000000000013` (`TOP_CLASS_EDUCATION`) | Scheme catalog & eligibility targets |
| **Application** | `00000000-0000-0000-0000-000000000020`<br>Status: `DRAFT` | Target for status, deficiencies, payment status, JAGO |
| **Documents** | `00000000-0000-0000-0000-000000000030` (`MOCK_ST_CERTIFICATE`)<br>`00000000-0000-0000-0000-000000000031` (`TEST_VERIFIED`)<br>`00000000-0000-0000-0000-000000000032` (`TEST_MISMATCH`) | Document linking & deterministic verification demos |
| **Verification Record** | `00000000-0000-0000-0000-000000000040`<br>Status: `PENDING` | Ready for execution |
| **Notifications** | `00000000-0000-0000-0000-000000000050` (Read)<br>`00000000-0000-0000-0000-000000000051` (Unread)<br>`00000000-0000-0000-0000-000000000052` (Unread) | Demo notifications for `GET /api/v1/notifications/me` |

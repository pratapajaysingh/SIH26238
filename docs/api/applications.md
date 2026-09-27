# Application Module API Contract

## 1. Playbook-Defined Requirements

The following requirements are explicitly mandated by the **TribalSetu Team Development & Integration Playbook**:

### Module Ownership & Responsibilities
- **Owner:** Backend/Core owns FastAPI, student profile, schemes, applications, and database.
- **Primary Responsibilities:** Draft/submit/application lifecycle and application APIs.

### Endpoints
- `GET /api/v1/applications`
- `POST /api/v1/applications`
- `GET /api/v1/applications/{id}/timeline` *(Application tracker)*

### Allowed Application Status Vocabulary
Only the following uppercase status values are permitted:
```text
DRAFT, SUBMITTED, IN_VERIFICATION, DEFICIENCY, SANCTIONED, REJECTED, WITHDRAWN, COMPLETED
```
*Rule: Do not invent alternate spellings or unapproved statuses.*

### Dependencies
- Application depends on:
  - **Student** (Profile ownership)
  - **Scheme** (Target scholarship)
  - **Documents** (Supporting assets)
- Downstream modules depending on Applications:
  - **Verification:** depends on Application, documents, adapters (`GET /api/v1/applications/{id}/verifications`)
  - **Manual Review:** exception queue depends on Verification, applications
  - **Payments:** depends on Applications, adapters (`GET /api/v1/applications/{id}/payment-status`, with legacy alias `/payments`)
  - **Notifications:** depends on Users, applications
  - **JAGO:** calls approved service for Application status

### Architecture & Database Rules
- **Internal IDs:** UUID strings are the project rule for internal IDs.
- **Database Ownership:** PostgreSQL is owned exclusively by Backend/Core.
- **Migrations:** All schema changes must be applied via Alembic migrations.
- **Status Separation:** Keep application status and status history separate.
- **Document Reusability:** Documents are reusable student assets; `application_documents` links them to applications.

---

## 2. Team-Approved Phase-1 Contract

The following decisions are **TEAM-APPROVED** for minimal Phase-1 implementation and must not be confused with playbook-defined requirements.

### Database Table: `applications`

```sql
CREATE TABLE applications (
    id VARCHAR PRIMARY KEY,
    student_id VARCHAR NOT NULL REFERENCES students(id),
    scholarship_id VARCHAR NOT NULL REFERENCES scholarships(id),
    status VARCHAR NOT NULL
);
```

#### Fields ONLY:
- **`id`**: `String`, internally generated UUID, `PRIMARY KEY`, `NOT NULL`
- **`student_id`**: `String`, `FOREIGN KEY -> students.id`, `NOT NULL`
- **`scholarship_id`**: `String`, `FOREIGN KEY -> scholarships.id`, `NOT NULL`
- **`status`**: `String`, `NOT NULL` (values must be from the playbook status vocabulary).

*Team Decision:* New applications created during Phase 1 will default to initial status **`DRAFT`**.

---

### POST Endpoint: `POST /api/v1/applications`

#### Request Payload
```json
{
  "student_id": "<student-uuid>",
  "scholarship_id": "<scholarship-uuid>"
}
```

#### Behavior
1. Validate that the referenced `student_id` exists in `students`. If not, reject with HTTP 404.
2. Validate that the referenced `scholarship_id` exists in `scholarships`. If not, reject with HTTP 404.
3. Construct the application with an internally generated UUID and default status `DRAFT`.
4. Persist to PostgreSQL and return the created record.

#### Success Response (`HTTP 200 OK`)
```json
{
  "id": "<application-uuid>",
  "student_id": "<student-uuid>",
  "scholarship_id": "<scholarship-uuid>",
  "status": "DRAFT"
}
```

#### Error Responses
- **Student not found:** `HTTP 404 Not Found` (`{"detail": "Student not found"}`)
- **Scholarship not found:** `HTTP 404 Not Found` (`{"detail": "Scholarship not found"}`)

---

### GET Endpoint: `GET /api/v1/applications`

#### Purpose
Returns a list of all application records currently in the system.

#### Success Response (`HTTP 200 OK`)
```json
[
  {
    "id": "<application-uuid>",
    "student_id": "<student-uuid>",
    "scholarship_id": "<scholarship-uuid>",
    "status": "DRAFT"
  }
]
```

---

### GET Endpoint: `GET /api/v1/applications/{application_id}/timeline`

#### Purpose
Returns the complete, chronologically ordered lifecycle history/timeline events for an application.

#### Database Table: `application_timeline`
```sql
CREATE TABLE application_timeline (
    id VARCHAR PRIMARY KEY,
    application_id VARCHAR NOT NULL REFERENCES applications(id),
    status VARCHAR NOT NULL,
    message VARCHAR,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
```

#### Status Vocabulary
Permitted status history values adhere strictly to the approved vocabulary:
`DRAFT`, `SUBMITTED`, `IN_VERIFICATION`, `DEFICIENCY`, `SANCTIONED`, `REJECTED`, `WITHDRAWN`, `COMPLETED`

#### Success Response (`HTTP 200 OK`)
```json
[
  {
    "id": "00000000-0000-0000-0000-000000000060",
    "application_id": "00000000-0000-0000-0000-000000000020",
    "status": "DRAFT",
    "message": "Application drafted by student",
    "created_at": "2026-09-20T10:00:00",
    "timestamp": "2026-09-20T10:00:00"
  }
]
```

#### Error Response
- **Application Not Found:** `HTTP 404 Not Found` (`{"detail": "Application not found"}`)

---

### POST Endpoint: `POST /api/v1/applications/{application_id}/transition`

#### Purpose
Executes a controlled, validated lifecycle status transition for an application. Atomically updates `Application.status` and appends a chronological record to `application_timeline`.

*(Note: `PATCH /api/v1/applications/{application_id}/status` is supported as a non-schema alias).*

#### Permitted Transition Matrix
| Current Status | Allowed Next States |
| :--- | :--- |
| **`DRAFT`** | `SUBMITTED`, `WITHDRAWN` |
| **`SUBMITTED`** | `IN_VERIFICATION`, `DEFICIENCY`, `REJECTED`, `WITHDRAWN` |
| **`IN_VERIFICATION`** | `DEFICIENCY`, `SANCTIONED`, `REJECTED`, `WITHDRAWN` |
| **`DEFICIENCY`** | `IN_VERIFICATION`, `SUBMITTED`, `REJECTED`, `WITHDRAWN` |
| **`SANCTIONED`** | `COMPLETED`, `REJECTED` |
| **`REJECTED`** | *(Terminal state - no transitions permitted)* |
| **`WITHDRAWN`** | *(Terminal state - no transitions permitted)* |
| **`COMPLETED`** | *(Terminal state - no transitions permitted)* |

#### Request Payload
```json
{
  "status": "SUBMITTED",
  "message": "Application submitted by student"
}
```

#### Success Response (`HTTP 200 OK`)
```json
{
  "id": "00000000-0000-0000-0000-000000000020",
  "status": "SUBMITTED",
  "previous_status": "DRAFT",
  "message": "Application submitted by student"
}
```

#### Error Responses
- **Application Not Found:** `HTTP 404 Not Found` (`{"detail": "Application not found"}`)
- **Unapproved Status String:** `HTTP 400 Bad Request` (`{"detail": "Invalid status '...'. Allowed statuses: DRAFT, SUBMITTED, IN_VERIFICATION, DEFICIENCY, SANCTIONED, REJECTED, WITHDRAWN, COMPLETED"}`)
- **Disallowed Transition:** `HTTP 400 Bad Request` (`{"detail": "Cannot transition application from '<current>' to '<target>'. Allowed next states: [...]"}`)

---

## 3. Implementation Status & Limitations

- **Lifecycle State Transitions:** Implemented via `POST /api/v1/applications/{application_id}/transition`. Atomically updates application status and records an `ApplicationTimeline` event.
- **Timeline Tracking:** Implemented via dedicated `application_timeline` table, preserving separation of current status and chronological history. Initial applications automatically record a `DRAFT` event.
- **Payment / DBT Status:** Approved canonical endpoint is `GET /api/v1/applications/{application_id}/payment-status` (with a non-schema compatibility alias at `/payments`). Operates in deterministic prototype simulation mode (`evaluation_mode: "MOCK"`).
- **Government Adapters:** Architectural adapter boundaries are implemented under `app.integrations` for DigiLocker, NSP, SFMP/PFMS, NOS, APAAR, UDISE+, AISHE, UIDAI, State e-District, and UGC/NTA. No live government APIs are called without authorized government onboarding and production credentials.

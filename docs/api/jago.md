# JAGO — LLM-Powered Conversational Scholarship Assistant

> **Clarification on External Government Systems:**  
> JAGO is an LLM-powered conversational assistant that retrieves student-specific information through authenticated TribalSetu backend services. External government integrations (PFMS, DigiLocker, District Verification) remain mock/adaptor-based in the SIH prototype.

---

## 1. Overview & Target Architecture

JAGO is the dedicated AI scholarship guidance assistant for the Ministry of Tribal Affairs (MoTA) under TribalSetu. It enables Scheduled Tribe (ST) students to ask questions naturally in English, Hindi, and Hinglish regarding scholarship status, deficiencies, DBT payments, eligibility rules, and scheme documentation.

```text
Flutter JAGO Chat UI
        ↓
POST /api/v1/jago/conversations/{conversation_id}/messages
        ↓
Authenticated FastAPI JAGO Layer (Resolves Student/User Context)
        ↓
LLM Orchestration Layer (Google GenAI SDK: google-genai)
        ↓
Tool / Function Calling (JagoToolSet)
        ↓
Approved TribalSetu Domain Services
        ↓
PostgreSQL Database / Scholarship Knowledge Base
        ↓
Tool Execution Results (Sanitized JSON)
        ↓
Gemini LLM (Synthesizes factual natural-language answer)
        ↓
FastAPI Response
        ↓
Flutter Chat UI (Displays answer, sources, suggestions)
```

---

## 2. Critical Security Rules

1. **No Direct Database Access:** The LLM NEVER connects directly to PostgreSQL, receives database credentials, or executes arbitrary SQL queries.
2. **Safe Tool Boundary:** The LLM can only invoke explicitly registered Python tool functions defined in `JagoToolSet`.
3. **Authenticated Student Context:** Every student-specific tool operates strictly within the authenticated caller's identity. The LLM cannot access another student's applications by supplying an arbitrary student ID.
4. **Ownership Verification:** When an application ID is provided, the tool strictly verifies that the application belongs to the authenticated student (`app.student_id == student.id`). Cross-student access returns an explicit `UNAUTHORIZED` error.
5. **Anti-Hallucination Policy:** JAGO is strictly forbidden from fabricating application approval outcomes, sanction dates, payment release timelines, or government decisions. If data is not returned by an approved tool or verified knowledge base, JAGO explicitly states that the information is unavailable.
6. **Read-Focused Operations:** JAGO does not modify application records, trigger payments, approve verifications, or mutate user data.

---

## 3. Gemini Integration & Environment Configuration

JAGO utilizes Google's official Python GenAI SDK: [`google-genai`](https://pypi.org/project/google-genai/).

### Environment Variables

Configure the following variables in `backend/.env` (see `backend/.env.example`):

```bash
# Gemini LLM Configuration (Google GenAI SDK)
GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_MODEL=gemini-2.5-flash
```

- **`GEMINI_API_KEY`**: API key obtained from [Google AI Studio](https://aistudio.google.com/). If omitted or left empty, JAGO starts safely without crashing and operates in deterministic fallback mode.
- **`GEMINI_MODEL`**: Configurable Gemini model identifier (default: `gemini-2.5-flash`).

### How to Create & Configure a Gemini API Key

1. Visit [Google AI Studio](https://aistudio.google.com/) and sign in with your Google account.
2. Click **Get API key** in the left sidebar.
3. Click **Create API key** (select a Google Cloud project or create a default one).
4. Copy the generated key.
5. In your local development environment:
   ```bash
   # Windows PowerShell
   $env:GEMINI_API_KEY="your_actual_key_here"

   # Or in backend/.env:
   GEMINI_API_KEY=your_actual_key_here
   ```
6. **Never commit real API keys to version control.** `.env` files are excluded in `.gitignore`.

---

## 4. Deterministic Fallback Behavior

If `GEMINI_API_KEY` is missing, unconfigured, or if the Gemini API encounters a network timeout or provider error:
1. The backend **does not crash or return a 500 error**.
2. JAGO automatically switches to the built-in deterministic rule engine (`_process_jago_message_deterministic`).
3. The deterministic pipeline uses regex/keyword intent classification, extracts application IDs, and invokes the identical backend domain services.
4. Multilingual response templates in English and Hindi provide accurate, formatted answers.

---

## 5. Safe Backend Tools Exposed to LLM

All tools are encapsulated within `JagoToolSet` (`backend/app/services/jago_tools.py`):

| Tool Name | Scope & Parameters | Description |
| :--- | :--- | :--- |
| `get_my_application_status` | `application_id: str = ""` | Retrieves the current stage (Draft, In Verification, Sanctioned, etc.) and timestamp of the student's application. |
| `get_my_application_timeline` | `application_id: str = ""` | Returns chronological audit log of verification milestones and actions. |
| `get_my_application_deficiencies` | `application_id: str = ""` | Identifies rejected documents, mismatches, or items needing student correction. |
| `check_my_eligibility` | `scheme_name_or_code: str = ""` | Evaluates eligibility criteria and verifies single-scholarship conflict rules. |
| `get_my_payment_status` | `application_id: str = ""` | Retrieves DBT disbursement stage and PFMS bank credit status. |
| `get_scholarship_information` | `scheme_name_or_code: str = ""` | Delivers verified knowledge on the 5 MoTA schemes (Pre-Matric, Post-Matric, Top Class, NFST, NOS). |
| `get_required_documents` | `scheme_name_or_code: str = ""` | Provides mandatory document checklist and DigiLocker availability for a scheme. |
| `get_my_profile_summary` | None | Returns non-sensitive student profile details (name, email, verification badge). |
| `get_my_notifications` | `unread_only: bool = False` | Fetches official student notifications, deadline reminders, and alerts. |

---

## 6. Conversation Memory & Multi-Tool Execution

- **Bounded Conversation Window:** Lightweight in-memory conversation history is maintained per `conversation_id` up to 20 turns, allowing contextual follow-up questions (e.g. "when was it last updated?" or "what about my payment?").
- **Multiple Tool Calling:** In complex queries (e.g. *"my application is verified but payment has not arrived"*), the LLM invokes multiple tools (`get_my_application_status` + `get_my_payment_status`) and synthesizes both results into a single coherent answer.

---

## 7. Example Queries Across Languages

| Language | Query Example | Expected Response / Tool Behavior |
| :--- | :--- | :--- |
| **English** | `"What is my scholarship status?"` | Calls `get_my_application_status` and returns current verification stage. |
| **English** | `"What documents are missing from my application?"` | Calls `get_my_application_deficiencies` and lists required corrections. |
| **English** | `"Tell me about Top Class scholarship and required documents"` | Calls `get_scholarship_information` + `get_required_documents`. |
| **Hindi** | `"मेरी स्कॉलरशिप का स्टेटस क्या है?"` | Responds in polite Hindi with status details. |
| **Hinglish** | `"bhai mera application verified hai but paisa kyu nahi aaya?"` | Calls `get_my_application_status` and `get_my_payment_status` and explains in Hinglish. |
| **Hinglish** | `"main NFST ke liye eligible hoon?"` | Calls `check_my_eligibility(scheme_name_or_code='NFST')`. |

---

## 8. Local Setup & Testing

### Running Tests

```bash
# Run JAGO LLM unit and integration tests (14 test cases)
cd backend
pytest tests/test_jago_llm.py

# Run all JAGO tests
pytest tests/test_jago.py tests/test_jago_llm.py tests/test_jago_multilingual.py

# Run complete backend test suite
pytest

# Run Flutter JAGO UI tests
cd ../frontend
flutter test test/jago_test.dart
```

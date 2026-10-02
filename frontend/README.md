# TribalSetu Flutter Client (SIH-26238)

Frontend mobile and web client for **TribalSetu** (Unified Scholarship Application Platform for Tribal Students, Ministry of Tribal Affairs).

---

## 1. Running Modes

TribalSetu supports two operational modes controlled by compile-time environment flags (`--dart-define`):

| Mode | Flag | Description |
| :--- | :--- | :--- |
| **Mock Mode** (Default) | `USE_MOCK=true` or omitted | Runs fully self-contained with realistic synthetic data, simulated DigiLocker documents, and instant responses. |
| **API Mode** | `USE_MOCK=false` | Connects over HTTP to the running FastAPI backend (`backend/app`). |

---

## 2. Running in API Mode (Single Documented Method)

Ensure the backend server is running first:
```bash
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Then run Flutter specifying `--dart-define=USE_MOCK=false` and the target platform's `API_BASE_URL`:

### A. Android Emulator
Android emulators access the host machine's `localhost` via the special loopback IP `10.0.2.2`:
```bash
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

### B. Web (Chrome / Edge)
Use a fixed port (`--web-port 5000`) so the CORS origin matches `CORS_ORIGINS` in backend `.env`:
```bash
flutter run -d chrome --web-port 5000 --dart-define=API_BASE_URL=http://localhost:8000
```

### C. Windows Desktop
```bash
flutter run -d windows --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://localhost:8000
```

### D. Physical Android or iOS Device
When debugging on a physical phone connected over Wi-Fi, point to your computer's local area network (LAN) IP:
```bash
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://<YOUR_COMPUTER_LAN_IP>:8000
```
*(Example: `flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://192.168.1.15:8000`)*

---

## 3. Seed User Credentials

When operating in API mode, use the following deterministic seeded credentials (`backend/app/seed.py`):

| Role | Name | Email | Password | Scenario |
| :--- | :--- | :--- | :--- | :--- |
| **Student** | Arjun Munda | `demo.student@example.com` | `DemoPassword123!` | Active Post-Matric application, in verification stage. |
| **Student** | Rani Marandi | `demo.student2@example.com` | `DemoPassword456!` | Eligible student with 0 applications (Unreached Beneficiary demo). |
| **Student** | Sunita Soren | `demo.student3@example.com` | `DemoPassword789!` | Application with missing document deficiency / manual review queue. |
| **Student** | Birsa Kerketta | `demo.student4@example.com` | `DemoPassword012!` | Completed NFST fellowship with credited DBT stipend. |
| **Admin** | MoTA Nodal Officer | `admin.mota@tribalsetu.gov.in` | `AdminSecret123!` | Ministry Dashboard, Manual Review Queue, and Outreach Dispatch. |

---

## 4. Running in Mock Mode

To run completely offline without an active backend instance:
```bash
flutter run
```
Or explicitly:
```bash
flutter run --dart-define=USE_MOCK=true
```

# CallProof

CallProof is a closed-loop phone agent system built for the CALL-E: Your Code Is Calling hackathon.

CALL-E executes real calls, Call Analyzer verifies outcomes against explicit policies, and AgentKit Rails orchestrates memory, human review, telemetry, and continuous improvement.

Development status and milestones are tracked in [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md).

## Repository layout

```text
apps/web/                 Rails application and AgentKit host
services/call_analyzer/   Python analysis service
contracts/                Versioned integration schemas
docs/                     Architecture and submission documentation
hackathon/                Upstream contribution preparation
```

The project defaults to fake adapters and must not place a real phone call without an explicit live-mode opt-in.

## Current vertical slice

The Rails application now supports two deterministic scenarios:

- a compliant simulated call that AgentKit marks as verified;
- a simulated policy violation that Call Analyzer supports with transcript evidence and AgentKit suspends at a persisted HITL gate.

It also includes the first real Rails ↔ Call Analyzer boundary:

- FastAPI transcript ingestion with persisted `received → analyzing → completed` states;
- idempotent analysis requests and a recovery endpoint;
- HMAC-signed completion webhooks with timestamp and replay protection;
- a second resumable AgentKit flow that routes remote policy exceptions to HITL.

The official CALL-E HTTP adapter is implemented behind explicit live-call safety
gates. The demo UI cannot enable it. Terminal result polling is normalized into
the same transcript contract and then sent through Call Analyzer and AgentKit.

The optional live workflow is deliberately two-step: it first creates a
no-side-effect contract preview, masks the recipient number, and only exposes
confirmation after checking provider, global live switch, and API-key readiness.
A typed phrase and browser confirmation remain required after those checks.

```bash
cd apps/web
rvm use 3.4.1
bundle install
bin/rails db:prepare
bin/rails server
```

Open `http://localhost:3000`. The default configuration uses fictional data, a fake phone provider, and a fake LLM adapter.

Run the analyzer independently with:

```bash
cd services/call_analyzer
python3 -m venv .venv
source .venv/bin/activate
pip install -e '.[dev]'
CALLPROOF_WEBHOOK_SECRET=replace-me uvicorn call_analyzer.main:app --reload --port 8001
```

`docker compose up --build` starts the complete safe stack: Rails at `http://localhost:3000`, PostgreSQL with pgvector, the analyzer API at `http://localhost:8001`, Redis, and the RQ worker. The phone provider and LLM adapter remain fake, and external webhook delivery remains disabled. A production deployment must provide a public HTTPS callback URL and explicit live-call switches.

See [docs/calle-integration.md](docs/calle-integration.md) before enabling any
CALL-E environment variables.

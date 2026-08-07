# CALL-E integration decision

Verified against the official CALL-E resources on 2026-08-01:

- [CALL-E Integrations](https://github.com/CALLE-AI/call-e-integrations)
- [CALL-E documentation](https://docs.heycall-e.com)

CallProof uses the Developer API from the trusted Rails backend:

- `POST /v1/calls` with Bearer authentication and `Idempotency-Key`;
- `GET /v1/calls/{call_id}` for status and terminal result recovery;
- structured `result_schema` and `recipient_result_schema` fields;
- an HTTPS `webhook_url` reserved for the official terminal webhook integration.

The current implementation polls the documented GET endpoint after the initial
60-second delay, then every 10 seconds until terminal. We intentionally have not
implemented a CALL-E webhook verifier because the accessible public reference did
not provide enough signature details to implement it without guessing.

## Live-call safety

A real call requires all of the following:

1. `CALLPROOF_CALL_PROVIDER=calle`;
2. `CALLPROOF_LIVE_CALLS=true` exactly;
3. a `CallRequest` with `live_mode=true`;
4. persisted `confirmed_at` from a future explicit confirmation screen;
5. `CALLE_API_KEY` and an HTTPS `CALLE_WEBHOOK_URL`.

The current demo controller always sets `live_mode=false`, so it cannot place a
real call. The demo and the automated test suite never place a call and never
require credentials. Live calls only happen through the deliberate, operator
authenticated two-step confirmation flow.

## Verified live test (2026-08-05)

A single controlled live call was placed through the official CALL-E MCP surface
(`plan_call` → `run_call` → `get_call_run`) to a consenting tester's own phone,
to validate end-to-end connectivity and the result contract. No production data
was involved.

- **Outcome:** `COMPLETED`, 28s call, `task_completed=true`, completion
  confidence `0.93 (high)`.
- **Policy behaviour observed:** the agent disclosed the call was recorded, made
  no offers or commitments, obtained the live confirmation, and ended in under a
  minute — matching the immutable contract.
- **Negative signal observed:** earlier attempts to the same number returned
  `DECLINED` (carrier-level reject: no duration, no transcript). Our pipeline
  treats that as a failed, unverifiable call — it never reaches the analyzer —
  which is exactly the fail-closed behaviour required by the PR #66 review.
- **Dialing note:** the Mexican mobile dialed correctly as `+52 <10 digits>`
  (E.164 without the legacy `1` trunk). The `DECLINED` results were transient
  carrier rejections, not a formatting problem.

A redacted copy of the real `get_call_run` payload is committed as a test fixture
at `apps/web/test/fixtures/files/calle_mcp_get_call_run.json` and drives the
normalizer tests below.

## Two result shapes: REST and MCP

CALL-E exposes the same call through two surfaces with different result shapes:

| Surface | Used by | Result shape |
| --- | --- | --- |
| REST Developer API | the durable Rails poller (`CallProviders::Calle#retrieve`) | top-level `status` + `recipients[].attempts[].transcript_turns` + `recipients[].structured_result` |
| MCP `get_call_run` | desktop/CLI agents | `status` + nested `result` with `outcome`, `summary`, a newline-joined `transcript` string, and `extracted.{calling,to_phones}` |

`CallProviders::CalleResultNormalizer.canonicalize/1` detects the shape and
returns the REST envelope in both cases, so a single validation and persistence
path (`CallProviders::PersistCalleResult`) serves either surface. Recipient
status, phone match, task completion and confidence are validated before a call
is marked complete regardless of which surface produced the result.


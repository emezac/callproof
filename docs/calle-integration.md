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
real call. No live API request has been made during development or tests.


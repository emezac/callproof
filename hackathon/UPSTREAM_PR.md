# Upstream PR preparation

Target: `CALLE-AI/awesome-phone-call-agents`

## Proposed Git metadata

- Branch: `feat/callproof-verification-app`
- Commit: `feat(apps): add CallProof verification workflow`
- PR title: `feat(apps): add CallProof verification workflow`

Validate the branch name in the upstream checkout:

```bash
python3 scripts/check_branch_name.py --branch feat/callproof-verification-app
```

## Files to apply

Copy `hackathon/upstream/apps/web/callproof/` to the same path in the upstream
fork. Add this row to the Apps table in the upstream root README:

```markdown
| [`apps/web/callproof`](apps/web/callproof/) | Ruby / Python | Closed-loop CALL-E workflow that checks transcript evidence against an immutable call contract and routes policy exceptions to persisted AgentKit human review. |
```

Then run:

```bash
python3 scripts/validate_repository.py
```

## Suggested PR body

### What

Adds CallProof, a Rails and FastAPI reference app for verifying a CALL-E result
against an explicit policy contract instead of trusting structured extraction
alone. Transcript evidence supports every policy finding, and AgentKit Rails
persists the human-review gate and decision ledger.

### Safety and side effects

- Default demo and tests place no calls and require no credentials.
- Live execution requires a separate preview, a typed confirmation, three
  server-side readiness gates, and a browser confirmation.
- Samples use fictional reserved phone numbers and UI summaries mask recipients.
- One stable idempotency key represents one intended call.
- Drafts can be canceled before confirmation; there is no recurring schedule.

### Verification

- Rails tests, RuboCop, Zeitwerk, and Brakeman pass.
- Python API, JSON Schema, HMAC, idempotency, and RQ tests pass.
- `python3 scripts/validate_repository.py` passes after applying this package.


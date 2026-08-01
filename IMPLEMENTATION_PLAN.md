# CallProof implementation plan

## 1. Product thesis

CallProof is a closed-loop phone agent system:

- CALL-E executes real outbound calls.
- Call Analyzer evaluates what actually happened and cites transcript evidence.
- AgentKit Rails controls the workflow, memory, human review, telemetry, and continuous improvement.

The differentiator is not merely making a phone call. It is proving whether the call respected the user's objective and policy, learning from exceptions, and improving the next call without losing auditability.

## 2. Repository decision

Use one product monorepo in this directory.

```text
seis/
├── apps/
│   └── web/                    # Rails product and AgentKit host
├── services/
│   └── call_analyzer/          # Adapted Python analysis service
├── contracts/                  # Versioned JSON Schemas shared across services
├── docs/                       # Architecture, demo, safety, and submission notes
├── hackathon/                  # Files used to prepare the upstream contribution
├── docker-compose.yml          # Local integrated environment
├── IMPLEMENTATION_PLAN.md
└── README.md
```

Why a monorepo:

- the Rails workflow and analyzer contract must change atomically;
- one commit can update code, schemas, fixtures, and end-to-end tests;
- one command can start the complete demo;
- CI can verify the boundary between Ruby and Python;
- it is easier for judges to understand and run.

Call Analyzer remains a separate deployable service inside the monorepo. Rails and Python must not share database tables. They communicate through a versioned HTTP contract.

The fork of `CALLE-AI/awesome-phone-call-agents` will not be the primary repository. Near submission, we will create a focused English-language contribution under `apps/web/callproof/` that links to or packages the runnable demo, includes a no-call mode, documents side effects, and passes the upstream validation script.

## 3. System boundaries

### Rails and AgentKit Rails

Rails owns:

- users and operator profiles;
- contacts and providers;
- call objectives and policy contracts;
- CALL-E credentials and invocation;
- call lifecycle and webhook ingestion;
- human decisions and learned preferences;
- the product dashboard.

AgentKit Rails provides:

- resumable orchestration;
- policy and preference memory;
- HITL decision ledger;
- audit and telemetry;
- quality findings and improvement experiments.

### Call Analyzer

Call Analyzer owns:

- transcript normalization;
- goal-completion evaluation;
- policy-adherence evaluation;
- unauthorized-commitment detection;
- evidence spans and contradictions;
- analysis confidence and review recommendation;
- analytical artifacts and processing events.

### CALL-E

CALL-E owns:

- call planning and execution;
- PSTN interaction;
- live conversation behavior;
- provider call status, transcript, and structured result.

## 4. Integration contract

The critical path uses asynchronous REST plus signed webhooks, not A2A.

1. Rails receives and persists a terminal CALL-E webhook.
2. Rails submits `POST /api/v1/analyses` with an idempotency key.
3. Call Analyzer responds `202 Accepted` with an `analysis_id`.
4. Call Analyzer evaluates the transcript in a background worker.
5. Call Analyzer sends a signed `analysis.completed` or `analysis.failed` webhook.
6. Rails records the event idempotently and starts the verdict-processing flow.
7. Rails can recover a missed webhook with `GET /api/v1/analyses/:id`.

A2A is an optional public facade added later. It may expose capabilities such as `analyze_phone_call`, but those capabilities must call the same internal analysis service and pass references rather than large audio payloads.

Initial schemas:

- `contracts/call-analysis-request.schema.json`
- `contracts/call-analysis-result.schema.json`
- `contracts/call-event.schema.json`

Every envelope includes `schema_version`, stable identifiers, timestamps, and correlation metadata.

## 5. Product workflow

### Flow A: Execute a call

1. Capture explicit user intent.
2. Normalize and mask the E.164 phone number for display.
3. Retrieve applicable provider and task policies.
4. Build an evaluable `CallContract`.
5. Show a dry-run preview.
6. Execute one CALL-E call with an idempotency key.
7. Persist provider events and terminal output.
8. Submit the transcript to Call Analyzer.

### Flow B: Process the verdict

1. Validate the analyzer response against its JSON Schema.
2. Compare the verdict with the original contract.
3. Route low-confidence or policy-violating results to HITL.
4. Record the human decision with a closed rejection/edit taxonomy.
5. Promote verified preferences to AgentKit memory.
6. Emit domain outcomes and quality telemetry.
7. Feed corrections into the analyzer golden set.

## 6. Initial domain model

- `OperatorProfile`: autonomy settings and ownership boundary.
- `ProviderProfile`: phone endpoint and provider-specific context.
- `CallPolicy`: versioned limits, permissions, and escalation rules.
- `CallRequest`: explicit intent, recipient, status, and idempotency key.
- `CallContract`: immutable policy snapshot used for one call.
- `PhoneCall`: CALL-E identifiers, status, result, and transcript.
- `CallAnalysis`: analyzer identifiers, status, verdict, and confidence.
- `AnalysisEvidence`: transcript turn references supporting a finding.
- `LearnedPreference`: promoted, scoped preference with provenance.
- AgentKit's own run, step, HITL, memory, audit, and telemetry records.

## 7. Delivery phases

### Phase 0 — Foundation

- [x] Select a product monorepo.
- [x] Initialize Git and the Rails application.
- [x] Add AgentKit Rails with a local development override and pinned public fallback.
- [x] Install AgentKit and verify its engine boots.
- [x] Add repository documentation and environment examples.

Exit criterion: the Rails test suite boots with AgentKit installed and no external credentials.

### Phase 1 — Contracts and fake vertical slice

- [x] Define request, result, and webhook schemas.
- [x] Implement a Rails `CallAnalyzers::Http` client.
- [x] Add a fake CALL-E adapter and deterministic fake analyzer.
- [x] Implement call preview, typed confirmation, readiness gates, and auditable cancellation.
- [x] Complete end-to-end no-call tests for compliant and violating outcomes.

Exit criterion: a fictional call progresses from intent to verified verdict without network access.

### Phase 2 — Call Analyzer adaptation

- [x] Review Altur and adapt its state-machine, idempotency, and provider boundaries without copying source.
- [x] Add direct transcript ingestion so STT is optional.
- [x] Add policy and goal evaluation fields.
- [x] Add evidence-turn references and confidence.
- [x] Add signed completion webhooks and status recovery.
- [ ] Preserve audio ingestion as a fallback path.
- [x] Replace in-process background tasks with Altur's RQ/Redis worker boundary, retaining inline tests.
- [ ] Move analyzer persistence from shared SQLite storage to PostgreSQL before multi-host deployment.

Exit criterion: Call Analyzer accepts a CALL-E-shaped fixture and returns a schema-valid verdict.

### Phase 3 — Real CALL-E integration

- [x] Confirm the current official CALL-E API contract.
- [x] Implement a provider adapter behind a stable Ruby interface.
- [ ] Verify authentication and one-call semantics.
- [ ] Implement signed/idempotent CALL-E webhooks.
- [x] Add safe, non-network contract tests for the live adapter.
- [x] Add documented terminal-result polling and transcript normalization.
- [ ] Add an opt-in integration test against a CALL-E test account.

Exit criterion: one real test call completes and is analyzed without manual data transfer.

### Phase 4 — Learning loop

- [x] Implement `ExecutePhoneCallFlow`.
- [x] Implement the remote-verdict `ReviewCallAnalysisFlow`.
- [x] Add HITL review for local and remote exceptions.
- [ ] Promote approved preferences with provider/task scope.
- [ ] Add AgentKit probes and outcomes.
- [ ] Add factory findings for policy violations, analyzer overrides, and confidence drift.

Exit criterion: a human correction changes the policy context used by a later comparable call and remains fully traceable.

### Phase 5 — Product and demonstration

- [x] Build call-contract preview.
- [ ] Build live call timeline.
- [ ] Build plan-versus-actual evidence view.
- [ ] Build learned-policy and HITL views.
- [ ] Prepare the three-call demonstration scenario.
- [ ] Add sample data containing only fictional numbers and identities.

Exit criterion: the complete differentiator can be demonstrated in under three minutes.

### Phase 6 — Hackathon submission

- [ ] Deploy a free-to-test build through the judging period.
- [x] Prepare an English README and testing instructions.
- [x] Provide dry-run/fake-server behavior by default.
- [x] Document credentials, side effects, cancellation, safety, and limitations.
- [x] Prepare `apps/web/callproof/` for the upstream repository.
- [x] Prepare the concise root README entry expected upstream.
- [x] Run `python3 scripts/validate_repository.py` against an upstream checkout with the package applied.
- [ ] Open the upstream PR and use its URL in Devpost.
- [ ] Record and publish a public video shorter than three minutes.
- [ ] Submit the CALL-E account email and functional demo URL.

## 8. Three-call demo script

1. **Learn:** no provider policy exists, so the operator defines a maximum surcharge.
2. **Catch:** a later call exceeds the limit; Call Analyzer cites the exact transcript turns and AgentKit opens HITL review.
3. **Improve:** the corrected preference is retrieved for a comparable call; CALL-E stays within policy and Call Analyzer certifies the outcome without interruption.

## 9. Quality and safety gates

- Default tests never place a real call.
- Live CALL-E use is explicitly opt-in.
- Every external create operation carries an idempotency key.
- Phone numbers are stored deliberately and masked in logs and UI summaries.
- Credentials never enter prompts, transcripts, fixtures, or repository files.
- Webhooks use HMAC signatures, timestamp windows, and replay protection.
- Analyzer conclusions cite transcript evidence.
- Medical, legal, financial, and emergency tasks are rejected or escalated.
- Human timeout decisions do not count as positive learning evidence.
- Contract and analyzer schema versions are immutable after use.

## 10. Immediate implementation order

1. Generate the Rails app and install AgentKit Rails.
2. Create the three JSON Schemas and contract fixtures.
3. Implement fake CALL-E and fake Call Analyzer adapters.
4. Build the first no-call vertical slice.
5. Adapt Call Analyzer's transcript ingestion and verdict model.
6. Connect the real CALL-E API only after the local slice is deterministic.

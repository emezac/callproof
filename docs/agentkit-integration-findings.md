# AgentKit Rails integration findings

## 2026-08-01: install generator load order

The generated Rails application initially loaded `agentkit` from an initializer.
That is too late for `Agentkit::Engine` to register its migration rake task, so
`rails generate agentkit:install` created the initializer and route but failed
at `agentkit:install:migrations`.

The host application currently resolves this by requiring both entry points in
`config/application.rb`, after `Bundler.require` and before the application
class is defined:

```ruby
require "agentkit"
require "agentkit/engine"
```

The generator should add the engine require before invoking its migration task,
or the gem should expose an auto-required entry point that loads the engine
while Rails is constructing the application.

## Ruby compatibility

The current AgentKit source declares Ruby `>= 3.1`, but it contains endless
method definitions whose spacing is parsed incompatibly by Ruby 3.2. CallProof
therefore starts on Ruby 3.4.1. AgentKit should either raise its declared Ruby
requirement or replace the incompatible definitions.

## Persisted `human_gate from:` values

A domain `Suggestion` returned by a prior flow step is serialized as a plain
hash. On resume, `human_gate from:` receives that hash and calls `resolved?`,
which fails. CallProof avoids this by assigning the domain suggestion the exact
gate key (`<run_id>:<step_name>`) and allowing the gate to recover it through
`HITL.by_gate_key`. AgentKit could teach `Flow::Coder` how to round-trip a
`Suggestion`, or make `human_gate` normalize a serialized suggestion hash.

# AGENTS.md — start here (adlc-demo)

Demo monorepo (.NET 8 API + React/Vite frontend) delivered by the slipway plugin

This repository is delivered by the **slipway** Claude Code plugin (0.13.2). This file is the routing page for humans and agents: what is here, which skill to run, which rules apply. Procedures live in the plugin's skills, not here.

## Layout
| App | Path | Kind | Stack | Port | Health |
|---|---|---|---|---|---|
| `api` | `apps/api` | api | dotnet8-api | 8080 | `/health` |
| `web` | `apps/web` | frontend | react-vite | 8080 | `/` |


| Path | Purpose |
|---|---|
| `.slipway/config.yaml` | Delivery options and app inventory (source of truth for every slipway skill) |
| `.slipway/SETUP.md`, `.slipway/setup-azure.sh` | One-time human prerequisites (checklist + idempotent script, dry run by default): GitHub secrets/variables, environment, Entra app registration with OIDC, state storage, RBAC |
| `.slipway/evidence/<app>/` | Verification records per app and deployed tag |
| `infra/foundation/` | Shared cloud resources (registry, key vault, identity, logs, Container Apps environment). Applied by a human after `/slipway:plan`; never by an agent alone |
| `infra/apps/api/` | Compute + image tag of `api` only (own state). Applied only by `slipway-demo-api-cd` behind the environment approval |
| `infra/apps/web/` | Compute + image tag of `web` only (own state). Applied only by `slipway-demo-web-cd` behind the environment approval |
| `.github/workflows/_ci.yml`, `_cd.yml` | Shared CI / CD stages (`workflow_call`), used by every app's thin workflows below |
| `.github/workflows/slipway-demo-api-ci.yml` | CI of `api`: version from `apps/api/version.json`, test, image, tag `api/v<semver>`. Runs only when its inputs change |
| `.github/workflows/slipway-demo-api-cd.yml` | CD of `api`: plan, human approval, apply `infra/apps/api`, smoke test; starts automatically after a green CI on `main` |
| `.github/workflows/slipway-demo-web-ci.yml` | CI of `web`: version from `apps/web/version.json`, test, image, tag `web/v<semver>`. Runs only when its inputs change |
| `.github/workflows/slipway-demo-web-cd.yml` | CD of `web`: plan, human approval, apply `infra/apps/web`, smoke test; starts automatically after a green CI on `main` |
| `compose.yaml` | Local run of all app images as built for the cloud (frontends use `nginx.local.conf`) |
| `.claude/rules/` | Path-scoped rules (see Rules below) |

## Pipelines (one CI and one CD per app)
| App | CI workflow | CD workflow | Version file | Git tag | Inputs (triggers = version pathFilters) |
|---|---|---|---|---|---|
| `api` | `slipway-demo-api-ci` | `slipway-demo-api-cd` | `apps/api/version.json` | `api/v<semver>` | `apps/api`, `libs/dotnet/Demo.Contracts`, `.github/workflows/slipway-demo-api-ci.yml`, `.github/workflows/slipway-demo-api-cd.yml`, `.github/workflows/_ci.yml`, `.github/workflows/_cd.yml`, `infra/apps/api`, `.dockerignore` |
| `web` | `slipway-demo-web-ci` | `slipway-demo-web-cd` | `apps/web/version.json` | `web/v<semver>` | `apps/web`, `.github/workflows/slipway-demo-web-ci.yml`, `.github/workflows/slipway-demo-web-cd.yml`, `.github/workflows/_ci.yml`, `.github/workflows/_cd.yml`, `infra/apps/web` |
A change to a path listed for one app only builds, versions and deploys that app; a path listed for several apps (shared inputs) triggers each of them. CD trigger: `on-ci-success`; pull-request behaviour: `always-run-gate` (see `.claude/rules/pipelines.md`).

## Delivery options chosen
| Dimension | Option |
|---|---|
| cloud | `azure` — Microsoft Azure |
| compute | `aca` — Azure Container Apps |
| registry | `acr` — Azure Container Registry |
| runner | `github-actions` — GitHub Actions |
| versioning | `nbgv` — Nerdbank.GitVersioning |
| branching | `trunk` — Trunk-based (main + short-lived branches + PRs) |
| tracker | `jira` — Jira Cloud (Atlassian Rovo MCP Server; Standard plan or higher) |
| secret_store | `azure-key-vault` — Azure Key Vault |
| base_image | `dhi` — Docker Hardened Images (dhi.io |
| cd_trigger | `on-ci-success` — Automatic: <prefix>-<app>-cd starts when <prefix>-<app>-ci succeeds on the default branch, targeting the CD environment; the environment approval gate still applies |
| pr_checks | `always-run-gate` — Always start; a first gate job lists the changed files and skips the rest when the app is untouched (a skipped job counts as passed, so the checks can be required on the branch) |

Change an option with `/slipway:bootstrap`; do not edit generated files by hand to switch options.

## I want to…
| Goal | Run |
|---|---|
| Onboard or change delivery options | `/slipway:bootstrap` |
| Build and smoke-test one app image locally | `/slipway:dockerize <app path>` |
| Run every app image together locally | `VERSION=$(nbgv get-version -v SemVer2) docker compose up --build` (see `compose.yaml`) |
| See what infrastructure would change | `/slipway:plan <env> --layer foundation\|apps/<app>` |
| Deploy a released tag of one app | `/slipway:deploy <app> <tag> <env>` |
| Prove a deployment is correct | `/slipway:verify <app> <env> <tag>` |
| Track the work | `/slipway:ticket create\|start\|review\|done <key>` |
| Understand the repo before changing it | ask for the `explore` sub-agent |
| Make a scoped change with proof | ask for the `execute` sub-agent with an acceptance command |
| Check claims independently | ask for the `verify` sub-agent |

## Skills
<available_skills>
- slipway:bootstrap — intake interview, app classification, scaffold, ticket
- slipway:dockerize — hardened multi-stage Dockerfile for one app, built and health-checked
- slipway:plan — terraform fmt/validate/plan for one layer; never applies
- slipway:deploy — trigger and monitor CD for an immutable tag
- slipway:verify — falsifiable post-deploy checks; writes .slipway/evidence/<app>/<tag>.md
- slipway:ticket — tracker lifecycle with structured descriptions
- slipway:delivery-knowledge — option reference material (model-invoked)
</available_skills>
Skills come from the plugin (`slipway@slipway-marketplace`, source `integranz/slipway`), declared in `.claude/settings.json`. Local sessions install it once with `/plugin install slipway@slipway-marketplace`; cloud sessions install it automatically.

## Sub-agents
`explore` (read-only facts with `path:line` evidence), `execute` (one scoped change + acceptance output), `verify` (CONFIRMED / REFUTED / UNVERIFIABLE per claim). None of them may apply infrastructure, push images or trigger workflows; guard hooks enforce this.

## Systems of record and tool policy
| Need | Use | Not |
|---|---|---|
| Tickets | `/slipway:ticket` (tracker MCP: Jira Cloud (Atlassian Rovo MCP Server; Standard plan or higher)) | manual browser updates |
| Pipeline status, logs, trigger CD | GitHub MCP via `/slipway:deploy` / `/slipway:verify` | `gh` for writes |
| Cloud inventory for verification | Azure MCP (read-only) or `az … show/list` | Azure MCP for changes |
| Infrastructure changes | Terraform in `infra/*` under the guard hooks | portal, `az … create`, Azure MCP writes |
| Images | CI pushes `acradlcdemo.azurecr.io/<repo>:<semver>` | `docker push` from a laptop, `latest` tags |

## Rules and precedence
Non-negotiables are in `CLAUDE.md`. Path-scoped rules are in `.claude/rules/` and load only when matching files are touched: `terraform.md` (`infra/**`), `pipelines.md` (`.github/workflows/**`), `docker.md` (Dockerfiles), `versioning.md`, `branching.md`. Precedence when instructions overlap: managed policy → user (`~/.claude/CLAUDE.md`) → project (`CLAUDE.md`, `.claude/rules/`) → `CLAUDE.local.md`. Hooks from the plugin are mechanical and cannot be relaxed by any of these; see `.claude/rules/precedence.md`.

## Multi-repo
Open **this repo alone** as the workspace root when working on the apps or their delivery. The plugin repo (`integranz/slipway`) owns cross-cutting changes (templates, hooks, skills); propose changes there rather than patching generated files here. Keep one `.mcp.json`/MCP policy per repo: this repo relies on the plugin's servers and declares none of its own.

## Other agents
Cursor reads this file natively and loads skills from `.claude/skills/` when present; the slipway skills live in the plugin, so use Claude Code for slipway workflows unless a mirror is enabled (`cursor_mirror` in `.slipway/config.yaml`).

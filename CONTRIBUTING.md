# Contributing to slipway-demo

This repository is delivered by the [slipway](https://github.com/integranz/slipway) Claude Code plugin. Read `AGENTS.md` first; it is the routing page for humans and agents.

## Branching and releases
- Trunk-based: `main` is always releasable. Work on a short-lived branch (`feat/<topic>`, `fix/<topic>`, `docs/<topic>`) and open a pull request.
- Every merge to `main` runs the CI of each app whose inputs changed (`slipway-demo-<app>-ci`), which computes that app's version with Nerdbank.GitVersioning (`apps/<app>/version.json`), pushes immutable images `acradlcdemo.azurecr.io/adlc-demo/{api,web}:<semver>` and creates the `v<semver>` tag. Never hand-write tags or bump versions in commits; change `version.json` in a PR when you need a new minor.
- Deployments are separate from merges: `/slipway:deploy <tag> dev` dispatches the CD workflow, which plans first and applies only after a human approves the `dev` environment.

## What you may edit by hand
- Application code under `apps/api/src`, `apps/api/tests`, `apps/web/src`.
- `.slipway/config.yaml` through `/slipway:bootstrap` (options marked *planned* or *later* are not selectable yet).
- Documentation such as this file and `README.md`.

## What is generated (change the plugin templates instead)
`AGENTS.md`, `CLAUDE.md`, `.claude/rules/*`, `.claude/settings.json`, `.github/workflows/*`, `infra/**`, `apps/*/Dockerfile`, `apps/*/.dockerignore`, `apps/web/nginx*.conf`, `compose.yaml`, `.slipway/SETUP.md`, `.slipway/setup-azure.sh`, `.slipway/cloud-setup.sh`. Re-render with the scaffold after a plugin update; a pull request that hand-edits these files will be asked to move the change to the template.

## Before you push
```
dotnet test apps/api
npm --prefix apps/web ci && npm --prefix apps/web test
VERSION=$(nbgv get-version -p apps/api -v SemVer2) docker compose up --build   # api :8080, web :8081 (one local label for both images)
```
Guard hooks in the plugin block the things nobody should do from an agent session: `terraform apply` without a human approval token, committing `.env`/`*.tfvars`/state/plan files, and pushing or deploying mutable tags.

## Verifying a deployment
`/slipway:verify dev <tag>` writes `.slipway/evidence/<tag>.md`; commit it with the ticket closure (`/slipway:ticket done <KEY> --evidence .slipway/evidence/<tag>.md`).

## Protected `main`
`main` accepts changes only through pull requests (ruleset since 2026-09-17). Required checks, two per app: `api changes` and `api ci`, `web changes` and `web ci`. `<app> ci` is the always-running result job: it passes when the app was built and tested green or when the change did not touch the app at all, and fails otherwise (the nested `<app> / test` and `<app> / image` checks only exist when the app is built, so they are not required). Force pushes and branch deletion are blocked. Verification evidence and other docs go through pull requests too.

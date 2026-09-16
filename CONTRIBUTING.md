# Contributing to adlc-demo

This repository is delivered by the [adlc](https://github.com/integranz/adlc) Claude Code plugin. Read `AGENTS.md` first; it is the routing page for humans and agents.

## Branching and releases
- Trunk-based: `main` is always releasable. Work on a short-lived branch (`feat/<topic>`, `fix/<topic>`, `docs/<topic>`) and open a pull request.
- Every merge to `main` runs CI, which computes the version with Nerdbank.GitVersioning (`version.json`), pushes immutable images `acradlcdemo.azurecr.io/adlc-demo/{api,web}:<semver>` and creates the `v<semver>` tag. Never hand-write tags or bump versions in commits; change `version.json` in a PR when you need a new minor.
- Deployments are separate from merges: `/adlc:deploy <tag> dev` dispatches the CD workflow, which plans first and applies only after a human approves the `dev` environment.

## What you may edit by hand
- Application code under `apps/api/src`, `apps/api/tests`, `apps/web/src`.
- `.adlc/config.yaml` through `/adlc:bootstrap` (options marked *planned* or *later* are not selectable yet).
- Documentation such as this file and `README.md`.

## What is generated (change the plugin templates instead)
`AGENTS.md`, `CLAUDE.md`, `.claude/rules/*`, `.claude/settings.json`, `.github/workflows/*`, `infra/**`, `apps/*/Dockerfile`, `apps/*/.dockerignore`, `apps/web/nginx*.conf`, `compose.yaml`, `.adlc/SETUP.md`, `.adlc/setup-azure.sh`, `.adlc/cloud-setup.sh`. Re-render with the scaffold after a plugin update; a pull request that hand-edits these files will be asked to move the change to the template.

## Before you push
```
dotnet test apps/api
npm --prefix apps/web ci && npm --prefix apps/web test
VERSION=$(nbgv get-version -v SemVer2) docker compose up --build   # api :8080, web :8081
```
Guard hooks in the plugin block the things nobody should do from an agent session: `terraform apply` without a human approval token, committing `.env`/`*.tfvars`/state/plan files, and pushing or deploying mutable tags.

## Verifying a deployment
`/adlc:verify dev <tag>` writes `.adlc/evidence/<tag>.md`; commit it with the ticket closure (`/adlc:ticket done <KEY> --evidence .adlc/evidence/<tag>.md`).

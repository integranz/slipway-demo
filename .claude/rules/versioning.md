---
paths:
  - "version.json"
  - ".github/workflows/**"
---
# Versioning rules (Nerdbank.GitVersioning)

- `version.json` at the repository root is the single version source; bump `version` there for a new minor/major. Patch numbers come from git height; never hand-write build numbers.
- CI reads the version with the `dotnet/nbgv` GitHub Action and tags images with `SemVer2`; `nbgv tag` creates the git tag on the release branch.
- Public releases only from `publicReleaseRefSpec` branches (`main`); other branches produce prerelease versions that must not be deployed beyond `dev`.
- One versioning scheme per repository. Switching schemes is a `/slipway:bootstrap` decision, not a workflow edit.

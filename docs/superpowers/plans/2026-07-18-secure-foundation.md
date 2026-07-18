# Secure Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the unsafe legacy baseline with a tested, secret-free repository foundation and reusable local/server Docker Swarm stacks.

**Architecture:** The repository declares immutable stack templates under `stacks/`, keeps generated state outside Git, and exposes shared validation contracts to later platform installers. This phase establishes security, quality automation, and deterministic stack rendering without installing Docker or changing a host system.

**Tech Stack:** Git, Docker Swarm Compose v3, Traefik v3, Portainer CE LTS, Bash, PowerShell, GitHub Actions, ShellCheck, PSScriptAnalyzer, Pester, yamllint, markdownlint, and Gitleaks.

## Global Constraints

- Supported targets are Windows 11 with WSL2 and Ubuntu 22.04/24.04 only.
- Docker workloads use Linux containers.
- The first release supports a single Docker Swarm manager.
- English is primary and Spanish is a complete translation.
- Installation is automatic but every planned system change is visible and confirmed.
- Generated environment files, ACME data, logs, backups, certificates, and private keys are never tracked.
- Portainer Server and Agent use matching explicit LTS tags.
- The server stack exposes no insecure Traefik dashboard and no Portainer port 9000.
- Commits use the owner's Git identity, English Conventional Commit subjects, and no AI attribution.
- Existing invalid worktree changes are removed explicitly; destructive Git reset is forbidden.

---

## File Map

- `.gitignore`: runtime data and secret exclusions.
- `.gitattributes`: stable platform line endings.
- `.editorconfig`: formatting contract.
- `.env.example`: public non-secret configuration.
- `stacks/local/*.yml`: local HTTP routing and Portainer.
- `stacks/server/*.yml`: server HTTPS routing and Portainer.
- `lib/shell/common.sh`: Bash logging, errors, checks, and redaction.
- `lib/powershell/Common.psm1`: equivalent PowerShell contracts.
- `tests/`: repository, shared-library, and stack assertions.
- `.github/workflows/quality.yml`: automated quality gates.
- `SECURITY.md`: disclosure and key-rotation guidance.

### Task 1: Remove audited invalid local drift

**Files:**
- Restore: `Kubernetes/Microk8s/README.md`
- Restore: `Kubernetes/Microk8s/metallb/install.yml`
- Restore: `Kubernetes/Microk8s/traefik/crd.yml`
- Remove untracked: six root-level `swarm/http/*.sh` and `swarm/https/*.sh` duplicates listed in the design audit

**Interfaces:**
- Consumes: the audited dirty worktree.
- Produces: a worktree containing only feature-owned changes.

- [ ] **Step 1: Record current drift**

Run:

```bash
git status --short
git diff -- Kubernetes/Microk8s
```

Expected: three modified MicroK8s files and six untracked Swarm scripts match the approved design.

- [ ] **Step 2: Restore only tracked invalid edits**

Run:

```bash
git restore -- Kubernetes/Microk8s/README.md Kubernetes/Microk8s/metallb/install.yml Kubernetes/Microk8s/traefik/crd.yml
```

Expected: the three modified entries disappear and no other path changes.

- [ ] **Step 3: Remove only audited untracked duplicates**

Delete these exact paths with platform-native literal-path removal:

```text
swarm/http/initCluster.sh
swarm/http/startCluster.sh
swarm/http/stopCluster.sh
swarm/https/initCluster.sh
swarm/https/startCluster.sh
swarm/https/stopCluster.sh
```

Do not use a glob and do not remove files below either `unix/` directory.

- [ ] **Step 4: Verify the cleanup boundary**

Run: `git status --short`

Expected: none of the nine audited legacy drift entries remain.

- [ ] **Step 5: Commit this plan separately**

```bash
git add docs/superpowers/plans/2026-07-18-secure-foundation.md
git commit -m "docs(plan): add secure foundation implementation plan"
```

### Task 2: Establish repository hygiene and secret boundaries

**Files:**
- Modify: `.gitignore`
- Create: `.gitattributes`
- Create: `.editorconfig`
- Create: `.env.example`
- Remove from tracking: `swarm/https/letsencrypt/acme.json`
- Create: `SECURITY.md`
- Test: `tests/repository/no-secrets.sh`

**Interfaces:**
- Produces variables `EASY_DEVOPS_MODE`, `EASY_DEVOPS_DOMAIN`, `EASY_DEVOPS_ACME_EMAIL`, `TRAEFIK_IMAGE`, `PORTAINER_IMAGE`, and `PORTAINER_AGENT_IMAGE`.

- [ ] **Step 1: Write the failing tracked-secret test**

Create `tests/repository/no-secrets.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

forbidden='(^|/)(acme\.json|\.env|.*\.pem|.*\.key)$'
tracked="$(git ls-files)"
if grep -E "$forbidden" <<<"$tracked"; then
  echo "Generated secrets or runtime configuration are tracked" >&2
  exit 1
fi
```

- [ ] **Step 2: Verify the test fails**

Run: `bash tests/repository/no-secrets.sh`

Expected: FAIL and list `swarm/https/letsencrypt/acme.json`.

- [ ] **Step 3: Define ignore and formatting policy**

Set `.gitignore` to:

```gitignore
.env
.env.*
!.env.example
runtime/
logs/
backups/
coverage/
TestResults/
*.pem
*.key
acme.json
.idea/
.vscode/
```

Set `.gitattributes` to:

```gitattributes
* text=auto
*.sh text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.md text eol=lf
*.ps1 text eol=crlf
*.psm1 text eol=crlf
*.bat text eol=crlf
```

Set `.editorconfig` to:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 2
trim_trailing_whitespace = true

[*.{ps1,psm1,bat}]
end_of_line = crlf

[*.md]
trim_trailing_whitespace = false
```

- [ ] **Step 4: Define public configuration**

Create `.env.example`:

```dotenv
EASY_DEVOPS_MODE=local
EASY_DEVOPS_DOMAIN=portainer.localhost
EASY_DEVOPS_ACME_EMAIL=
TRAEFIK_IMAGE=traefik:v3.7
PORTAINER_IMAGE=portainer/portainer-ce:lts
PORTAINER_AGENT_IMAGE=portainer/agent:lts
```

- [ ] **Step 5: Remove current ACME material safely**

Run `git rm --cached swarm/https/letsencrypt/acme.json`, then delete the working copy by exact literal path without printing it. Write `SECURITY.md` stating that the historical ACME account key requires rotation and that history cleanup is a separate maintainer operation because it rewrites published history.

- [ ] **Step 6: Verify security boundaries**

Run:

```bash
bash tests/repository/no-secrets.sh
git diff --check
```

Expected: PASS with no output.

- [ ] **Step 7: Commit**

```bash
git add .gitignore .gitattributes .editorconfig .env.example SECURITY.md tests/repository/no-secrets.sh
git add -u swarm/https/letsencrypt/acme.json
git commit -m "fix(security): remove tracked runtime secrets"
```

### Task 3: Add test-first Bash contracts

**Files:**
- Create: `lib/shell/common.sh`
- Create: `tests/shell/common.bats`

**Interfaces:**
- Produces: `log_info(message)`, `log_success(message)`, `log_error(message)`, `command_exists(name)`, `require_command(name)`, `redact(value)`, and `die(code, message)`.

- [ ] **Step 1: Write failing Bats tests**

Create tests containing:

```bash
@test "command_exists returns success for bash" {
  run command_exists bash
  [ "$status" -eq 0 ]
}

@test "redact hides non-empty values" {
  run redact "private-value"
  [ "$status" -eq 0 ]
  [ "$output" = "[REDACTED]" ]
}

@test "require_command fails with stable code" {
  run require_command easy-devops-command-that-does-not-exist
  [ "$status" -eq 10 ]
  [[ "$output" == *"E10"* ]]
}
```

The test file must source `lib/shell/common.sh` from `setup_file`.

- [ ] **Step 2: Verify tests fail**

Run: `bats tests/shell/common.bats`

Expected: FAIL because the library does not exist.

- [ ] **Step 3: Implement minimal contracts**

Create `lib/shell/common.sh` with `set -o pipefail`, terminal-only ANSI colors, stable `E<code>` messages, `command -v` detection, and `[REDACTED]` for non-empty values. Functions return status codes; top-level installers decide when to exit.

- [ ] **Step 4: Test and lint**

```bash
bats tests/shell/common.bats
shellcheck lib/shell/common.sh tests/repository/no-secrets.sh
```

Expected: all PASS and no ShellCheck findings.

- [ ] **Step 5: Commit**

```bash
git add lib/shell/common.sh tests/shell/common.bats
git commit -m "feat(core): add shared shell contracts"
```

### Task 4: Add test-first PowerShell contracts

**Files:**
- Create: `lib/powershell/Common.psm1`
- Create: `tests/powershell/Common.Tests.ps1`

**Interfaces:**
- Produces: `Write-StepInfo`, `Write-StepSuccess`, `Write-StepError`, `Test-CommandAvailable`, `Assert-CommandAvailable`, `Protect-LogValue`, and `New-EasyDevOpsError`.

- [ ] **Step 1: Write failing Pester tests**

```powershell
BeforeAll {
    Import-Module "$PSScriptRoot/../../lib/powershell/Common.psm1" -Force
}

Describe 'Common contracts' {
    It 'detects an available command' {
        Test-CommandAvailable -Name 'powershell' | Should -BeTrue
    }

    It 'redacts non-empty values' {
        Protect-LogValue -Value 'private-value' | Should -Be '[REDACTED]'
    }

    It 'creates stable errors' {
        $record = New-EasyDevOpsError -Code 10 -Message 'Missing command'
        $record.Exception.Message | Should -Be 'E10: Missing command'
    }
}
```

- [ ] **Step 2: Verify tests fail**

Run: `Invoke-Pester tests/powershell/Common.Tests.ps1 -Output Detailed`

Expected: FAIL because the module does not exist.

- [ ] **Step 3: Implement exact exports**

Use strict mode, `Get-Command -ErrorAction SilentlyContinue`, `[REDACTED]` for non-empty inputs, and `ErrorRecord` IDs `EasyDevOps.E<code>`. Export only the seven public functions.

- [ ] **Step 4: Test and analyze**

```powershell
Invoke-Pester tests/powershell/Common.Tests.ps1 -Output Detailed
Invoke-ScriptAnalyzer lib/powershell/Common.psm1 -Recurse
```

Expected: Pester PASS and no analyzer findings.

- [ ] **Step 5: Commit**

```bash
git add lib/powershell/Common.psm1 tests/powershell/Common.Tests.ps1
git commit -m "feat(core): add shared powershell contracts"
```

### Task 5: Create deterministic local Swarm stacks

**Files:**
- Create: `stacks/local/traefik.yml`
- Create: `stacks/local/portainer.yml`
- Create: `tests/stacks/assert-local.ps1`

**Interfaces:**
- Consumes image variables and `EASY_DEVOPS_DOMAIN`.
- Produces external overlay network `easy-devops-proxy` and local HTTP routing.

- [ ] **Step 1: Write failing assertions**

The PowerShell test must parse both YAML files and reject missing manager placement, labels outside `deploy`, a load-balancer port other than 9000, floating `latest`, published 8080, or `api.insecure=true`.

- [ ] **Step 2: Verify failure**

Run: `pwsh tests/stacks/assert-local.ps1`

Expected: FAIL because manifests do not exist.

- [ ] **Step 3: Implement local manifests**

Use Compose v3. Traefik consumes `${TRAEFIK_IMAGE}`, enables the Swarm provider, disables exposure by default, joins `easy-devops-proxy`, publishes port 80, mounts Docker socket read-only, and runs on managers. Portainer Agent uses `${PORTAINER_AGENT_IMAGE}` globally on Linux. Portainer Server uses `${PORTAINER_IMAGE}`, volume `portainer-data`, manager placement, and `deploy.labels` routing `${EASY_DEVOPS_DOMAIN}` to port 9000.

- [ ] **Step 4: Render and test**

```bash
docker stack config -c stacks/local/traefik.yml
docker stack config -c stacks/local/portainer.yml
pwsh tests/stacks/assert-local.ps1
```

Expected: both render and assertions PASS with fixture environment loaded.

- [ ] **Step 5: Commit**

```bash
git add stacks/local tests/stacks/assert-local.ps1
git commit -m "feat(stack): add secure local swarm manifests"
```

### Task 6: Create deterministic server Swarm stacks

**Files:**
- Create: `stacks/server/traefik.yml`
- Create: `stacks/server/portainer.yml`
- Create: `tests/stacks/assert-server.ps1`

**Interfaces:**
- Consumes local variables plus `EASY_DEVOPS_ACME_EMAIL`.
- Produces HTTP-to-HTTPS redirection and ACME resolver `letsencrypt`.

- [ ] **Step 1: Write failing security assertions**

Reject server manifests unless they publish only 80/443, redirect HTTP to HTTPS, use ACME HTTP challenge, place labels under `deploy`, route through `websecure`, use resolver `letsencrypt`, omit 9000/9443/8080, and constrain manager services.

- [ ] **Step 2: Verify failure**

Run: `pwsh tests/stacks/assert-server.ps1`

Expected: FAIL because manifests do not exist.

- [ ] **Step 3: Implement server manifests**

Use the local service/network contracts. Configure `web` on 80, `websecure` on 443, permanent redirection, ACME email from the environment, HTTP challenge on `web`, and storage at `/letsencrypt/acme.json`. Portainer publishes no host ports and routes only through TLS.

- [ ] **Step 4: Render and test**

Use `portainer.example.test` and `admin@example.test` fixture values, render both manifests with `docker stack config`, and run the server assertion script.

Expected: renders and assertions PASS.

- [ ] **Step 5: Commit**

```bash
git add stacks/server tests/stacks/assert-server.ps1
git commit -m "feat(stack): add secure server swarm manifests"
```

### Task 7: Add continuous quality gates

**Files:**
- Create: `.github/workflows/quality.yml`
- Create: `.yamllint.yml`
- Create: `.markdownlint.json`

**Interfaces:**
- Consumes all tests and linters from Tasks 2-6.
- Produces required GitHub Actions job `quality`.

- [ ] **Step 1: Create the workflow**

Grant `contents: read` only. Check out full history and run Gitleaks, ShellCheck, Bats, Pester, PSScriptAnalyzer, yamllint, markdownlint, repository secret tests, stack assertions, and `git diff --check`. Pin actions to maintained major releases.

- [ ] **Step 2: Validate locally**

```bash
yamllint .github/workflows/quality.yml stacks .yamllint.yml
markdownlint-cli2 "**/*.md"
```

Expected: no findings.

- [ ] **Step 3: Run the complete local suite**

Run every workflow command against the checkout. Missing tools are reported as prerequisites and installed according to official documentation; checks are not silently skipped.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/quality.yml .yamllint.yml .markdownlint.json
git commit -m "ci(quality): enforce repository validation"
```

### Task 8: Remove superseded runtime and close the phase

**Files:**
- Remove: `Kubernetes/`
- Remove: `swarm/`
- Modify: `README.md`

**Interfaces:**
- Consumes tested local/server replacements.
- Produces a single unambiguous runtime baseline for later installers.

- [ ] **Step 1: Prove replacements pass**

Run repository secret tests, local/server assertions and rendering, Bash tests, and PowerShell tests.

Expected: all PASS before legacy removal.

- [ ] **Step 2: Remove exact legacy directories**

Remove `Kubernetes/` and `swarm/` only. Confirm their contents remain recoverable from commits before `feature/easy-installers`. Do not rewrite history here.

- [ ] **Step 3: Update transition README**

Remove broken legacy links and direct feature-branch readers to the approved design. State that guided installers are under development; do not claim completion.

- [ ] **Step 4: Validate final diff**

Run the complete quality suite plus `git status --short` and `git diff --check`.

Expected: only intended legacy removals and README transition are pending, and all checks PASS.

- [ ] **Step 5: Commit**

```bash
git add -A Kubernetes swarm README.md
git commit -m "refactor(repo): remove superseded legacy deployments"
```

- [ ] **Step 6: Review phase completion**

Verify `git log --oneline main..HEAD` contains focused English commits, the worktree is clean, commit metadata contains neither Codex nor co-author attribution, and all foundation success criteria from the design are satisfied.

Expected: the secure foundation is independently reviewable and ready for the Ubuntu local implementation plan.


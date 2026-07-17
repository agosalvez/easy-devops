# Easy DevOps v1.0 Design

## Purpose

Easy DevOps will be a professional, beginner-friendly, bilingual repository that teaches a user starting with no tooling how to deploy a single-node Docker Swarm managed through Portainer and routed through Traefik. The project must support three explicit journeys: Windows local, Ubuntu local, and Ubuntu Server. A user should be able to follow a guided installer without hiding the commands or system changes being made.

The repository is intended both as a useful open-source tutorial and as a public engineering portfolio. Its documentation, security posture, Git history, tests, and maintenance workflows must therefore demonstrate senior-level judgment.

## Success Criteria

- A beginner can select the correct journey within one minute of opening the README.
- Each supported journey begins with one documented bootstrap command.
- Installers explain planned changes, request confirmation, display progress, and provide actionable failures.
- Re-running an installer is safe and does not corrupt an existing deployment.
- A successful run ends with a verified Portainer URL and operational commands.
- The server journey enables HTTPS without committing ACME data or private keys.
- CI validates scripts, YAML, Markdown, secrets, and stack configuration.
- Windows 11, Ubuntu 22.04, and Ubuntu 24.04 behavior is explicitly tested and documented.
- The final release is merged into `main` and tagged `v1.0.0` only after all release checks pass.

## Scope

### Supported in v1.0

- Windows 11 with WSL2 and Docker Desktop using Linux containers.
- Ubuntu Desktop 22.04 and 24.04 for local use.
- Ubuntu Server 22.04 and 24.04 for a public server.
- A single manager node initialized as a Docker Swarm.
- Traefik as the ingress proxy.
- Portainer Community Edition as the management UI.
- Local HTTP access for development journeys.
- Public HTTPS access with DNS and Let's Encrypt for the server journey.
- Guided install, status, start, stop, update, backup, and uninstall operations.
- English primary documentation and a complete Spanish translation.

### Explicitly deferred

- Windows containers and Windows Server.
- macOS.
- Linux distributions other than the supported Ubuntu releases.
- Automated multi-manager or production high-availability clusters.
- Kubernetes and MicroK8s.
- Cloud-provider-specific provisioning.
- Automatic DNS provider integration.
- A graphical installer.

The documentation may explain how to add Swarm workers as an advanced follow-up, but this is not part of the v1.0 automated path.

## User Journeys

### Windows local

The PowerShell bootstrap checks the Windows version, administrator access, virtualization, WSL2, Git, and Docker Desktop. It shows every required change and asks for confirmation. If WSL2 activation requires a reboot, it records only non-sensitive continuation state and prints the exact resume command. After Docker Desktop is available and running with Linux containers, it initializes a single-node Swarm, deploys the local stack, validates services, and opens or prints the local Portainer URL.

The installer must not silently accept third-party licenses. Docker Desktop installation and its license implications must be explained before confirmation.

### Ubuntu local

The Bash bootstrap verifies the supported Ubuntu release and sudo access, then installs Docker Engine and required plugins from Docker's official apt repository. It initializes a single-node Swarm, deploys the local stack, configures the documented local hostname strategy, validates the deployment, and prints the URL.

### Ubuntu Server

The Bash bootstrap performs the same system checks and Docker installation, then requests a fully qualified domain name and ACME contact email. It checks that the domain resolves to the server's public address and verifies required port availability before deployment. It documents firewall requirements and only makes firewall changes after explicit confirmation. It deploys the secure server stack, waits for certificate issuance, validates HTTPS, and prints the final URL and maintenance commands.

## Repository Architecture

```text
easy-devops/
|-- README.md
|-- README.es.md
|-- LICENSE
|-- CHANGELOG.md
|-- CONTRIBUTING.md
|-- SECURITY.md
|-- .env.example
|-- installers/
|   |-- windows-local.ps1
|   |-- linux-local.sh
|   `-- linux-server.sh
|-- lib/
|   |-- powershell/
|   `-- shell/
|-- stacks/
|   |-- local/
|   |   |-- traefik.yml
|   |   `-- portainer.yml
|   `-- server/
|       |-- traefik.yml
|       `-- portainer.yml
|-- scripts/
|   |-- windows/
|   `-- linux/
|-- docs/
|   |-- windows-local.md
|   |-- linux-local.md
|   |-- linux-server.md
|   |-- architecture.md
|   |-- security.md
|   `-- troubleshooting.md
|-- tests/
|   |-- powershell/
|   |-- shell/
|   `-- fixtures/
`-- .github/
    |-- workflows/
    |-- ISSUE_TEMPLATE/
    `-- pull_request_template.md
```

Installers contain only journey orchestration. Reusable checks, logging, prompts, state inspection, and Docker operations live in focused library functions. Stack manifests contain runtime declarations and no generated credentials. Maintenance commands use the same shared functions as installers.

## Configuration and Data Flow

`.env.example` documents non-secret configuration. An installer creates a user-specific `.env` that Git ignores. Domain and ACME email are validated before use. Values are passed to stack rendering or deployment through a documented, deterministic interface; scripts must not rewrite tracked templates in place.

Runtime data, Portainer state, backups, logs, continuation state, and ACME storage are outside tracked source files. Logs redact secrets and record timestamps, step names, commands where safe, results, and error codes.

The normal flow is:

1. Detect journey and environment.
2. Validate compatibility and privileges.
3. Build and display an execution summary.
4. Obtain explicit confirmation.
5. Install missing prerequisites from official sources.
6. Initialize or validate Swarm state.
7. Generate untracked runtime configuration.
8. Deploy the appropriate stack.
9. Wait for services and health checks.
10. Validate the end-user URL.
11. Print next steps and log location.

## Installer Behavior

All installers must be idempotent. A second run detects completed work and either skips it or performs a safe reconciliation. Existing non-Easy-DevOps Swarms are never adopted or modified without a clear warning and explicit confirmation.

Each step uses a stable identifier and produces one of: pending, running, skipped, succeeded, failed, or action required. A failure includes a concise explanation, likely cause, remediation command or documentation link, and log location. Partial success must never be reported as a completed installation.

Destructive operations require a separate confirmation. Uninstall removes services and project-created networks by default but retains named volumes and backups. Deleting persistent data requires an explicit purge flag and interactive confirmation.

## Runtime and Security Design

- Use supported, explicitly pinned Traefik and matching Portainer Server/Agent release lines.
- Place Swarm routing labels under `deploy.labels`.
- Constrain Traefik and Portainer Server to manager nodes where required.
- Use the dedicated Traefik Swarm provider configuration supported by the selected Traefik release.
- Do not expose the insecure Traefik dashboard on a public port.
- Do not expose Portainer HTTP port 9000 in the server journey.
- Route server access through HTTPS and publish only required ports.
- Store ACME data in an untracked runtime location with restrictive permissions.
- Never commit credentials, certificates, private keys, generated `.env` files, logs, or backups.
- Keep the Docker socket read-only where possible and document its security implications.
- Ensure Portainer Server and Agent versions match.
- Document Swarm inter-node ports separately from public ingress ports.
- Use secure defaults; insecure laboratory exceptions must be explicit and local-only.

The currently tracked `swarm/https/letsencrypt/acme.json` contains an ACME account private key. It must be removed from current tracking and repository history, ignored going forward, and treated as compromised if the repository has ever been public. Rotation is a required owner action and must be documented without exposing the key.

## Maintenance Commands

Each platform provides equivalent user-facing operations:

- `status`: show Swarm, services, replicas, routes, and URL checks.
- `start`: reconcile the declared stacks.
- `stop`: remove running stacks while preserving persistent data.
- `update`: back up Portainer, pull approved versions, deploy, and verify.
- `backup`: create a timestamped, documented Portainer data backup.
- `uninstall`: remove project runtime resources conservatively.

Commands must display their actions and return non-zero exit codes on failure. Updating never uses an unconstrained floating `latest` tag.

## Documentation Design

`README.md` is the English portfolio landing page and quick-start router. `README.es.md` is a complete Spanish equivalent. Both link to each other above the introduction.

The landing page includes a concise value proposition, useful status badges, supported-platform table, result preview, journey selector, architecture overview, quick start, security summary, operational commands, contribution entry point, license, author, LinkedIn, and GitHub contact links.

Detailed procedures live in focused documents rather than making the landing page unscannable. Each journey guide contains prerequisites, estimated time, exact commands, expected output, validation checkpoints, rollback guidance, common failures, and next steps. Documentation distinguishes verified behavior from best-effort or unsupported environments.

The contact section remains professional and restrained. It demonstrates ownership and provides ways to contact the author without weakening the technical focus.

## Testing and CI

CI will include:

- ShellCheck for Bash.
- PSScriptAnalyzer and Pester for PowerShell.
- YAML and Markdown linting.
- Secret scanning.
- Stack manifest rendering and configuration validation.
- Unit tests for detection, validation, prompting, redaction, idempotency decisions, and error handling.
- Link checking for maintained documentation.
- Tests ensuring tracked files do not contain generated runtime data.

Release acceptance requires a documented clean-machine test for Windows 11, Ubuntu local, and Ubuntu Server. Tests record platform version, commands, expected outcome, actual outcome, and known limitations. Unsupported environments are not represented as verified.

## Existing Worktree Disposition

The current `main` worktree contains user changes that are not part of a coherent final implementation:

- Case-only edits in legacy MicroK8s manifests alter case-sensitive Kubernetes fields and make them invalid. These changes will not be retained.
- New root-level Swarm shell scripts duplicate scripts already present below platform directories. They will not be carried into the new architecture.
- The legacy MicroK8s area is outside v1.0 scope. It will be removed from the final repository after its history remains recoverable through Git.
- Legacy Swarm files will be replaced only after the new stacks and journeys cover their required behavior.

Before cleanup, the exact pre-existing state must be made recoverable without attributing it to the new feature history. No destructive Git reset will be used. Cleanup changes will be explicit and reviewable.

## Git and Release Workflow

- `main` remains the stable public branch.
- Implementation occurs on `feature/easy-installers`.
- Commits are small, in English, and use Conventional Commit-style messages compatible with a simplified GitFlow workflow.
- Commit authorship uses the owner's configured Git identity.
- Commits contain no Codex signature, `Co-authored-by`, generated attribution, or mention of AI tooling.
- The feature is merged only after CI, manual journey tests, documentation review, and security checks pass.
- The first completed release is tagged `v1.0.0` and documented in `CHANGELOG.md`.

Representative commit subjects include:

- `chore(repo): establish project quality baseline`
- `feat(installer): add guided Ubuntu local setup`
- `feat(server): deploy Portainer behind secure Traefik ingress`
- `test(installer): cover idempotent swarm initialization`
- `docs(readme): add bilingual quick-start journeys`

## Delivery Roadmap

1. Preserve and audit the current worktree; remediate the tracked ACME secret.
2. Establish the feature branch and repository quality baseline.
3. Implement shared configuration, stacks, libraries, and maintenance contracts.
4. Deliver and validate Ubuntu local.
5. Deliver and validate Windows local.
6. Deliver and validate Ubuntu Server with DNS and HTTPS.
7. Complete bilingual documentation and portfolio presentation.
8. Run security, CI, and clean-machine acceptance checks.
9. Review and merge into `main`; tag `v1.0.0`.

Each phase must leave the branch internally consistent and must pass its relevant automated checks before the next phase begins.

## Owner Decisions and Constraints

- Optimize for a beginner who starts with no required tooling.
- Installation must be automatic but transparent.
- Support three explicit journeys rather than requiring users to infer server changes.
- Favor tested compatibility over broad unsupported claims.
- Produce a senior-quality public repository suitable for review by prospective employers or clients.
- Preserve final deliverables on `main`, while using a feature branch during development.
- Do not attribute commits to Codex or mention Codex in commit metadata.

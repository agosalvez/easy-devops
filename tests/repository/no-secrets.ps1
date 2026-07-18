$ErrorActionPreference = 'Stop'
$tracked = git ls-files
$forbidden = '(^|/)(acme\.json|\.env|.*\.pem|.*\.key)$'
$matches = @($tracked | Where-Object { $_ -match $forbidden })
if ($matches.Count -gt 0) {
    throw "Generated secrets or runtime configuration are tracked: $($matches -join ', ')"
}


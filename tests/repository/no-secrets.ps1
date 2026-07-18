$ErrorActionPreference = 'Stop'
$repository = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$safeRepository = $repository.Replace('\', '/')
$tracked = git -c "safe.directory=$safeRepository" -C $repository ls-files
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to inspect tracked files.'
}
$forbidden = '(^|/)(acme\.json|\.env|.*\.pem|.*\.key)$'
$matches = @($tracked | Where-Object { $_ -match $forbidden })
if ($matches.Count -gt 0) {
    throw "Generated secrets or runtime configuration are tracked: $($matches -join ', ')"
}

Set-StrictMode -Version Latest

function Write-StepInfo { param([string]$Message) Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-StepSuccess { param([string]$Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-StepError { param([string]$Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }
function Test-CommandAvailable { param([string]$Name) return [bool](Get-Command $Name -ErrorAction SilentlyContinue) }
function New-EasyDevOpsError {
    param([int]$Code, [string]$Message)
    $exception = [InvalidOperationException]::new("E${Code}: $Message")
    return [Management.Automation.ErrorRecord]::new($exception, "EasyDevOps.E$Code", 'NotSpecified', $null)
}
function Assert-CommandAvailable {
    param([string]$Name)
    if (-not (Test-CommandAvailable $Name)) { throw (New-EasyDevOpsError 10 "Required command not found: $Name") }
}
function Protect-LogValue { param([string]$Value) if ($Value) { '[REDACTED]' } else { '' } }
Export-ModuleMember -Function Write-StepInfo,Write-StepSuccess,Write-StepError,Test-CommandAvailable,Assert-CommandAvailable,Protect-LogValue,New-EasyDevOpsError


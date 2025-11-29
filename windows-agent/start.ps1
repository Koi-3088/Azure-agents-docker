param (
    [string]$AZP_URL = $env:AZP_URL,
    [string]$AZP_TOKEN = $env:AZP_TOKEN,
    [string]$AZP_POOL = $env:AZP_POOL,
    [string]$AZP_AGENT_NAME = $env:AZP_AGENT_NAME
)

if (-not $AZP_URL -or -not $AZP_TOKEN) {
    Write-Host "AZP_URL and AZP_TOKEN must be set."; exit 1
}

if (-not $AZP_POOL) { $AZP_POOL = "self-hosted" }
if (-not $AZP_AGENT_NAME) { $AZP_AGENT_NAME = $env:COMPUTERNAME }

cd C:\azp

if (-not (Test-Path ".agent")) {
    .\config.cmd --unattended `
        --url $AZP_URL `
        --auth pat `
        --token $AZP_TOKEN `
        --pool $AZP_POOL `
        --agent $AZP_AGENT_NAME `
        --replace `
        --acceptTeeEula
}

try {
    .\run.cmd
}
finally {
    Write-Host "Removing agent registration..."
    .\config.cmd remove --unattended --auth pat --token $AZP_TOKEN
}

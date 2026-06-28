# One-time setup for Ymca Member App GitHub Actions deploy secrets.
# Prerequisites: GitHub CLI installed and authenticated (`gh auth login`).
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts/setup-github-secrets.ps1

$ErrorActionPreference = "Stop"

$gh = "C:\Program Files\GitHub CLI\gh.exe"
if (-not (Test-Path $gh)) {
    throw "GitHub CLI not found. Install from https://cli.github.com/ then run: gh auth login"
}

& $gh auth status | Out-Null

$keyPath = Join-Path $env:USERPROFILE ".memapp-deploy\github_actions_deploy"
if (-not (Test-Path $keyPath)) {
    throw "Deploy key not found at $keyPath. Re-run CI/CD setup or regenerate the key."
}

$repos = @("memapp-web", "memapp-backend", "memappcaddy")
$owner = "frederickohe"
$deployHost = "62.171.136.252"
$deployUser = "deploy"

foreach ($repo in $repos) {
    $fullName = "$owner/$repo"
    Write-Host "Setting secrets on $fullName (repo + production environment) ..."
    & $gh secret set DEPLOY_HOST --repo $fullName --body $deployHost
    & $gh secret set DEPLOY_USER --repo $fullName --body $deployUser
    Get-Content -Raw $keyPath | & $gh secret set DEPLOY_SSH_KEY --repo $fullName

    & $gh secret set DEPLOY_HOST --repo $fullName --env production --body $deployHost
    & $gh secret set DEPLOY_USER --repo $fullName --env production --body $deployUser
    Get-Content -Raw $keyPath | & $gh secret set DEPLOY_SSH_KEY --repo $fullName --env production
}

Write-Host "Done. Re-run failed workflows from GitHub Actions or push a commit to trigger deploy."

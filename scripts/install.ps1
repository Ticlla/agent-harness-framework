<#
.SYNOPSIS
  install.ps1 — install / uninstall / inspect Agent Harness Framework skills (Windows / PowerShell).

.DESCRIPTION
  Default action: copy the framework skills into $env:USERPROFILE\.claude\skills (self-contained;
  the repo can be moved or deleted afterwards and the skills keep working). The default set is the
  five meta-skills plus `prompt-engineering` (a vendored advisory skill).

  PowerShell mirror of scripts/install.sh. Run on Windows PowerShell 5.1+ or PowerShell 7+.

.EXAMPLE
  # copy all into %USERPROFILE%\.claude\skills
  ./scripts/install.ps1 install

.EXAMPLE
  # copy all into %USERPROFILE%\.cursor\skills
  ./scripts/install.ps1 install -Target cursor

.EXAMPLE
  # symlink skills to this repo instead of copying (tracks git pull live; repo must stay in place)
  ./scripts/install.ps1 install -Link
  # NOTE: symlinks on Windows may require Administrator rights or Developer Mode enabled.

.EXAMPLE
  # subset only
  ./scripts/install.ps1 install -Skills designer,validator

.EXAMPLE
  ./scripts/install.ps1 uninstall -Yes
  ./scripts/install.ps1 status
#>

[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [ValidateSet('install', 'uninstall', 'status')]
  [string]$Action = 'install',

  # claude = %USERPROFILE%\.claude\skills, cursor = %USERPROFILE%\.cursor\skills,
  # gemini = %USERPROFILE%\.gemini\skills, or any path.
  [string]$Target = 'claude',

  # Symlink skills to this repo instead of copying them.
  [switch]$Link,

  # Comma-separated subset. Default: designer,implementer,validator,enhancer,skill-creator,prompt-engineering
  [string]$Skills,

  # Skip confirmation prompts (uninstall).
  [switch]$Yes
)

$ErrorActionPreference = 'Stop'

$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$DefaultSkills = 'designer,implementer,validator,enhancer,skill-creator,prompt-engineering'

# --- helpers ----------------------------------------------------------------

function Write-Info($m) { Write-Host "• $m" }
function Write-Ok($m)   { Write-Host "✓ $m" -ForegroundColor Green }
function Write-Warn($m) { Write-Host "! $m" -ForegroundColor Yellow }
function Write-Err($m)  { Write-Host "✗ $m" -ForegroundColor Red }

function Resolve-TargetPath($t) {
  switch ($t) {
    'claude' { Join-Path $env:USERPROFILE '.claude\skills' }
    'cursor' { Join-Path $env:USERPROFILE '.cursor\skills' }
    'gemini' { Join-Path $env:USERPROFILE '.gemini\skills' }
    default  { $t }
  }
}

# Returns 'link' | 'copy' | 'foreign' | 'missing'
function Get-SkillClass($target, $skill) {
  $p = Join-Path $target $skill
  if (Test-Path $p) {
    $item = Get-Item $p -Force
    if ($item.LinkType -eq 'SymbolicLink') {
      $real = (Resolve-Path $item.Target -ErrorAction SilentlyContinue).Path
      if ($real -and ($real -eq $Repo -or $real.StartsWith("$Repo$([IO.Path]::DirectorySeparatorChar)"))) {
        return 'link'
      }
    }
    $sentinel = Join-Path $p '.ahf-installed'
    if ((Test-Path $p -PathType Container) -and (Test-Path $sentinel)) {
      return 'copy'
    }
    return 'foreign'
  }
  return 'missing'
}

function Confirm-Action($msg) {
  if ($Yes) { return $true }
  $reply = Read-Host "$msg [y/N]"
  return ($reply -match '^(y|yes)$')
}

# --- actions ----------------------------------------------------------------

function Invoke-Install {
  $target = Resolve-TargetPath $Target
  New-Item -ItemType Directory -Path $target -Force | Out-Null
  $method = if ($Link) { 'link' } else { 'copy' }
  Write-Info "Installing into: $target  (method: $method)"

  # Python check — informational. skill-creator scripts (init/package/quick_validate) need Python 3.
  $py = (Get-Command python -ErrorAction SilentlyContinue) ?? (Get-Command python3 -ErrorAction SilentlyContinue) ?? (Get-Command py -ErrorAction SilentlyContinue)
  if (-not $py) {
    Write-Warn "No Python 3 found on PATH: skill-creator init/package/validate scripts will fail until Python 3 is installed."
  }

  $rc = 0
  foreach ($skill in $SkillList) {
    $src = Join-Path $Repo "skills\$skill"
    $dst = Join-Path $target $skill
    $skillMd = Join-Path $src 'SKILL.md'
    if (-not (Test-Path $skillMd)) {
      Write-Warn "source skill not found, skipping: $skill (looked in $src)"
      $rc = 1; continue
    }
    if (Test-Path $dst) { Remove-Item $dst -Recurse -Force -ErrorAction SilentlyContinue }
    if ($Link) {
      try {
        New-Item -ItemType SymbolicLink -Path $dst -Target $src | Out-Null
        Write-Ok "linked  $skill"
      } catch {
        Write-Warn "could not symlink $skill (needs Administrator or Developer Mode). Falling back to copy."
        Copy-Item -Path $src -Destination $dst -Recurse -Force
        New-Item -Path (Join-Path $dst '.ahf-installed') -ItemType File -Force | Out-Null
        Write-Ok "copied  $skill (fallback)"
      }
    } else {
      Copy-Item -Path $src -Destination $dst -Recurse -Force
      New-Item -Path (Join-Path $dst '.ahf-installed') -ItemType File -Force | Out-Null
      Write-Ok "copied  $skill"
    }
  }
  Write-Host ''
  Write-Info "Done. $($SkillList.Count) skill(s) processed at $target ($method)."
  if ($Link) {
    Write-Host "  Note: -Link tracks this repo live; keep $Repo in place."
  } else {
    Write-Host "  Update later with: git pull; ./scripts/install.ps1 install -Target $Target"
  }
  if ($rc -ne 0) { exit $rc }
}

function Invoke-Uninstall {
  $target = Resolve-TargetPath $Target
  Write-Info "Target: $target"
  $toRemove = @()
  foreach ($skill in $SkillList) {
    $kind = Get-SkillClass $target $skill
    switch ($kind) {
      'missing' { Write-Host "  - $skill (not present)" -ForegroundColor DarkGray }
      'foreign' { Write-Warn "$skill exists at target but is not managed by this installer — leaving it untouched." }
      default   { $toRemove += $skill; Write-Host "  ? $skill ($kind)" -ForegroundColor Yellow }
    }
  }
  if ($toRemove.Count -eq 0) {
    Write-Ok "Nothing to remove."
    return
  }
  Write-Host ''
  if (-not (Confirm-Action "Remove the $($toRemove.Count) skill(s) above from $target?")) {
    Write-Info "Aborted (nothing changed)."; return
  }
  foreach ($skill in $toRemove) {
    Remove-Item (Join-Path $target $skill) -Recurse -Force
    Write-Ok "removed $skill"
  }
  Write-Host ''
  Write-Info "Done. $($toRemove.Count) skill(s) removed."
}

function Invoke-Status {
  $target = Resolve-TargetPath $Target
  Write-Info "Target: $target"
  foreach ($skill in $SkillList) {
    $kind = Get-SkillClass $target $skill
    switch ($kind) {
      'link'    { Write-Ok ("{0,-16} link -> {1}" -f $skill, (Join-Path $Repo "skills\$skill")) }
      'copy'    { Write-Ok ("{0,-16} copy" -f $skill) }
      'missing' { Write-Host ("  x {0,-16} not installed" -f $skill) -ForegroundColor DarkGray }
      'foreign' { Write-Warn ("{0,-16} present but not managed by this installer" -f $skill) }
    }
  }
}

# --- run --------------------------------------------------------------------

if ($Skills) {
  $SkillList = $Skills -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
} else {
  $SkillList = $DefaultSkills -split ','
}

switch ($Action) {
  'install'   { Invoke-Install }
  'uninstall' { Invoke-Uninstall }
  'status'    { Invoke-Status }
}

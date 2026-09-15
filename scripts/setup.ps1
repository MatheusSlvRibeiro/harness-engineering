#Requires -Version 5.1
<#
.SYNOPSIS
    Setup do harness-engineering em uma nova maquina (Windows).
.DESCRIPTION
    Roda uma vez por maquina. Idempotente.
      1. Valida dependencias (git, gh, python, uv).
      2. Cria junction skills/ -> ~/.claude/skills/harness/ e dir ~/.claude/skills/captured/.
      3. Instala RTK (Rust Token Killer).
      4. Instala MCP servers (mempalace + openspace) e escreve ~/.claude/mcp.json.
      5. Roda doctor.ps1 no fim.
.PARAMETER SkipMcp
    Pula instalacao dos MCP servers. Util em CI ou ambientes restritos.
.PARAMETER Force
    Recria a junction mesmo se ja existir.
#>
param(
    [switch]$SkipMcp,
    [switch]$Force
)

# Stop para cmdlets, mas precisamos tratar native commands manualmente
# (uv escreve mensagens em stderr que nao sao erros — nao redirecionamos).
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$claudeDir = Join-Path $env:USERPROFILE '.claude'
$claudeSkillsDir = Join-Path $claudeDir 'skills'
$skillsTarget = Join-Path $claudeSkillsDir 'harness'
$capturedTarget = Join-Path $claudeSkillsDir 'captured'
$repoSkills = Join-Path $repoRoot 'skills'
$openspaceWorkspace = Join-Path $env:USERPROFILE '.openspace-workspace'

Write-Host '=== Harness Engineering Setup ===' -ForegroundColor Cyan
Write-Host "Repo:   $repoRoot"
Write-Host "Target: $skillsTarget"

# --- 1. Validar dependencias ------------------------------------------------
Write-Host ''
Write-Host '[1/5] Validando dependencias...' -ForegroundColor Yellow
$missing = New-Object System.Collections.Generic.List[string]
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { $missing.Add('git') }
if (-not (Get-Command gh  -ErrorAction SilentlyContinue)) { $missing.Add('gh (GitHub CLI)') }
if (-not $SkipMcp) {
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) { $missing.Add('python 3.9+') }
    if (-not (Get-Command uv     -ErrorAction SilentlyContinue)) { $missing.Add('uv (Astral)') }
}
if ($missing.Count -gt 0) {
    Write-Host ('  Faltam: {0}' -f ($missing -join ', ')) -ForegroundColor Red
    Write-Host '  Rode .\scripts\doctor.ps1 para instrucoes de instalacao.' -ForegroundColor Yellow
    exit 1
}
Write-Host '  Tudo certo.' -ForegroundColor Green

# --- 2. Junction skills/ -> ~/.claude/skills/harness/ -----------------------
Write-Host ''
Write-Host '[2/5] Linkando skills em ~/.claude/skills/harness...' -ForegroundColor Yellow
if (-not (Test-Path $claudeDir))       { New-Item -ItemType Directory -Path $claudeDir       | Out-Null }
if (-not (Test-Path $claudeSkillsDir)) { New-Item -ItemType Directory -Path $claudeSkillsDir | Out-Null }

if (Test-Path $skillsTarget) {
    if ($Force) {
        Write-Host '  -Force: removendo junction existente.' -ForegroundColor Yellow
        cmd /c rmdir "$skillsTarget" | Out-Null
    } else {
        Write-Host "  Junction ja existe. Use -Force para recriar." -ForegroundColor Yellow
    }
}
if (-not (Test-Path $skillsTarget)) {
    cmd /c mklink /J "$skillsTarget" "$repoSkills" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host '  Falha ao criar junction.' -ForegroundColor Red
        exit 1
    }
}
Write-Host "  $skillsTarget -> $repoSkills" -ForegroundColor Green

# Diretorio para skills CAPTURED pelo OpenSpace (untracked, local da maquina).
if (-not (Test-Path $capturedTarget)) {
    New-Item -ItemType Directory -Path $capturedTarget | Out-Null
}
Write-Host "  $capturedTarget (captured skills do OpenSpace)" -ForegroundColor Green

# --- 3. RTK (Rust Token Killer) --------------------------------------------
Write-Host ''
Write-Host '[3/5] Instalando RTK...' -ForegroundColor Yellow
if (Get-Command rtk -ErrorAction SilentlyContinue) {
    $rtkVer = (& rtk --version 2>$null)
    if (-not $rtkVer) { $rtkVer = 'versao desconhecida' }
    Write-Host "  rtk ja instalado ($rtkVer)." -ForegroundColor Green
} elseif (Get-Command cargo -ErrorAction SilentlyContinue) {
    Write-Host '  Tentando cargo install --git https://github.com/rtk-ai/rtk' -ForegroundColor Cyan
    & cargo install --git https://github.com/rtk-ai/rtk
    if ($LASTEXITCODE -ne 0) {
        Write-Host '  Falha no cargo install. Baixe o binario Windows em:' -ForegroundColor Yellow
        Write-Host '    https://github.com/rtk-ai/rtk/releases (rtk-x86_64-pc-windows-msvc.zip)' -ForegroundColor Yellow
    } else {
        Write-Host '  rtk instalado via cargo.' -ForegroundColor Green
    }
} else {
    Write-Host '  cargo nao encontrado. Baixe o binario Windows em:' -ForegroundColor Yellow
    Write-Host '    https://github.com/rtk-ai/rtk/releases (rtk-x86_64-pc-windows-msvc.zip)' -ForegroundColor Yellow
    Write-Host '  Extraia e coloque rtk.exe em algum diretorio do PATH (ex.: %USERPROFILE%\.local\bin).' -ForegroundColor Yellow
    Write-Host '  Recomendado: rode o harness via WSL para ter o hook system completo.' -ForegroundColor Gray
}

# --- 4. MCP servers ---------------------------------------------------------
if (-not $SkipMcp) {
    Write-Host ''
    Write-Host '[4/5] Instalando MCP servers...' -ForegroundColor Yellow

    Write-Host '  -> mempalace' -ForegroundColor Cyan
    # NAO usar 2>&1 com uv: ele escreve mensagens informativas em stderr
    # ("Resolved N packages") que viram NativeCommandError em PS 5.1.
    # Deixamos a saida do uv aparecer naturalmente.
    & uv tool install mempalace
    if ($LASTEXITCODE -ne 0) {
        Write-Host '  Falha ao instalar mempalace. Ver: https://github.com/mempalace/mempalace' -ForegroundColor Yellow
    } else {
        Write-Host '     instalado.' -ForegroundColor Green
    }

    # Auto-save hooks (Claude Code Stop + PreCompact).
    # Os scripts sao bash; em Windows precisam de WSL/Git Bash no PATH.
    $hooksDir = Join-Path $claudeDir 'hooks\mempalace'
    if (-not (Test-Path $hooksDir)) {
        New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
    }
    $saveHook = Join-Path $hooksDir 'mempal_save_hook.sh'
    $precompactHook = Join-Path $hooksDir 'mempal_precompact_hook.sh'
    $hooksBase = 'https://raw.githubusercontent.com/MemPalace/mempalace/master/hooks'
    foreach ($h in @('mempal_save_hook.sh', 'mempal_precompact_hook.sh')) {
        $target = Join-Path $hooksDir $h
        if (-not (Test-Path $target) -or $Force) {
            try {
                Invoke-WebRequest -Uri "$hooksBase/$h" -OutFile $target -UseBasicParsing -ErrorAction Stop
                Write-Host "     hook baixado: $target" -ForegroundColor Green
            } catch {
                Write-Host "     Falha ao baixar $h. Baixe manualmente de $hooksBase/$h" -ForegroundColor Yellow
            }
        }
    }

    # Wire hooks em ~/.claude/settings.json se ainda nao estiver.
    # Aviso: os hooks sao bash; rode Claude Code sob WSL/Git Bash para os hooks executarem.
    $settingsFile = Join-Path $claudeDir 'settings.json'
    if (-not (Test-Path $settingsFile)) {
        $saveHookJson = $saveHook -replace '\\','\\\\'
        $precompactHookJson = $precompactHook -replace '\\','\\\\'
        $settingsJson = @"
{
  "hooks": {
    "Stop": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "$saveHookJson",
        "timeout": 30
      }]
    }],
    "PreCompact": [{
      "hooks": [{
        "type": "command",
        "command": "$precompactHookJson",
        "timeout": 30
      }]
    }]
  }
}
"@
        $settingsJson | Out-File -FilePath $settingsFile -Encoding utf8
        Write-Host "     auto-save wired em $settingsFile (arquivo criado)." -ForegroundColor Green
        Write-Host "     Aviso: hooks sao bash. No Windows nativo precisa de WSL/Git Bash no PATH." -ForegroundColor Gray
    } elseif (Select-String -Path $settingsFile -Pattern 'mempal_save_hook' -Quiet) {
        Write-Host "     auto-save ja configurado em $settingsFile." -ForegroundColor Green
    } else {
        Write-Host "     $settingsFile ja existe — nao vou sobrescrever." -ForegroundColor Yellow
        Write-Host "     Adicione manualmente (ou rode /update-config no Claude Code):" -ForegroundColor Yellow
        Write-Host "       Stop hook    -> $saveHook" -ForegroundColor Yellow
        Write-Host "       PreCompact   -> $precompactHook" -ForegroundColor Yellow
    }

    Write-Host '  -> openspace' -ForegroundColor Cyan
    if (Get-Command openspace-mcp -ErrorAction SilentlyContinue) {
        Write-Host '     openspace-mcp ja instalado.' -ForegroundColor Green
    } else {
        & uv tool install 'git+https://github.com/HKUDS/OpenSpace.git'
        if ($LASTEXITCODE -ne 0) {
            Write-Host '     Falha ao instalar openspace via uv. Manual:' -ForegroundColor Yellow
            Write-Host '       git clone https://github.com/HKUDS/OpenSpace.git ~/.openspace' -ForegroundColor Yellow
            Write-Host '       cd ~/.openspace; pip install -e .' -ForegroundColor Yellow
        } else {
            Write-Host '     instalado via uv tool (git+https).' -ForegroundColor Green
        }
    }

    if (-not (Test-Path $openspaceWorkspace)) {
        New-Item -ItemType Directory -Path $openspaceWorkspace | Out-Null
    }

    $mcpFile = Join-Path $claudeDir 'mcp.json'
    if (-not (Test-Path $mcpFile)) {
        $mcpJson = @"
{
  "mcpServers": {
    "mempalace": {
      "command": "mempalace",
      "args": ["mcp"]
    },
    "openspace": {
      "command": "openspace-mcp",
      "toolTimeout": 600,
      "env": {
        "OPENSPACE_HOST_SKILL_DIRS": "$($capturedTarget -replace '\\','\\\\')",
        "OPENSPACE_WORKSPACE": "$($openspaceWorkspace -replace '\\','\\\\')"
      }
    }
  }
}
"@
        $mcpJson | Out-File -FilePath $mcpFile -Encoding utf8
        Write-Host "  Criado $mcpFile (mempalace + openspace)" -ForegroundColor Green
    } else {
        Write-Host "  $mcpFile ja existe. Adicione 'mempalace' e 'openspace' manualmente se ainda nao estiver." -ForegroundColor Yellow
        Write-Host "    OPENSPACE_HOST_SKILL_DIRS=$capturedTarget" -ForegroundColor Yellow
        Write-Host "    OPENSPACE_WORKSPACE=$openspaceWorkspace" -ForegroundColor Yellow
    }
} else {
    Write-Host ''
    Write-Host '[4/5] Pulando MCPs (-SkipMcp)' -ForegroundColor Gray
}

# --- 5. Doctor final --------------------------------------------------------
Write-Host ''
Write-Host '[5/5] Verificacao final...' -ForegroundColor Yellow
& (Join-Path $PSScriptRoot 'doctor.ps1')

Write-Host ''
Write-Host 'Setup completo. Reinicie o Claude Code para carregar as skills.' -ForegroundColor Green

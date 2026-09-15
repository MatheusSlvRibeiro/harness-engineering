#!/usr/bin/env bash
# Setup do harness-engineering em uma nova máquina (Linux/macOS).
# Roda uma vez por máquina. Idempotente.
#
# Flags:
#   SKIP_MCP=1   pula instalação dos MCPs
#   FORCE=1      recria symlink mesmo se existir
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_SKILLS_DIR="$CLAUDE_DIR/skills"
SKILLS_TARGET="$CLAUDE_SKILLS_DIR/harness"
CAPTURED_TARGET="$CLAUDE_SKILLS_DIR/captured"
REPO_SKILLS="$REPO_ROOT/skills"
SKIP_MCP="${SKIP_MCP:-0}"
FORCE="${FORCE:-0}"

echo "=== Harness Engineering Setup ==="
echo "Repo:   $REPO_ROOT"
echo "Target: $SKILLS_TARGET"

# --- 1. Instalar dependências -----------------------------------------------
echo ""
echo "[1/5] Instalando dependências..."

# Detecta OS
_OS="unknown"
if [[ "$(uname)" == "Darwin" ]]; then
    _OS="mac"
elif [[ "$(uname)" == "Linux" ]]; then
    _OS="linux"
fi

# apt-get update uma vez só se precisar instalar algo
_APT_UPDATED=0
apt_install() {
    if [[ "$_APT_UPDATED" == "0" ]]; then
        sudo apt-get update -q
        _APT_UPDATED=1
    fi
    sudo apt-get install -y "$@"
}

# git
if ! command -v git >/dev/null 2>&1; then
    echo "  Instalando git..."
    if [[ "$_OS" == "mac" ]]; then brew install git
    else apt_install git; fi
else
    echo "  git $(git --version | awk '{print $3}') — ok"
fi

# jq (necessário para check-harness.sh)
if ! command -v jq >/dev/null 2>&1; then
    echo "  Instalando jq..."
    if [[ "$_OS" == "mac" ]]; then brew install jq
    else apt_install jq; fi
else
    echo "  jq $(jq --version) — ok"
fi

# gh (GitHub CLI)
if ! command -v gh >/dev/null 2>&1; then
    echo "  Instalando gh (GitHub CLI)..."
    if [[ "$_OS" == "mac" ]]; then
        brew install gh
    else
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
            | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
        _APT_UPDATED=0  # forçar re-update após novo source
        apt_install gh
    fi
else
    echo "  gh $(gh --version | head -1 | awk '{print $3}') — ok"
fi

if [[ "$SKIP_MCP" != "1" ]]; then
    # python3
    if ! command -v python3 >/dev/null 2>&1; then
        echo "  Instalando python3..."
        if [[ "$_OS" == "mac" ]]; then brew install python3
        else apt_install python3; fi
    else
        echo "  python3 $(python3 --version | awk '{print $2}') — ok"
    fi

    # uv (Astral) — instalador oficial funciona em Linux e Mac
    if ! command -v uv >/dev/null 2>&1; then
        echo "  Instalando uv (Astral)..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
    else
        echo "  uv $(uv --version | awk '{print $2}') — ok"
    fi
fi

# Verificação final: aborta só se ainda faltar algo após tentativa de instalação
_missing=()
command -v git >/dev/null 2>&1     || _missing+=("git")
command -v jq  >/dev/null 2>&1     || _missing+=("jq")
command -v gh  >/dev/null 2>&1     || _missing+=("gh")
if [[ "$SKIP_MCP" != "1" ]]; then
    command -v python3 >/dev/null 2>&1 || _missing+=("python3")
    command -v uv      >/dev/null 2>&1 || _missing+=("uv")
fi
if [[ ${#_missing[@]} -gt 0 ]]; then
    echo ""
    echo "  Ainda faltam após tentativa de instalação: ${_missing[*]}"
    echo "  Instale manualmente e rode novamente. Rode ./scripts/doctor.sh para instruções."
    exit 1
fi
echo "  Todas as dependências prontas."

# --- 2. Symlink skills/ -> ~/.claude/skills/harness/ -----------------------
echo ""
echo "[2/5] Linkando skills em ~/.claude/skills/harness..."
mkdir -p "$CLAUDE_SKILLS_DIR"
if [[ -L "$SKILLS_TARGET" || -e "$SKILLS_TARGET" ]]; then
    if [[ "$FORCE" == "1" ]]; then
        echo "  FORCE=1: removendo link existente."
        rm -rf "$SKILLS_TARGET"
    else
        echo "  Symlink já existe. Use FORCE=1 para recriar."
    fi
fi
if [[ ! -L "$SKILLS_TARGET" ]]; then
    ln -s "$REPO_SKILLS" "$SKILLS_TARGET"
fi
echo "  $SKILLS_TARGET -> $REPO_SKILLS"

# Diretório para skills CAPTURED pelo OpenSpace (untracked, local da máquina).
# Mantido separado do curated para não poluir o repo.
mkdir -p "$CAPTURED_TARGET"
echo "  $CAPTURED_TARGET (captured skills do OpenSpace)"

# --- 3. RTK (Rust Token Killer) --------------------------------------------
echo ""
echo "[3/5] Instalando RTK..."
if command -v rtk >/dev/null 2>&1; then
    echo "  rtk $(rtk --version 2>/dev/null || echo 'versão desconhecida') — ok"
elif command -v brew >/dev/null 2>&1; then
    echo "  Instalando rtk via Homebrew..."
    if brew install rtk >/dev/null 2>&1; then
        echo "  rtk instalado via Homebrew."
    else
        echo "  Brew falhou, tentando instalador upstream..."
        if curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh; then
            export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
            echo "  rtk instalado via script upstream."
        else
            echo "  Falha ao instalar rtk. Instale manualmente via cargo:"
            echo "    cargo install --git https://github.com/rtk-ai/rtk"
        fi
    fi
else
    echo "  Instalando rtk via script upstream..."
    if curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh; then
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
        echo "  rtk instalado."
    else
        echo "  Falha ao instalar rtk. Instale manualmente via cargo:"
        echo "    cargo install --git https://github.com/rtk-ai/rtk"
    fi
fi

# --- 4. MCP servers ---------------------------------------------------------
if [[ "$SKIP_MCP" != "1" ]]; then
    echo ""
    echo "[4/5] Instalando MCP servers..."

    echo "  -> mempalace"
    if uv tool install mempalace >/dev/null 2>&1; then
        echo "     instalado."
    else
        echo "  Falha ao instalar mempalace. Ver: https://github.com/mempalace/mempalace"
    fi

    # Auto-save hooks (Claude Code Stop + PreCompact).
    # Indexam transcripts automaticamente, evitando perda de contexto entre sessões.
    hooks_dir="$CLAUDE_DIR/hooks/mempalace"
    mkdir -p "$hooks_dir"
    hooks_base="https://raw.githubusercontent.com/MemPalace/mempalace/master/hooks"
    save_hook="$hooks_dir/mempal_save_hook.sh"
    precompact_hook="$hooks_dir/mempal_precompact_hook.sh"
    for h in mempal_save_hook.sh mempal_precompact_hook.sh; do
        if [[ ! -f "$hooks_dir/$h" || "$FORCE" == "1" ]]; then
            if curl -fsSL -o "$hooks_dir/$h" "$hooks_base/$h" 2>/dev/null; then
                chmod +x "$hooks_dir/$h"
                echo "     hook baixado: $hooks_dir/$h"
            else
                echo "     Falha ao baixar $h (offline?). Baixe manualmente de $hooks_base/$h"
            fi
        fi
    done

    # Wire hooks em ~/.claude/settings.json se ainda não estiver.
    settings_file="$CLAUDE_DIR/settings.json"
    if [[ ! -f "$settings_file" ]]; then
        cat > "$settings_file" <<EOF
{
  "hooks": {
    "Stop": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "$save_hook",
        "timeout": 30
      }]
    }],
    "PreCompact": [{
      "hooks": [{
        "type": "command",
        "command": "$precompact_hook",
        "timeout": 30
      }]
    }]
  }
}
EOF
        echo "     auto-save wired em $settings_file (arquivo criado)."
    elif grep -q "mempal_save_hook" "$settings_file" 2>/dev/null; then
        echo "     auto-save já configurado em $settings_file."
    else
        echo "     $settings_file já existe — não vou sobrescrever."
        echo "     Adicione manualmente (ou rode /update-config no Claude Code):"
        echo "       Stop hook    → $save_hook"
        echo "       PreCompact   → $precompact_hook"
    fi

    echo "  -> openspace"
    if command -v openspace-mcp >/dev/null 2>&1; then
        echo "     openspace-mcp já instalado."
    elif uv tool install "git+https://github.com/HKUDS/OpenSpace.git" >/dev/null 2>&1; then
        echo "     instalado via uv tool (git+https)."
    else
        echo "     Falha ao instalar openspace via uv. Manual:"
        echo "       git clone https://github.com/HKUDS/OpenSpace.git ~/.openspace"
        echo "       cd ~/.openspace && pip install -e ."
    fi

    mcp_file="$CLAUDE_DIR/mcp.json"
    if [[ ! -f "$mcp_file" ]]; then
        cat > "$mcp_file" <<EOF
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
        "OPENSPACE_HOST_SKILL_DIRS": "$CAPTURED_TARGET",
        "OPENSPACE_WORKSPACE": "$HOME/.openspace-workspace"
      }
    }
  }
}
EOF
        mkdir -p "$HOME/.openspace-workspace"
        echo "  Criado $mcp_file (mempalace + openspace)"
    else
        echo "  $mcp_file já existe. Adicione 'mempalace' e 'openspace' manualmente se ainda não tiver."
        echo "    OPENSPACE_HOST_SKILL_DIRS=$CAPTURED_TARGET"
        echo "    OPENSPACE_WORKSPACE=$HOME/.openspace-workspace"
    fi
else
    echo ""
    echo "[4/5] Pulando MCPs (SKIP_MCP=1)"
fi

# --- 5. Doctor --------------------------------------------------------------
echo ""
echo "[5/5] Verificação final..."
"$REPO_ROOT/scripts/doctor.sh"

echo ""
echo "Setup completo. Reinicie o Claude Code para carregar as skills."

#!/usr/bin/env bash
# Valida o ambiente local do harness-engineering.
# Mostra comando de instalação para cada item faltante.
set -u

any_missing=0

check_cmd() {
    local name=$1
    local cmd=$2
    local install=${3:-}
    if command -v "$cmd" >/dev/null 2>&1; then
        printf "  [OK]    %s\n" "$name"
    else
        printf "  [FALTA] %s\n" "$name"
        if [[ -n "$install" ]]; then
            printf "          %s\n" "$install"
        fi
        any_missing=1
    fi
}

echo "=== Harness Doctor ==="

echo ""
echo "Dependências base:"
check_cmd "git"             "git"     "apt install git / brew install git"
check_cmd "gh (GitHub CLI)" "gh"      "brew install gh"
check_cmd "python 3.9+"     "python3" "brew install python@3.12"
check_cmd "uv (Astral)"     "uv"      "curl -LsSf https://astral.sh/uv/install.sh | sh"
check_cmd "node"            "node"    "brew install node"

# RTK: checa via `rtk --version` para reportar versão instalada.
if command -v rtk >/dev/null 2>&1; then
    rtk_version=$(rtk --version 2>/dev/null || echo "versão desconhecida")
    printf "  [OK]    rtk (%s)\n" "$rtk_version"
else
    printf "  [FALTA] rtk (Rust Token Killer)\n"
    printf "          brew install rtk\n"
    printf "          ou: curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh\n"
    any_missing=1
fi

echo ""
echo "MCP servers:"
check_cmd "mempalace"    "mempalace"    "uv tool install mempalace"
check_cmd "openspace-mcp" "openspace-mcp" "uv tool install git+https://github.com/HKUDS/OpenSpace.git"

echo ""
echo "Skills dirs:"
if [[ -L "$HOME/.claude/skills/harness" || -d "$HOME/.claude/skills/harness" ]]; then
    echo "  [OK]    ~/.claude/skills/harness (curated)"
else
    echo "  [FALTA] symlink ~/.claude/skills/harness"
    echo "          Rode: ./scripts/setup.sh"
    any_missing=1
fi
if [[ -d "$HOME/.claude/skills/captured" ]]; then
    echo "  [OK]    ~/.claude/skills/captured (captured — OpenSpace)"
else
    echo "  [FALTA] ~/.claude/skills/captured"
    echo "          Rode: ./scripts/setup.sh (cria o diretório vazio)"
    any_missing=1
fi

echo ""
echo "Claude MCP config:"
if [[ -f "$HOME/.claude/mcp.json" ]]; then
    echo "  [OK]    ~/.claude/mcp.json"
else
    echo "  [FALTA] ~/.claude/mcp.json"
    echo "          Rode: ./scripts/setup.sh"
    any_missing=1
fi

echo ""
echo "MemPalace auto-save hooks:"
save_hook="$HOME/.claude/hooks/mempalace/mempal_save_hook.sh"
precompact_hook="$HOME/.claude/hooks/mempalace/mempal_precompact_hook.sh"
settings_file="$HOME/.claude/settings.json"
if [[ -x "$save_hook" && -x "$precompact_hook" ]]; then
    echo "  [OK]    scripts em ~/.claude/hooks/mempalace/"
else
    echo "  [FALTA] scripts de hook em ~/.claude/hooks/mempalace/"
    echo "          Rode: ./scripts/setup.sh"
    any_missing=1
fi
if [[ -f "$settings_file" ]] && grep -q "mempal_save_hook" "$settings_file" 2>/dev/null; then
    echo "  [OK]    Stop + PreCompact wired em ~/.claude/settings.json"
else
    echo "  [AVISO] hooks não estão wired em ~/.claude/settings.json"
    echo "          Sessions não vão auto-indexar no MemPalace."
    echo "          Rode: ./scripts/setup.sh (ou /update-config no Claude Code)."
fi

echo ""
if [[ "$any_missing" -eq 1 ]]; then
    echo "Doctor: itens faltando. Rode ./scripts/setup.sh para corrigir."
    exit 1
else
    echo "Doctor: tudo OK."
fi

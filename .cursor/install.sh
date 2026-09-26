#!/usr/bin/env bash
# Cloud Agent install script for the Roblox Luau (Pet Shop) project.
#
# Sets up the full toolchain and project dependencies:
#   - rokit         (toolchain manager -> stylua, selene, luau-lsp, pesde, rojo, darklua)
#   - lune / zune   (Luau runtimes used by the project scripts / CI)
#   - pesde install (project package dependencies)
#
# The script is idempotent: re-running it only refreshes what is missing.
set -euo pipefail

ROKIT_VERSION="1.2.0"
LUNE_VERSION="0.8.9"   # matches pesde.toml [engines] lune = "^0.8.9"
ZUNE_VERSION="0.5.9"

LOCAL_BIN="${HOME}/.local/bin"
ROKIT_BIN="${HOME}/.rokit/bin"
mkdir -p "${LOCAL_BIN}"

export PATH="${ROKIT_BIN}:${LOCAL_BIN}:${PATH}"

log() { printf '\n\033[1;32m[install]\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. rokit (Roblox toolchain manager)
# ---------------------------------------------------------------------------
if ! command -v rokit >/dev/null 2>&1; then
    log "Installing rokit ${ROKIT_VERSION}"
    tmp="$(mktemp -d)"
    curl -fsSL -o "${tmp}/rokit.zip" \
        "https://github.com/rojo-rbx/rokit/releases/download/v${ROKIT_VERSION}/rokit-${ROKIT_VERSION}-linux-x86_64.zip"
    unzip -oq "${tmp}/rokit.zip" -d "${tmp}"
    mkdir -p "${ROKIT_BIN}"
    install -m755 "${tmp}/rokit" "${ROKIT_BIN}/rokit"
    rm -rf "${tmp}"
    # self-install wires up tool shims and PATH in the user's shell profile.
    "${ROKIT_BIN}/rokit" self-install
else
    log "rokit already installed ($(rokit --version))"
fi

# ---------------------------------------------------------------------------
# 2. Luau runtimes: lune (pesde engine) and zune (CI script runner)
# ---------------------------------------------------------------------------
install_zip_binary() {
    # $1 = binary name, $2 = download url
    local name="$1" url="$2" tmp
    tmp="$(mktemp -d)"
    curl -fsSL -o "${tmp}/${name}.zip" "${url}"
    unzip -oq "${tmp}/${name}.zip" -d "${tmp}"
    install -m755 "${tmp}/${name}" "${LOCAL_BIN}/${name}"
    rm -rf "${tmp}"
}

if ! command -v lune >/dev/null 2>&1; then
    log "Installing lune ${LUNE_VERSION}"
    install_zip_binary lune \
        "https://github.com/lune-org/lune/releases/download/v${LUNE_VERSION}/lune-${LUNE_VERSION}-linux-x86_64.zip"
else
    log "lune already installed ($(lune --version))"
fi

if ! command -v zune >/dev/null 2>&1; then
    log "Installing zune ${ZUNE_VERSION}"
    install_zip_binary zune \
        "https://github.com/Scythe-Technology/zune/releases/download/v${ZUNE_VERSION}/zune-${ZUNE_VERSION}-linux-x86_64.zip"
else
    log "zune already installed"
fi

# ---------------------------------------------------------------------------
# 3. Project toolchain pinned in rokit.toml
#    --no-trust-check is the documented flag for non-interactive / CI machines.
# ---------------------------------------------------------------------------
log "Installing project toolchain (rokit install)"
rokit install --no-trust-check

# ---------------------------------------------------------------------------
# 4. pesde package dependencies
#    pesde reads registry tokens from ~/.pesde/config.toml and only falls back
#    to the OS keyring (Secret Service) when that file is missing. Headless VMs
#    have no Secret Service, so we seed an empty token table to skip it.
# ---------------------------------------------------------------------------
PESDE_CONFIG="${HOME}/.pesde/config.toml"
if [ ! -f "${PESDE_CONFIG}" ]; then
    log "Seeding pesde config (avoids OS keyring on headless machines)"
    mkdir -p "${HOME}/.pesde"
    printf 'default_index = "https://github.com/pesde-pkg/index"\n\n[tokens]\n' > "${PESDE_CONFIG}"
fi

log "Installing project dependencies (pesde install)"
pesde install

# ---------------------------------------------------------------------------
# 5. Generate the Rojo sourcemap (used by darklua require conversion + luau-lsp)
# ---------------------------------------------------------------------------
log "Generating sourcemap"
rojo sourcemap default.project.json -o sourcemap.json

# ---------------------------------------------------------------------------
# 6. Ensure interactive shells and tmux terminals can find the tools.
# ---------------------------------------------------------------------------
PROFILE_SNIPPET='# >>> roblox-luau toolchain (managed by .cursor/install.sh) >>>
export PATH="$HOME/.rokit/bin:$HOME/.local/bin:$PATH"
# <<< roblox-luau toolchain <<<'
if [ -w "${HOME}/.bashrc" ] || [ ! -e "${HOME}/.bashrc" ]; then
    if ! grep -q "roblox-luau toolchain" "${HOME}/.bashrc" 2>/dev/null; then
        printf '\n%s\n' "${PROFILE_SNIPPET}" >> "${HOME}/.bashrc"
    fi
fi

log "Done. Toolchain versions:"
rojo --version
darklua --version
selene --version
stylua --version
lune --version

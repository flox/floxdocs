#! /usr/bin/env bash
# ============================================================================ #
#
# Setup routines used to initialize the bash sessions.
#
# ---------------------------------------------------------------------------- #

home_setup() {
  if [[ -n "${__FT_RAN_HOME_SETUP:-}" ]]; then return 0; fi

  export REAL_HOME="$HOME";
  export HOME=$PWD

  export __FT_RAN_HOME_SETUP=:;
}

# ---------------------------------------------------------------------------- #

# Set `XDG_*_HOME' variables to temporary paths.
xdg_setup() {
  if [[ -n "${__FT_RAN_XDG_SETUP:-}" ]]; then return 0; fi

  home_setup;

  : "${XDG_CONFIG_HOME:=$REAL_HOME/.config}";
  : "${XDG_CACHE_HOME:=$REAL_HOME/.cache}";
  : "${XDG_DATA_HOME:=$REAL_HOME/.local/share}";
  export REAL_XDG_CONFIG_HOME="${XDG_CONFIG_HOME:?}";
  export REAL_XDG_CACHE_HOME="${XDG_CACHE_HOME:?}";
  export REAL_XDG_DATA_HOME="${XDG_DATA_HOME:?}";

  export XDG_CONFIG_HOME="$HOME/.config";
  mkdir -p "$XDG_CONFIG_HOME";
  chmod u+w "$XDG_CONFIG_HOME";

  export XDG_DATA_HOME="$HOME/.local/share";
  mkdir -p "$XDG_DATA_HOME";
  chmod u+w "$XDG_DATA_HOME";

  export XDG_CACHE_HOME="$HOME/.cache";
  mkdir -p "$XDG_CACHE_HOME";
  chmod u+w "$XDG_CACHE_HOME";

  export __FT_RAN_XDG_SETUP=:;
}

# ---------------------------------------------------------------------------- #

nix_setup() {
  if [[ -n "${__FT_RAN_NIX_SETUP:-}" ]]; then return 0; fi

  xdg_setup;

  # Cache Dirs

  # We symlink the cache for `nix' so that the fetcher cache and eval cache are
  # shared across the entire suite and between runs.
  # We DO NOT want to use a similar approach for `flox' caches.
  if ! [[ -e "$XDG_CACHE_HOME/nix" ]]; then
    if [[ -e "$REAL_XDG_CACHE_HOME/nix" ]]; then
      chmod u+w "$REAL_XDG_CACHE_HOME/nix";
      ln -s -- "$REAL_XDG_CACHE_HOME/nix" "$XDG_CACHE_HOME/nix";
    else
      mkdir -p "$XDG_CACHE_HOME/nix";
    fi
  fi

  mkdir -p "$XDG_CACHE_HOME/nix/eval-cache-v4";
  chmod u+w "$XDG_CACHE_HOME/nix/eval-cache-v4";

  # Config Dirs

  if [[ -e "${REAL_XDG_CONFIG_HOME:?}/nix" ]]; then
    rm -rf "$XDG_CONFIG_HOME/nix";
    cp -Tr -- "$REAL_XDG_CONFIG_HOME/nix" "$XDG_CONFIG_HOME/nix";
    chmod -R u+w "$XDG_CONFIG_HOME/nix";
  fi
  if [[ -e "$REAL_XDG_CONFIG_HOME/flox" ]]; then
    rm -rf "$XDG_CONFIG_HOME/flox";
    cp -Tr -- "$REAL_XDG_CONFIG_HOME/flox" "$XDG_CONFIG_HOME/flox";
    chmod -R u+w "$XDG_CONFIG_HOME/flox";
  fi

  export __FT_RAN_NIX_SETUP=:;
}

# ---------------------------------------------------------------------------- #

# Scrub vars recognized by `flox' CLI and set a few configurables.
flox_setup() {
  if [[ -n "${__FT_RAN_FLOX_SETUP:-}" ]]; then return 0; fi

  xdg_setup;

  mkdir -p "$XDG_DATA_HOME/flox";
  chmod u+w "$XDG_DATA_HOME/flox";
  mkdir -p "$XDG_DATA_HOME/flox/environments";
  chmod u+w "$XDG_DATA_HOME/flox/environments";

  unset FLOX_PROMPT_ENVIRONMENTS FLOX_ACTIVE_ENVIRONMENTS;
  export FLOX_DISABLE_METRICS='true';
  export FLOX_SAVE_PS1="$PS1"

  export __FT_RAN_FLOX_SETUP=:;
}

# ---------------------------------------------------------------------------- #

# Creates an ssh key and sets `SSH_AUTH_SOCK' for use by the test suite.
# It is recommended that you use this setup routine in `setup_suite'.
ssh_key_setup() {
  if [[ -n "${__FT_RAN_SSH_KEY_SETUP:-}" ]]; then return 0; fi

  : "${FLOX_TEST_SSH_KEY:=${HOME}/.ssh/id_ed25519}";
  export FLOX_TEST_SSH_KEY;

  if ! [[ -r "$FLOX_TEST_SSH_KEY" ]]; then
    mkdir -p "${FLOX_TEST_SSH_KEY%/*}";
    ssh-keygen -t ed25519 -q -N '' -f "$FLOX_TEST_SSH_KEY"  \
               -C 'floxuser@example.invalid';
    chmod 600 "$FLOX_TEST_SSH_KEY";
  fi

  export SSH_AUTH_SOCK="$HOME/.ssh/ssh_agent.sock";
  if ! [[ -d "${SSH_AUTH_SOCK%/*}" ]]; then mkdir -p "${SSH_AUTH_SOCK%/*}"; fi
  # If our socket isn't open ( it probably ain't ) we open one.
  if ! [[ -e "$SSH_AUTH_SOCK" ]]; then
    # You can't find work in this town without a good agent. Lets get one.
    eval "$( ssh-agent -s; )";
    ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_agent.sock";
    export SSH_AUTH_SOCK="$HOME/.ssh/ssh_agent.sock";
    ssh-add "$FLOX_TEST_SSH_KEY";
  fi

  unset SSH_ASKPASS;

  export __FT_RAN_SSH_KEY_SETUP=:;
}

# ---------------------------------------------------------------------------- #

# Create a temporary `gitconfig' suitable for this test suite.
git_setup() {
  if [[ -n "${__FT_RAN_GIT_SETUP:-}" ]]; then return 0; fi

  xdg_setup;

  mkdir -p "$XDG_CONFIG_HOME/git";
  export GIT_CONFIG_SYSTEM="$XDG_CONFIG_HOME/git/gitconfig.system";

  # Handle config shared across whole test suite.
  git config --system user.name  'Flox User';
  git config --system user.email 'floxuser@example.invalid';
  git config --system gpg.format ssh;

  # Create a temporary `ssh' key for use by `git'.
  ssh_key_setup;
  git config --system user.signingkey "$FLOX_TEST_SSH_KEY.pub";

  # Test files and some individual tests may override this.
  export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/gitconfig.global";
  touch "$GIT_CONFIG_GLOBAL";

  export __FT_RAN_GIT_SETUP=:;
}

# ---------------------------------------------------------------------------- #

gh_setup() {
  if [[ -n "${__FT_RAN_GH_SETUP:-}" ]]; then return 0; fi

  xdg_setup;

  export GH_CONFIG_DIR="$XDG_CONFIG_HOME/gh";
  mkdir -p "$GH_CONFIG_DIR";

  export __FT_RAN_GH_SETUP=:;
}

# ---------------------------------------------------------------------------- #

setup() {

  # TODO: how do we fail setup/teardown
  # TODO: check that HOME, SHELL is set
  # TODO: check that PS1 is "$ "
  # TODO: Check for commands that we require: git, ssh, jq, tracelinks, docker

  # https://github.com/NixOS/nix/blame/3723363697b3908a2f58dce3e706783b1c783414/src/libutil/util.cc#L1496-L1502
  export NO_COLOR=1
  export TERM=dumb

  home_setup
  xdg_setup
  nix_setup;
  flox_setup;
  ssh_setup
  git_setup;
  gh_setup;
}

# ---------------------------------------------------------------------------- #

setup

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #

#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/docker-run.sh
#   ./scripts/docker-run.sh --no-ssh
#   ./scripts/docker-run.sh <command...>
#
# Examples:
#   ./scripts/docker-run.sh
#   ./scripts/docker-run.sh bitbake-layers show-layers

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USE_SSH=1

if [[ "${1:-}" == "--no-ssh" ]]; then
    USE_SSH=0
    shift
fi

export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"

cd "${REPO_DIR}"

compose_cmd=(docker compose run --rm)

if [[ ${USE_SSH} -eq 1 && -n "${SSH_AUTH_SOCK:-}" && -S "${SSH_AUTH_SOCK}" ]]; then
    echo "Forwarding host SSH agent into container."
    compose_cmd+=(-e "SSH_AUTH_SOCK=/ssh-agent")
    compose_cmd+=(-v "${SSH_AUTH_SOCK}:/ssh-agent")
fi

if [[ ${USE_SSH} -eq 1 && -f "${HOME}/.ssh/known_hosts" ]]; then
    compose_cmd+=(-v "${HOME}/.ssh/known_hosts:/home/builder/.ssh/known_hosts:ro")
fi

if [[ $# -gt 0 ]]; then
    "${compose_cmd[@]}" yocto-builder "$@"
else
    "${compose_cmd[@]}" yocto-builder bash
fi

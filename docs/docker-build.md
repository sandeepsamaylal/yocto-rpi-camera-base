# Docker Build Workflow

This project supports building Yocto inside a Docker container so the host only needs Docker and Git.

## Host Requirements

- Docker Engine
- Docker Compose plugin (`docker compose`)
- Git

## One-Time Setup

1. Clone this repository.
2. Initialize submodules:
   - `git submodule update --init --recursive`

## Build in Container

From repository root:

- `./scripts/docker-build.sh`

Optional build directory name:

- `./scripts/docker-build.sh build-rpi4`

If you need Git over SSH (for private repos), load your key on host first:

- `eval "$(ssh-agent -s)"`
- `ssh-add ~/.ssh/id_ed25519`

This uses:

- `docker/Dockerfile`
- `docker-compose.yml`

## Build Caches

To speed up repeated builds, these host directories are mounted into the container:

- `cache/downloads`
- `cache/sstate-cache`

## Open an Interactive Builder Shell

- `./scripts/docker-run.sh`

Run a one-shot command in the same container context:

- `./scripts/docker-run.sh bitbake-layers show-layers`

## Generate SDK in Docker

- Standard SDK:
   - `./scripts/docker-sdk.sh`
- Extensible SDK:
   - `./scripts/docker-sdk.sh --ext`

SDK output directory:

- `build-rpi4/tmp/deploy/sdk`

For SSH agent forwarding in an interactive shell:

- `HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose run --rm -e SSH_AUTH_SOCK=/ssh-agent -v $SSH_AUTH_SOCK:/ssh-agent -v ~/.ssh/known_hosts:/home/builder/.ssh/known_hosts:ro yocto-builder bash`

Inside the container, you can run:

- `./scripts/build.sh`

To verify agent forwarding:

- `ssh-add -l`

## Notes

- Hardware boot, network validation on target, and SSH-to-target testing still require the Raspberry Pi.
- Containerized builds provide reproducibility and reduce host dependency setup.

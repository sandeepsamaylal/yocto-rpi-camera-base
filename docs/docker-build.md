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

This uses:

- `docker/Dockerfile`
- `docker-compose.yml`

## Build Caches

To speed up repeated builds, these host directories are mounted into the container:

- `cache/downloads`
- `cache/sstate-cache`

## Open an Interactive Builder Shell

- `HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose run --rm yocto-builder bash`

Inside the container, you can run:

- `./scripts/build.sh`

## Notes

- Hardware boot, network validation on target, and SSH-to-target testing still require the Raspberry Pi.
- Containerized builds provide reproducibility and reduce host dependency setup.

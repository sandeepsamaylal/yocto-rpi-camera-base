# Submodule Revision Locks

This file records the currently pinned submodule revisions used by this repository.

## Branch Policy

All Yocto source submodules track the `scarthgap` branch in `.gitmodules`.

## Current Pinned Revisions

| Submodule | Branch | Commit | Describe |
|---|---|---|---|
| sources/poky | scarthgap | 077627338ac18aeca34bfe0c52777fab38e2e0c0 | yocto-5.0.19-127-g077627338a |
| sources/meta-openembedded | scarthgap | ef3df29f2cfca6a9513b51ebcdccf82b6c8a836f | ef3df29f2c |
| sources/meta-raspberrypi | scarthgap | 6ca1f75017cc5d5acdb8bb05634c4bc01fa049fd | 6ca1f75 |

## How To Refresh

Run the following from the repository root:

- `git submodule update --remote --merge`

Then update this file with new commit hashes and descriptions.

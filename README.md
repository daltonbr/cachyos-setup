# CachyOs Setup

## Setup

You can toggle options in `config.env` without touching the scripts. Each step is idempotent, safe to rerun.

### Giving execution permission

```shell
chmod +x main.sh steps/*.sh lib/common.sh
```

### Running

Individual steps

```shell
./main.sh <individual-step>
```

```shell
./main.sh 00-preflight
```

Or run all steps

```shell
./main.sh
```

### Structure

```
bootstrap/
├─ main.sh
├─ config.env
├─ lib/
│  └─ common.sh
└─ steps/
   └─ ...
```

## Documentation

- [Flatpak](./docs/flatpak.md)
- [ExtraRead](./docs/extra-read.md)

### A note about CPU archtectures

I am using Ryzen `5800X` (Zen 3) is `x86-64-v3` capable but not v4. On CachyOS you “choose” optimized binaries by using the matching repos (e.g. `cachyos-v3`, `cachyos-core-v3`, `cachyos-extra-v3`). Once those repos are enabled and precede Arch repos in `pacman.conf`, `pacman -Syu` will pull the optimized builds automatically.

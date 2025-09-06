# CachyOS Gaming Guide

This document provides tips and tricks for an optimal gaming experience on your CachyOS system.

## Installation

The `cachyos-setup` script installs the following gaming components:
- `cachyos-gaming-meta` - Core gaming components including Gamescope, Goverlay, Heroic Games Launcher, Lutris, MangoHud and Steam
- `cachyos-gaming-applications` - Additional gaming applications
- `proton-cachyos` - CachyOS optimized Proton with additional patches
- `proton-cachyos-slr` - CachyOS Proton with Steam Linux Runtime (for Anti-Cheat games)
- `wine-cachyos-opt` - CachyOS optimized Wine (installed to /opt/wine-cachyos for coexistence with system wine)
- `game-performance` - Official CachyOS script to temporarily enable performance power profile
- `power-profiles-daemon` - Required for game-performance to function
- Other utilities and performance tools

## Proton Versions

CachyOS provides several Proton versions:

- **proton-cachyos**: Main version with additional QoL changes, cherry-picked patches, and compilation optimizations. Recommended for most cases.
- **proton-cachyos-slr**: For games using BattlEye or Easy Anti-Cheat.
- **Proton Experimental**: Bleeding edge release from Valve. Use for new games or if recommended on ProtonDB.
- **Proton 9.0.4 or older**: Stable releases from Valve. Use if a game only works with a specific older version.
- **Proton-GE**: Custom build with various fixes and optimizations.

## Performance Optimizations

### Power Profile Switching

The `game-performance` script is the official CachyOS utility that temporarily switches your system to the performance power profile while gaming. It also prevents your system from entering screensaver mode during gameplay.

To use it with Steam games, add this to the game's launch options:
```
game-performance %command%
```

For other launchers:
- **Lutris**: Add `game-performance` in the "Command prefix" field
- **Heroic Games Launcher**: Add `game-performance` in the "Command Line Arguments" field

This script requires `power-profiles-daemon` which is installed automatically by our setup.

### Shader Cache Size

The setup script increases your shader cache size to 12GB to prevent shader recompilation:
- For NVIDIA: `__GL_SHADER_DISK_CACHE_SIZE=12000000000`
- For AMD: `MESA_SHADER_CACHE_MAX_SIZE=12G`

### DLSS Optimization

For NVIDIA users with DLSS-compatible games, use the `dlss-swapper` script to force the latest DLSS preset:

```
dlss-swapper %command%
```

## Useful Environment Variables

Add these to your game's launch options in Steam as needed:

- `PROTON_ENABLE_HDR=1`: Enables HDR output support
- `PROTON_ENABLE_WAYLAND=1`: Enables native Wayland support
- `PROTON_NVIDIA_LIBS=1`: Enables NVIDIA-specific features (NVIDIA GPUs only)
- `PROTON_FSR4_UPGRADE=1`: Automatically upgrades FSR4 to the latest version
- `PROTON_DLSS_UPGRADE=1`: Automatically upgrades DLSS
- `PROTON_USE_NTSYNC=1`: Enables NTSync for better performance in CPU-bound games
- `PROTON_NO_WM_DECORATION=1`: Fixes borderless fullscreen issues
- `PROTON_PREFER_SDL=1`: May help with controller detection issues

## Anti-Cheat Support

For games using Easy Anti-Cheat (EAC) or BattlEye (BE), use `proton-cachyos-slr` which is built using Steam Linux Runtime.

## Checking Game Compatibility

- [ProtonDB](https://www.protondb.com/): Check how well games run with Proton
- [Are We Anti-Cheat Yet?](https://areweanticheatyet.com/): Check anti-cheat compatibility

## Wine-CachyOS

For non-Steam games, use `wine-cachyos-opt` with Lutris, Heroic, or Bottles. Environment variables:

- `WINE_WMCLASS="<n>"`: Controls Wine windows through window manager rules
- `WINEUSERSANDBOX=1`: Disables symlinks from Wine user folders
- `WINE_NO_WM_DECORATION=1`: Disables window decorations
- `WINE_PREFER_SDL_INPUT=1`: Helps with controller detection

### Using wine-cachyos-opt

Since `wine-cachyos-opt` is installed to `/opt/wine-cachyos/` to avoid conflicts with the system wine:

- Direct usage: `/opt/wine-cachyos/bin/wine program.exe`
- With winetricks: `WINE=/opt/wine-cachyos/bin/wine WINEPREFIX=/path/to/prefix winetricks verb`

For more advanced usage, you can set these environment variables:
```
export PATH="/opt/wine-cachyos/bin/:$PATH"
export WINEDLLPATH="/opt/wine-cachyos/lib/wine:/opt/wine-cachyos/lib32/wine:$WINEDLLPATH"
export LD_LIBRARY_PATH="/opt/wine-cachyos/lib/:/opt/wine-cachyos/lib32/:$LD_LIBRARY_PATH"
```

## Troubleshooting

### Fix Steam Overlay Issues

If Steam's overlay causes stuttering, add this launch option:
```
LD_PRELOAD="" %command%
```
Note: This disables the Steam overlay.

You can combine this with game-performance:
```
game-performance LD_PRELOAD="" %command%
```

### Steam Shader Pre-caching

It's advised to disable Steam's pre-caching of shaders when using Proton-CachyOS, Proton-GE, or Proton-EM, as they already contain necessary codecs.

### NTFS Partitions

Avoid using Proton on NTFS drives. Valve does not support this configuration, and it can cause games to behave unpredictably.

## Additional Resources

For more information, visit the [CachyOS Gaming Wiki](https://wiki.cachyos.org/configuration/gaming/).
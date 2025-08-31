# Extra Read

## AUR and PARU - Helper repositories
- WHAT IS THE AUR AND WHY DO WE NEED A HELPER?

The Arch User Repository (AUR) is a vast, community-driven repository for
Arch Linux users. It contains package descriptions (PKGBUILDs) that allow
you to compile and install software not available in the official repos.

The official package manager, `pacman`, does not interact with the AUR.
The manual process is:
1. Find the package on the AUR website.
2. `git clone` its source repository.
3. `cd` into the directory.
4. Run `makepkg -si` to download sources, compile, and install.

An "AUR Helper" (like yay or paru) automates this entire process for you,
making installing AUR packages as easy as `yay -S <package>`.

## Development notes

This is a defensive programming command we are using in those scripts

```sh
set -euo pipefail
```

This is a very important line for writing robust and safe shell scripts. It sets a few options:
*   `set -e` (`errexit`): The script will exit immediately if any command fails (returns a non-zero exit code). This prevents the script from continuing in an unpredictable state after an error.
*   `set -u` (`nounset`): The script will exit if it tries to use a variable that has not been defined. This helps catch typos in variable names.
*   `set -o pipefail`: By default, the exit code of a pipeline (e.g., `command1 | command2`) is the exit code of the *last* command. With `pipefail`, the exit code of the pipeline will be the exit code of the *first* command to fail, or zero if all commands succeed. This is crucial for catching errors in the middle of a pipeline.

# Extra Read

```sh
set -euo pipefail
```

This is a very important line for writing robust and safe shell scripts. It sets a few options:
*   `set -e` (`errexit`): The script will exit immediately if any command fails (returns a non-zero exit code). This prevents the script from continuing in an unpredictable state after an error.
*   `set -u` (`nounset`): The script will exit if it tries to use a variable that has not been defined. This helps catch typos in variable names.
*   `set -o pipefail`: By default, the exit code of a pipeline (e.g., `command1 | command2`) is the exit code of the *last* command. With `pipefail`, the exit code of the pipeline will be the exit code of the *first* command to fail, or zero if all commands succeed. This is crucial for catching errors in the middle of a pipeline.

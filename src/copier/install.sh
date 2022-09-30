#!/bin/bash

USERNAME=${USERNAME:-"automatic"}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

# su ${USERNAME} -c "/usr/local/py-utils/bin/pipx install copier"
su ${USERNAME} -c "echo hello > /tmp/hello.txt"
# su ${USERNAME} -c "which python > /tmp/copier-debug.txt"
# su ${USERNAME} -c "which pip >> /tmp/copier-debug.txt"
# su ${USERNAME} -c "which pipx >> /tmp/copier-debug.txt"
# su ${USERNAME} -c "whoami >> /tmp/copier-debug.txt"
# su ${USERNAME} -c "$(which pipx) install copier" || exit 0

echo "Done!"
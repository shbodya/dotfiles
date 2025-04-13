#!/usr/bin/env bash

# Root is $DOTPATH if it exists, otherwise the directory of this script
root=$(realpath "${DOTPATH:-$(dirname "$(realpath "$0")")}")

# Source the bash_traceback.sh file
source "${root}/bash_traceback.sh"

###############################################################################
# Update dotfiles                                                             #
###############################################################################

function dotlink() {
	find "linkme" -type d -mindepth 1 | sed "s|^linkme/||" |
		while read -r dir; do mkdir -p "${HOME}/${dir}"; done
	find "linkme" -type f -not -name '.DS_Store' | sed "s|^linkme/||" |
		while read -r file; do
			echo -e "✅ Linked linkme/${file} -> ~/${file}"
			ln -fvns "${root}/linkme/${file}" "${HOME}/${file}" 1>/dev/null
		done
}

function dotunlink() {
	rsync -av --exclude='.DS_Store' linkme/ "${HOME}" |
		grep -v "building file list ... done" |
		awk '/^$/ { exit } !/\/$/ { printf "🔙 Restored %s\n", $0; }'
}

# Copy all files from copyme/ to $HOME
if [[ ${1-} == "unlink" ]]; then
	echo -e "📋 Restoring dotfiles..."
	dotunlink
else
	echo -e "🔗 Linking dotfiles..."
	if [[ ${1-} != "-y" ]] && [[ ${1-} != "--yes" ]]; then
		read -rp $'❓ Overwrite existing dotfiles with symlinks to stored dotfiles? (y/n) ' LINK
	else
		LINK="y"
	fi

	if [[ ${LINK} =~ ^[Yy]$ ]]; then
		dotlink
		# 1Password needs the permissions to be set to 700
		chmod 700 "${HOME}/.config/op"
	fi
fi

# shellcheck source=/dev/null
source "${HOME}/.zprofile"

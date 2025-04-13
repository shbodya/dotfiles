#!/usr/bin/env bash

# Root is $DOTPATH if it exists, otherwise the directory of this script
root=$(realpath "${DOTPATH:-$(dirname "$(realpath "$0")")}")

# Source the bash_traceback.sh file
source "${root}/bash_traceback.sh"

###############################################################################
# Manage VSCode extensions                                                    #
###############################################################################

# Taken and modified from https://github.com/br3ndonland/dotfiles

# Check if the first argument is -y or --yes
auto_yes=false
for arg in "$@"; do
	if [[ ${arg} == "-y" ]] || [[ ${arg} == "--yes" ]]; then
		auto_yes=true
	fi
done

extensions_file="${root}/linkme/.config/code/extensions.txt"

export_extensions() {
	echo -e "📲 Exporting extensions from $2 to extensions.txt..."
	$1 --list-extensions >"${extensions_file}"
	echo -e "✅ Extensions exported to extensions.txt"
}

sync_extensions() {
	echo -e "📲 Syncing extensions for $2..."
	local installed to_remove=()

	# Get currently installed extensions
	mapfile -t installed < <($1 --list-extensions)

	# Install missing extensions
	while read -r extension; do
		if printf '%s\n' "${installed[@]}" | grep -q "^${extension}$"; then
			echo -e "✅ Extension ${extension} already installed."
		else
			echo -e "⬇️  Installing extension ${extension}..."
			$1 --install-extension "${extension}"
		fi
	done <"${extensions_file}"

	# Find extensions to remove
	for installed_extension in "${installed[@]}"; do
		if ! grep -q "^${installed_extension}$" "${extensions_file}"; then
			to_remove+=("${installed_extension}")
		fi
	done

	# If there are extensions to remove, ask for confirmation
	if [[ ${#to_remove[@]} -gt 0 ]]; then
		echo -e "\n❗️ The following extensions are not in extensions.txt:"
		printf "  %s\n" "${to_remove[@]}"

		if [[ ${auto_yes} == false ]]; then
			read -rp $'❓ Do you want to uninstall these extensions? (y/n) ' choice
		else
			choice="y"
			echo -e "🔄 Auto-confirming removal due to -y flag"
		fi

		if [[ ${choice} == "y" ]]; then
			for extension in "${to_remove[@]}"; do
				echo -e "🗑️  Uninstalling extension '${extension}'..."
				$1 --uninstall-extension "${extension}"
				echo -e "🚮 Uninstalled '${extension}'."
			done
		else
			echo -e "🆗 No extensions were uninstalled."
		fi
	else
		echo -e "✅ All installed extensions are present in extensions.txt."
	fi
}

# Parse arguments
editor="cursor" # default editor
action=""

for arg in "$@"; do
	case ${arg} in
	--export | --sync)
		action=${arg}
		;;
	-y | --yes)
		continue
		;;
	*)
		if [[ -n ${arg} ]]; then # Only set editor if arg is not empty
			editor=${arg}
		fi
		;;
	esac
done

if [[ -z ${action} ]]; then
	echo -e "\n❌ Error: Invalid action. Use --export or --sync"
	echo -e "Usage: $0 [editor] [--export|--sync] [-y|--yes]"
	exit 1
fi

# Get the friendly name for the editor
case ${editor} in
code) editor_name="Visual Studio Code" ;;
code-exploration) editor_name="Visual Studio Code - Exploration" ;;
code-insiders) editor_name="Visual Studio Code - Insiders" ;;
codium) editor_name="VSCodium" ;;
cursor) editor_name="Cursor" ;;
*)
	echo -e "\n❌ Error: Invalid editor specified."
	exit 1
	;;
esac

MACOS_BIN="/Applications/${editor}.app/Contents/Resources/app/bin"
if [[ "$(uname -s)" == "Darwin" ]] && [[ -d ${MACOS_BIN} ]]; then
	export PATH="${MACOS_BIN}:${PATH}"
fi

if ! type "${editor}" &>/dev/null; then
	echo -e "\n❌ Error: ${editor} command not on PATH." >&2
	exit 1
else
	case ${action} in
	--export) export_extensions "${editor}" "${editor_name}" ;;
	--sync) sync_extensions "${editor}" "${editor_name}" ;;
	*)
		echo -e "\n❌ Error: Invalid action"
		exit 1
		;;
	esac
fi

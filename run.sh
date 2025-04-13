#!/usr/bin/env bash

# Root is $DOTPATH if it exists, otherwise the directory of this script
root=$(realpath "${DOTPATH:-$(dirname "$(realpath "$0")")}")

# Source the bash_traceback.sh file
source "${root}/bash_traceback.sh"

###############################################################################
# OS and architecture detection                                               #
###############################################################################
os="$(uname)"
if [[ ${os} != 'Darwin' ]] && [[ ${os} != 'Linux' ]]; then
	echo -e "❌ Error: Unsupported OS: ${os}"
	exit 1
fi
echo -e "💻 OS detected:   ${os}"

archname="$(arch)"
echo -e "💻 Arch detected: ${archname}"

# Get hardware identifier
if [[ ${os} == "Darwin" ]]; then
	uuid=$(system_profiler SPHardwareDataType | awk '/Hardware UUID/ {print $3}')
	serial=$(system_profiler SPHardwareDataType | awk '/Serial Number/ {print $4}')
	model=$(sysctl hw.model | sed 's/hw.model: //')
else
	uuid=$(cat /sys/class/dmi/id/product_uuid 2>/dev/null ||
		cat /etc/machine-id 2>/dev/null ||
		cat /var/lib/dbus/machine-id 2>/dev/null || echo '')
	serial=$(cat /sys/class/dmi/id/serial_number 2>/dev/null ||
		cat /sys/devices/virtual/dmi/id/product_serial 2>/dev/null ||
		cat /sys/devices/virtual/dmi/id/product_uuid 2>/dev/null || echo '')
	model=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null ||
		cat /sys/devices/virtual/dmi/id/product_version 2>/dev/null || echo '')
fi
echo -e "💻 Hardware UUID: ${uuid}"
echo -e "💻 Serial Number: ${serial:-N/A}"
echo -e "💻 Model:         ${model:-N/A}"

###############################################################################
# Install Homebrew                                                            #
###############################################################################
echo
echo -e "🍺 Installing Homebrew..."
if ! command -v brew &>/dev/null; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo -e "🍻 Homebrew installed."
else
	echo -e "🍻 Homebrew is already installed."
fi

###############################################################################
# Install dotfiles                                                            #
###############################################################################
echo
echo -e "🚀 Running dotsync.sh..."
sleep 1
./dotsync.sh "${1-}"

###############################################################################
# Linux exit                                                                  #
###############################################################################
if [[ ${os} == "Linux" ]]; then
	echo
	echo -e "⛔️ Warning: Linux is not supported after this point."
	exit 0
fi

###############################################################################
# macOS preferences                                                           #
###############################################################################
sleep 1
echo
echo -e "🚀 Running macos.sh..."
./macos.sh "${1-}"

# ###############################################################################
# # CI exit                                                                     #
# ###############################################################################
# if [[ ${CI-} == "true" ]]; then
# 	echo
# 	echo -e "⛔️ Warning: macOS is not supported in CI after this point."
# 	exit 0
# fi

###############################################################################
# Install apps and software                                                   #
###############################################################################
echo
echo -e "🚀 Running install.sh..."
sleep 1
./install.sh "${1-}"
# echo
# echo -e "🚀 Running dock.sh..."
# sleep 1
# ./dock.sh

# not working
# ###############################################################################
# # Install Cursor extensions                                                   #
# ###############################################################################
# echo
# echo -e "🚀 Running code.sh..."
# sleep 1
# ./code.sh --sync "${1-}"

# ###############################################################################
# # Local settings and variables                                                #
# ###############################################################################
# echo
# echo -e "🚀 Running local.sh..."
# sleep 1
# ./local.sh "${1-}"

echo
echo -e "🎉 Setup complete!"

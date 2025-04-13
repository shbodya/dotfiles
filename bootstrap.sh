#!/usr/bin/env bash

{ # Prevent script from running if partially downloaded

	set -euo pipefail

	DOTPATH=${HOME}/.dotfiles
	BRANCH=""
	YES=false
	while getopts b:y flag; do
		case "${flag}" in
		b) BRANCH=${OPTARG} ;;
		y) YES=true ;;
		*) echo "Invalid option: -${OPTARG}" && exit 1 ;;
		esac
	done

	echo -e "Bootstrapping dotfiles"

	if [[ ! -d ${DOTPATH} ]]; then
		if [[ -z ${BRANCH} ]]; then
			echo -e "Cloning dotfiles..."
			git clone https://github.com/shbodya/dotfiles.git "${DOTPATH}"
			echo -e "Cloned Dotfiles to ${DOTPATH}"
		else
			echo -e "Cloning dotfiles on branch ${BRANCH}..."
			git clone https://github.com/shbodya/dotfiles.git --branch "${BRANCH}" "${DOTPATH}"
			echo -e "Cloned Dotfiles to ${DOTPATH} on branch ${BRANCH}"
		fi
	else
		if [[ -z ${BRANCH} ]]; then
			echo -e "Dotfiles already downloaded to ${DOTPATH}"
		else
			echo -e "Dotfiles already downloaded to ${DOTPATH}, checking out branch ${BRANCH}"
			cd "${DOTPATH}"
			git stash
			git checkout "${BRANCH}"
			git pull origin "${BRANCH}"
		fi
	fi

	cd "${DOTPATH}"

	if [[ ${YES} == true ]]; then
		./run.sh -y
	else
		./run.sh
	fi

} # Prevent script from running if partially downloaded
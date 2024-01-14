#!/usr/bin/env bash

# Prepare OS for deployment.
# - Configure local repository
# - Directories should be created on the go

# FIXME Move into base module?

#
## Libraries
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/env.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/common.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/log.sh

case "$dd_distro" in
    gentoo)
        # Add GURU overlay
        # Make sure eselect-repository is installed
        if ! equery l app-eselect/eselect-repository > /dev/null; then
            dd::log::log-info "Installing app-eselect/eselect-repository"
            dd::common::elevate_cmd emerge --oneshot --verbose app-eselect/eselect-repository || exit 1
        fi

        if ! eselect repository list -i | grep "guru" > /dev/null; then
           dd::log::log-info "Adding GURU overlay"
           dd::common::elevate_cmd eselect repository enable guru || exit 1
           dd::common::elevate_cmd emaint sync -r guru || exit 1
        fi

        # Add local repository
        if [[ ! -d /etc/portage/repos.conf ]]; then
            dd::common::elevate_cmd mkdir -p /etc/portage/repos.conf
        fi
        if [[ ! -f /etc/portage/repos.conf/localrepo.conf ]]; then
            dd::common::elevate_cmd ln -sfv "$DOTDEPLOY_ROOT"/packages/gentoo/localrepo.conf /etc/portage/repos.conf/localrepo.conf
        fi
        if [[ ! -d /etc/portage/package.accept_keywords ]]; then
            dd::common::elevate_cmd mkdir -p /etc/portage/package.accept_keywords
        fi
        if [[ ! -f /etc/portage/package.accept_keywords/localrepo ]]; then
            dd::common::elevate_cmd ln -sfv "$DOTDEPLOY_ROOT"/packages/gentoo/localrepo.keywords /etc/portage/package.accept_keywords/localrepo
        fi
        if [[ ! -d /etc/portage/package.use ]]; then
            dd::common::elevate_cmd mkdir -p /etc/portage/package.use
        fi
        if [[ ! -d /etc/portage/patches ]]; then
            dd::common::elevate_cmd mkdir -p /etc/portage/patches
        fi
        ;;
    ubuntu)
        # Make sure equivs and dpkg-dev are installed
        if dd::common::check_uncallable equivs-build; then
            dd::common::elevate_cmd apt-get update
            dd::common::elevate_cmd apt-get install -y equivs
        fi
        if dd::common::check_uncallable equivs-build; then
            dd::common::elevate_cmd apt-get update
            dd::common::elevate_cmd apt-get install -y dpkg-dev
        fi

        # Copy declarations into temp directory
        dd_build_dir="$DOTDEPLOY_TMP_DIR"/build
        mkdir -p "$dd_build_dir"

        mapfile -t deb_srcs < <(find "$DOTDEPLOY_ROOT"/packages/ubuntu/sources -type f -name "*.ctl")
        for deb_src in "${deb_srcs[@]}"; do
            cp "$deb_src" "$dd_build_dir"/"$(basename "$deb_src")"
        done
        unset -v deb_srcs
        unset -v deb_src

        pushd "$dd_build_dir" > /dev/null || exit 1

        # Build metapackages
        dd::log::log-info "Building Ubuntu packages ..."
        mapfile -t deb_srcs < <(find . -type f -name "*.ctl")
        for deb_src in "${deb_srcs[@]}"; do
            dd::common::dry_run equivs-build "$deb_src"
        done
        unset -v deb_srcs
        unset -v deb_src

        # Create repo folder and copy files
        if [[ ! -d /var/local/dotdeploy/repo ]]; then
            dd::common::elevate_cmd mkdir -p /var/local/dotdeploy/repo
        fi

        mapfile -t deb_files < <(find . -type f -name "*.deb")
        for deb in "${deb_files[@]}"; do
            dd::common::elevate_cmd cp "$deb" /var/local/dotdeploy/repo/"$(basename "$deb")"
        done
        unset -v deb_files
        unset -v deb

        dd::common::elevate_cmd cp "$DOTDEPLOY_ROOT"/packages/ubuntu/dotdeploy-update-repo /usr/local/bin/dotdeploy-update-repo
        dd::common::elevate_cmd chmod +x /usr/local/bin/dotdeploy-update-repo

        # Execute repo script
        dd::common::elevate_cmd /usr/local/bin/dotdeploy-update-repo

        # Add repository to sources
        if [[ ! -f /etc/apt/sources.list.d/dotdeploy.list ]]; then
            dd::common::elevate_cmd ln -sfv "$DOTDEPLOY_ROOT"/packages/ubuntu/dotdeploy.list /etc/apt/sources.list.d/dotdeploy.list
        fi

        popd > /dev/null || exit 1
        unset -v dd_build_dir

        # apt update and done
        dd::common::elevate_cmd apt-get -q update
        ;;
esac

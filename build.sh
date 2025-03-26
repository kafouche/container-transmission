#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# SHELL FUNCTIONS
# ------------------------------------------------------------------------------

function __is_command {
    command -v "$1" 2>&1 > /dev/null
}

function __printerr {
    if [ $# -ne 0 ]; then
        printf '%s' "$1" >&2
        shift

        if [ $# -ne 0 ]; then
            for arg in $@; do
                printf ' %s' "$arg" >&2
            done
        fi
    else
        printf '\n' >&2
    fi
}

# ENGINE FUNCTIONS
# ------------------------------------------------------------------------------

function __buid_image {
    local engine="$1"
    local image="$2"

    __printerr "[${image}] Building image..."
    __printerr
    __printerr

    "${engine}" build --tag "${image}" .

    __printerr
    __printerr "[${image}] Build Completed."
    __printerr
    __printerr
}

function __get_dockerfile_release_arg {
    local release="$(grep --extended-regexp "^ARG[[:space:]]+RELEASE=.+$" Dockerfile)"

    release="$([[ "${release}" =~ RELEASE=(.+)$ ]] && printf '%s' "${BASH_REMATCH[1]}")"

    printf '%s' "${release}"
}

function __push_image {
    local engine="$1"
    local image="$2"

    __printerr "[${image}] Pushing image to registry..."
    __printerr
    __printerr

    "${engine}" push "${image}"

    __printerr
    __printerr "[${image}] Push Completed."
    __printerr
    __printerr
}

function __tag_image {
    local engine="$1"
    local image="$2"
    local tag="$3"

    __printerr "[${image}] Adding tag '${tag}'..."

    "${engine}" tag "${image}" "${tag}"

    __printerr ' DONE'
    __printerr
    __printerr
}

function __update_build_tag {
    local tag="$1"

    if [[ "${tag}" != "${TAG}" ]]; then
        __printerr
        __printerr "[build.env] Updating tag: ${TAG} => ${tag}..."

        sed -i "/^TAG=/s/=.*/='${tag}'/" build.env

        __printerr " DONE"
        __printerr
    fi
}

function __update_dockerfile_release_arg {
    local release="$1"

    local arg="$(__get_dockerfile_release_arg)"

    if [[ "${release}" != "${arg}" ]]; then
        __printerr
        __printerr "[Dockerfile] Updating tag: ${arg} => ${release}..."

        sed -i "/^ARG[[:space:]]\+RELEASE=/s/=.*/=${release}/" Dockerfile

        __printerr " DONE"
        __printerr
    fi
}

function __update_tag_from_github {
    local github_api_url="https://api.github.com/repos/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}/releases/latest"
    
    local github_tag="$(
        curl --silent --request GET "${github_api_url}" \
        | awk '/tag_name/{print $4;exit}' FS='[""]'
    )"


    if [[ "${github_tag}" == v* ]]; then
        local tag="${github_tag:1}"
    else
        local tag="${github_tag}"
    fi

    __update_build_tag "${tag}"

    if "${BUILD_FROM_GITHUB}"; then
        __update_dockerfile_release_arg "${github_tag}"
    else
        __update_dockerfile_release_arg "${tag}"
    fi

    if "${COMMIT_CHANGES}"; then
        git add .
        git commit -m "Auto-update: ${TAG} => ${tag}"
    fi

    __printerr

    TAG="${tag}"
}

# SELECT ENGINE

if __is_command docker; then
    __ENGINE='docker'
elif __is_command podman; then
    __ENGINE='podman'
else
    __printerr 'Error: neither `docker` nor `podman` are installed on this system.'
    exit 1
fi

__NOT_BUILT=true

# LOAD ENVIRONMENT

source build.env

# UPDATE TAG

if "${UPDATE_TAG_FROM_GITHUB}"; then
    __update_tag_from_github
fi

REGISTRY=($REGISTRY)
TAG=($TAG)

# BUILD AND TAG IMAGE

if "${BUILD_TAG_IMAGE}"; then
    for r in "${REGISTRY[@]}"; do
        for t in "${TAG[@]}"; do
            if "${__NOT_BUILT}"; then
                __buid_image "$__ENGINE" "${REGISTRY[0]}/${NAMESPACE}/${IMAGE}:${TAG[0]}"
                __NOT_BUILT=false
            else
                __tag_image "$__ENGINE" \
                    "${REGISTRY[0]}/${NAMESPACE}/${IMAGE}:${TAG[0]}" \
                    "${r}/${NAMESPACE}/${IMAGE}:${t}"
            fi
        done

        if "${LATEST_TAG}"; then
            __tag_image "$__ENGINE" \
                "${REGISTRY[0]}/${NAMESPACE}/${IMAGE}:${TAG[0]}" \
                "${r}/${NAMESPACE}/${IMAGE}:latest"
        fi
    done
fi


# PUSH TO REGISTRY

if "${PUSH_TO_REGISTRY}"; then
    for r in "${REGISTRY[@]}"; do
        for t in "${TAG[@]}"; do
            __push_image "$__ENGINE" "${r}/${NAMESPACE}/${IMAGE}:${t}"
        done

        if "${LATEST_TAG}"; then
            __push_image "$__ENGINE" "${r}/${NAMESPACE}/${IMAGE}:latest"
        fi
    done
fi

exit 0
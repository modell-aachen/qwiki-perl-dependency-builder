#!/bin/bash

build() {

    usage() {
        printf -v text "%s" \
            "build [OPTION...]\n" \
            "    -d, --distro       specify distro pattern, e.g. \"deb\" would match debian8 and debian10\n" \
            "    -p, --package      cpan package to build, e.g. JSON::XS\n" \
            "    -v, --version      build the specified Version of the package. Defaults to latest\n" \
            "    -i, --images       only build the docker images\n" \
            "    -h, --help         shows this help message\n"
        printf "$text"
    }

    filter-distros() {
        if [ "$DISTRO" ]; then
            for elem in "${distros[@]}"; do [[ $elem =~ $DISTRO ]] && with_distros+=("$elem"); done
        else
            for elem in "${distros[@]}"; do with_distros+=("$elem"); done
        fi
    }

    check-params() {
        if [ -z "$PACKAGE" ] && [ -z "$IMAGES" ]; then
            echo "CPAN Module name missing."
            exit 1
        elif [ ${#with_distros[@]} -eq 0 ]; then
            echo "Distro pattern resulted in an empty list."
            exit 1
        fi
    }

    move-packages() {
        mkdir -p ./builds/$distro
        build_packages=$(find ./distros/$distro/ -name "*.deb" -o -name "*.rpm")
        if [[ "$build_packages" ]]; then
            echo $build_packages | xargs cp -t ./builds/$distro/
        else
            echo "Could not find any packages."
        fi
    }

    IMAGES=false
    distros=(debian8 debian10 redhat7)

    OPTS=`getopt -o d:p:v:ih --long distro:,package:,version:,images,help -- "$@"`
    if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

    eval set -- "$OPTS"

    while true; do
        case "$1" in
            -d | --distro )
                DISTRO=$2
                shift 2 ;;
            -p | --package )
                PACKAGE=$2
                shift 2 ;;
            -v | --version )
                VERSION=$2
                shift 2 ;;
            -i | --images )
                IMAGES=true
                shift ;;
            -h | --help )
                usage
                return
                shift ;;
            -- )
                shift
                break ;;
            * )
                break ;;
        esac
    done

    filter-distros

    check-params

    rm -rf ./builds/*
    echo "Using distros: ${with_distros[@]}"

    for distro in "${with_distros[@]}"; do
        echo "Building for distro: $distro"
        docker build -t qwiki-$distro -f ./distros/$distro/Dockerfile ./distros/$distro
        if [[ "$IMAGES" = false ]]; then
            docker run -v $(pwd)/distros/$distro/build:/opt/build -it --rm qwiki-$distro $PACKAGE $VERSION
            move-packages
        fi
    done
    echo "Done building packages. You'll find them in the builds/ folder."
}

build $@
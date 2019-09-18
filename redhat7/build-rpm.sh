#!/bin/bash

build-rpm() {

    usage() {
        printf -v text "%s" \
            "build-rpm [OPTION...]\n" \
            "    -p, --package      cpan package to build\n" \
            "    -v, --version      build specified Version. Defaults to latest\n" \
            "    -h, --help         shows this help message\n"
        printf "$text"
    }

    OPTS=`getopt -o p:v:h --long package:,version:,help -- "$@"`
    if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

    eval set -- "$OPTS"

    while true; do
        case "$1" in
            -p | --package )
                PACKAGE=$2
                shift 2 ;;
            -v | --version )
                VERSION=$2
                shift 2 ;;
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

    if [ -z "$PACKAGE" ]; then
        echo "CPAN Module name missing."
        exit 1
    fi

    docker build -t qwiki-redhat7 .
    docker run -v $(pwd)/build:/opt/build -it --rm qwiki-redhat7 $PACKAGE $VERSION
    echo "Done building package. Its located in build/RPMS/<arch>/"
}

build-rpm $@
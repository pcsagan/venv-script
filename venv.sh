#!/bin/bash -x

C_USE=true # toggle the use of colors by changing this constant to any other value
[ "$C_USE" = true ] && C_X='\e[0m'    || C_X=''    # no color
[ "$C_USE" = true ] && C_R='\e[0;31m' || C_R=''    # red
[ "$C_USE" = true ] && C_G='\e[0;32m' || C_G=''    # green
[ "$C_USE" = true ] && C_Y='\e[0;33m' || C_Y=''    # yellow
[ "$C_USE" = true ] && C_B='\e[0;34m' || C_B=''    # blue

script=`basename ${BASH_SOURCE[0]}`
pwd=`pwd`
venv_command="venv" # can be "venv" or "virtualenv" but the latter has been deprecated since python 3.8
env_dir="venv"
recreate_env=false
install_deps=false
install_dev_deps=false
requirements="requirements.txt"
requirements_dev="requirements_dev.txt"
quiet_mode=false

function print() {
    # if we're not in quiet mode then forward all arguments to echo
    [ "$quiet_mode" != true ] && echo -e "$@"
}

function help {
    print "usage:  ${C_G}source ${script} [-h] [-d] [-n {virtualenv}] [-r]${C_X}"
    print "options:"
    print "  ${C_G}-h${C_X}    show this help message and exit"
    print "  ${C_G}-d${C_X}    install dependencies from $requirements_dev (${C_B}default: $install_dev_deps${C_X})"
    print "  ${C_G}-n${C_X}    the name of the virtual environment directory (${C_B}default: $env_dir${C_X})"
    print "  ${C_G}-r${C_X}    recreate the virtual environment (${C_B}default: $recreate_env${C_X})"
    print "  ${C_G}-q${C_X}    the script will generate no output (${C_B}default: $quiet_mode${C_X})"
    return 0
}

# note: due to the way arguments are parsed the -q flag must come first in order
#       to silence errors regarding invalid arguments. e.g. '-q -<invalid>'' produces
#       no output whereas '-<invalid> -q' does.

OPTIND=1 # required for getopts to work with repeated calls in the same session
while getopts :dn:rqh FLAG; do
  case $FLAG in
    d)  # install dependencies from $requirements_dev
        install_dev_deps=true
        ;;
    n)  # the name of the virtual environment directory
        env_dir=$OPTARG
        ;;
    r)  # recreate the virtual environment
        recreate_env=true
        ;;
    q)  # the script will generate no output
        quiet_mode=true
        ;;
    h)  # show help
        help
        ;;
    \?) # unrecognized option - show help
        print "${C_X}[${C_R}error${C_X}] unrecognized arguments: ${C_R}-$OPTARG${C_X}"
        help
        ;;
  esac
done
shift "$((OPTIND-1))"

function install_environment {
    # install the virtual environment and set the flag to install the dependencies
    python -m $venv_command $env_dir
    install_deps=true
}

function create_or_recreate() {
    # if the virtual environment doesn't exist...
    if [ ! -d $env_dir ]; then
        # create a new one
        print "${C_G}creating virtual environment ${C_B}$env_dir${C_X}"
        install_environment
    # otherwise, if the -r flag was set...
    elif [ "$recreate_env" = true ]; then
        # delete the existing virtual environment
        print "${C_G}recreating virtual environment ${C_B}$env_dir${C_X}"
        rm -r $env_dir
        # create a new virtual environment
        install_environment
    fi
}

function activate () {
    # if we're on windows...
    if [ -f "$pwd/$env_dir/scripts/activate" ]; then
        . "$pwd/$env_dir/scripts/activate"
    # if we're on linux...
    elif [ -f "$pwd/$env_dir/bin/activate" ]; then
        . "$pwd/$env_dir/bin/activate"
    else
        print "${C_R}error: could not locate virtual environment activation script${C_X}"
    fi
}

function install_dependencies() {
    # if we created or recreated the environment, or if the user set the -d flag...
    if [ "$install_deps" = true ] || [ "$install_dev_deps" = true ]; then
        # determine which requirements file we're installing
        [ "$install_dev_deps" = true ] && requirements_file=$requirements_dev || requirements_file=$requirements
        # if the requirements file doesn't exist...
        if [ ! -f "$requirements_file" ]; then
            # nothing more to do
            print "${C_Y}warning: did not find $requirements_file${C_X}"
        else
            # install the requirements from the file
            print "${C_G}installing dependencies from ${C_B}$requirements_file${C_X}"
            pip install -r $requirements_file --quiet --disable-pip-version-check
        fi
    fi
}

create_or_recreate
activate
install_dependencies

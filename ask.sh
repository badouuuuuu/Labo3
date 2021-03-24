#!/bin/bash
#Fichier test pour améloration du script bash createVM.sH

ask() {
    local prompt default reply

    if [[ ${2:-} = 'Y' ]]; then
        prompt='Y/n'
        default='Y'
    elif [[ ${2:-} = 'N' ]]; then
        prompt='y/N'
        default='N'
    else
        prompt=''
        default=''
    fi

    while true; do

        echo -n "$1 [$prompt] "


        read -r reply </dev/tty

        # Default?
        if [[ -z $reply ]]; then
            reply=$default
        fi

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

# Default to Yes if the user presses enter without giving an answer:
if ask "Do you want to start all yours Virtual Machines now?" Y; then
    echo "Yes"
    VBoxManage startvm 'dns' --defaultfrontend headless
else
    ask "Do you want to start a specific Virtual Machines now?" Y;
    vboxmanage list vms
    ask "Type the vm name or uuid" ;
fi

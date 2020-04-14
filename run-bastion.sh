#!/usr/bin/env bash

USER_NAME=damian
PUID=$(id -u $USER_NAME)
PGID=$(id -g $USER_NAME)
TZ=Australia/Melbourne
PUBLIC_KEY=$(cat $(eval echo ~${USER_NAME}/.ssh/authorized_keys))
BASTION_CONFIG_DIR=/etc/bastion
PORT=1234

while getopts "r" OPT; do
    case "$OPT" in
        r)  REBUILD=true
    esac
done

if [[ "$REBUILD" == "true" ]]; then
    echo "* Stopping and destroying Bastion"
    sudo systemctl stop bastion-container.service
    sudo podman stop bastion
    sudo podman rm bastion
fi

echo "* Starting Bastion"
sudo podman run -d \
    --name bastion \
    --hostname bastion \
    --network host \
    -e PUID=$PUID \
    -e PGID=$PGID \
    -e TZ=$TZ \
    -e PUBLIC_KEY="$PUBLIC_KEY" \
    -e SUDO_ACCESS=false \
    -e PASSWORD_ACCESS=false \
    -e USER_NAME=$USER_NAME \
    -p ${PORT}:2222 \
    -v ${BASTION_CONFIG_DIR}:/config:Z \
    -v /run/bastion:/var/run:Z \
    -v /etc/issue.net:/etc/motd \
    linuxserver/openssh-server

if [[ "$REBUILD" == "true" ]]; then
    sudo systemctl start bastion-container.service
fi


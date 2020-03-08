# SSH Bastion Host

## Instructions

Full instructions: https://github.com/linuxserver/docker-openssh-server

Configuration:
```shell script
USER_NAME=damian
PUBLIC_KEY=$(cat $(eval echo ~${USER_NAME}/.ssh/authorized_keys))
PUID=$(id -u $USER_NAME)
PGID=$(id -g $USER_NAME)
TZ=Australia/Melbourne
BASTION_CONFIG_DIR=/etc/bastion
```

Initial  setup only
```shell script
sudo mkdir -p $BASTION_CONFIG_DIR
sudo cp -R custom-cont-init.d $BASTION_CONFIG_DIR/
echo "d /run/bastion 755 root root" | sudo tee /etc/tmpfiles.d/bastion.conf
sudo systemd-tmpfiles --create
```

Run the container on the default port, 2222:
```shell script
sudo podman run -d \
  --name=bastion \
  --hostname=bastion \
  --network=host \
  -e PUID=$PUID \
  -e PGID=$PGID \
  -e TZ=$TZ \
  -e PUBLIC_KEY="$PUBLIC_KEY" \
  -e SUDO_ACCESS=false \
  -e PASSWORD_ACCESS=false \
  -e USER_NAME=$USER_NAME \
  -v ${BASTION_CONFIG_DIR}:/config:Z \
  -v /run/bastion:/var/run:Z \
  -v /etc/issue.net:/etc/motd \
  linuxserver/openssh-server
```

Open the firewall:
```shell script
sudo firewall-cmd --new-service-from-file firewalld/bastion.xml --permanent
sudo firewall-cmd --add-service bastion --permanent
sudo firewall-cmd --reload
```

Add to systemd:
```shell script
sudo cp systemd/bastion-container.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable bastion-container.service
sudo systemctl start bastion-container.service
```


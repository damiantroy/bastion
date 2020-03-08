#!/bin/bash

echo "**** Setting AllowTcpForwarding to yes****"
sed -i 's/^AllowTcpForwarding .*/AllowTcpForwarding yes/g' /etc/ssh/sshd_config

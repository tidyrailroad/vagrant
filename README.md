<!--
    This file is part of vagrant.

    vagrant is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    vagrant is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with vagrant.  If not, see <http://www.gnu.org/licenses/>.
-->

# vagrant

## Usage

```
export WORK &&
    BIN
```

### Preparing the VirtualBox volume

```
(docker \
    run \
    --interactive \
    --rm \
    --volume ${BIN}:/usr/local/src \
    --workdir /usr/local/src \
    alpine:3.4 \
    tee init <<EOF
#!/bin/sh

docker \
    run \
    --cidfile /root/virtualbox.cidfile \
    --detach \
    --volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
    --env DISPLAY \
    --volume /dev/vboxdrv:/dev/vboxdrv:ro \
    --volume \${WORK}:/root \
    --workdir /root \
    --net host \
    tidyrailroad/virtualbox:0.0.0
EOF
) &&
    (docker \
        run \
        --interactive \
        --rm \
        --volume ${BIN}:/usr/local/src \
        --workdir /usr/local/src \
        alpine:3.4 \
        tee VBoxManage <<EOF
#!/bin/sh

docker \
    exec \
    \$(cat /root/virtualbox.cidfile) \
    VBoxManage \
    "\${@}"
EOF
    ) &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume ${BIN}:/root \
        --workdir /root \
        alpine:3.4 \
        chmod 0500 init VBoxManage
```


### Example
Define a script:

```
vagrant(){
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --volume ${WORK}:/root \
        --workdir /root \
        --volume ${BIN}:/usr/local/bin:ro \
        --env VAGRANT_DEFAULT_PROVIDER=virtualbox \
        --env WORK \
        --env DISPLAY \
        --net host \
        --entrypoint bash \
        tidyrailroad/vagrant:0.0.0 \
        ${@}
}
```

Initiate
```
vagrant init hashicorp/precise64
```

Then verify
```
docker run -it --rm --volume ${WORK}:/usr/local/src --workdir /usr/local/src alpine:3.4 cat Vagrantfile
```
should yield
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "hashicorp/precise64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
```

### Start the machine


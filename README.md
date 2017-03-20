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

## Discussion

### Provider Needed

One needs a provider in order to use vagrant.
This image does not contain any.

The most popular provider for beginning usage is VirtualBox.
The [Sample Usage](#sample_usage) shows how to "inject" VirtualBox into the container.

### Docker Containers are One Process

Docker containers are guarded processes.
They run their assigned process and when it is done, they stop.

This can be problematic.
The VirtualBox workflow assumes that we start a virtual machine in its own process.
However, the Docker mindset is that as soon as that happens the container shuts down.

The effect is that `vagrant up` starts a virtual machine and it mysteriously shuts down almost immediately.
The sample usage  \illustrates a kludgey work around.

This is obviously applicable to VirtualBox but is thought to be applicable to most other providers.

### Docker Containers have their own networking

The example uses two containers.
Each network has its own network (in general).
This is a problem because vagrant uses ssh port forwarding.

The kludge solution introducted is to use the host network.

### There can be only one VirtualBox

It is thought that it is not possible to run two or more VirtualBoxes simultaneously.

Ideally we would verify that assumption and if it is true then put in programmatic safeguard that
would prevent that from happening.

The sample code does not.
Remember to shut down VirtualBox when you are finished.

### GUI should not be needed.

The provided sample opens a useless GUI window.
The user does not use it, but it will fail if it is not provided an environment where it can open the window.


## Sample Usage

### Volumes

The sample uses two docker volumes:  WORK and BIN can be created as:

```
export WORK=$(docker volume create) &&
    BIN=$(docker volume create)
```

#### Preparing the BIN volume

The BIN volume is how VirtualBox is injected into the container.
It can be prepared as:

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
    --privileged \
    --detach \
    --volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
    --env DISPLAY \
    --volume /dev/vboxdrv:/dev/vboxdrv:ro \
    --volume \${WORK}:/root \
    --workdir /root \
    --net host \
    tidyrailroad/virtualbox:0.0.0 &&
        yum install --assumeyes openssh-clients wget &&
        wget https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE11/IE11.Win7.Vagrant.zip
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

Basically we are creating two binaryies:  init and VBoxManage.

1. init starts VirtualBox (remember to shut VirtualBox down yourself)
2. VBoxManage is what vagrant uses to control VirtualBox


#### Preparing the WORK volume
You do not need to do anything to prepare WORK.
It is the root directory shared by the vagrant and VirtualBox containers.
This is where download virtual box images will end up.


### A Script
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

## Running a simple example.

1. Log into the vagrant container `vagrant`.
2. Inside the vagrant container start VirtualBox `init`.
   1. Start up vagrant `vagrant init hashicorp/precise64`
   2. Launch the machine `vagrant up`
   3. ssh into the machine `vagrant ssh`

## Running a windows example
1. Log into the vagrant container `vagrant`
2. Inside the vagrant container start VirtualBox `init`
   1. Download the windows virtual machines `wget https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE11/IE11.Win7.Vagrant.zip`
   2. unzip it `unzip IE11.Win7.Vagrant.zip`
   3. import the box `vagrant box import IE11 ...`
   4. vagrant init IE11
   5. edit the Vagrantfile to use the GUI
   6. vagrant up
   7. it will fail b/c it can not ssh into the virtual machine (the Windows VM does not have a running SSH server), but the GUI is up and you can play with that.


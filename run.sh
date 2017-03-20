#!/bin/sh
#
#    This file is part of vagrant.
#
#    vagrant is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    vagrant is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with vagrant.  If not, see <http://www.gnu.org/licenses/>.

yum update --assumeyes &&
    yum install --assumeyes wget &&
    DOWNLOAD_DIR=$(mktemp -d) &&
    wget --output-document ${DOWNLOAD_DIR}/vagrant_1.9.2_x86_64.rpm https://releases.hashicorp.com/vagrant/1.9.2/vagrant_1.9.2_x86_64.rpm?_ga=1.171934121.806233260.1489927479 &&
    yum remove --assumeyes wget &&
    yum update --assumeyes &&
    yum install --assumeyes ${DOWNLOAD_DIR}/vagrant_1.9.2_x86_64.rpm &&
    rm --recursive --force ${DOWNLOAD_DIR} &&
    yum update --assumeyes &&
    yum install --assumeyes docker &&
    yum update --assumeyes &&
    yum clean --assumeyes all

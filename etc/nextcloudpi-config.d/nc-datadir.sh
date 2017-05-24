#!/bin/bash

# Data dir configuration script for NextCloudPi
# Tested with 2017-03-02-raspbian-jessie-lite.img
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
# 
#   ./installer.sh nc-datadir.sh <IP> (<img>)
#
# See installer.sh instructions for details
#
# More at https://ownyourbits.com/2017/03/13/nextcloudpi-gets-nextcloudpi-config/
#

DATADIR_=/media/USBdrive/ncdata
DESCRIPTION="Change your data dir to a new location, like a USB drive"

show_info()
{
  whiptail --yesno \
           --backtitle "NextCloudPi configuration" \
           --title "Info" \
"Note that non Unix filesystems such as NTFS are not supported
because they do not provide a compatible user/permissions system" \
  20 90
}

configure()
{
  local SRCDIR=$( cd /var/www/nextcloud; sudo -u www-data php occ config:system:get datadirectory )
  [ -d $SRCDIR ] || { echo -e "data directory $SRCDIR not found"; return 1; }

  [ -d $DATADIR_ ] && {
    [[ $( find "$DATADIR_" -maxdepth 0 -empty | wc -l ) == 0 ]] && {
      echo "$DATADIR_ is not empty"
      return 1
    }
    rmdir "$DATADIR_" 
  }

  local BASEDIR=$( dirname "$DATADIR_" )
  mkdir -p "$BASEDIR"

  grep -q ext <( stat -fc%T $BASEDIR ) || { echo -e "Only ext filesystems can hold the data directory"; sleep 3; return 1; }

  sudo -u www-data test -x $BASEDIR || { echo -e "ERROR: the user www-data does not have access permissions over $BASEDIR"; sleep 3; return 1; }

  [[ $( stat -fc%d / ) == $( stat -fc%d $BASEDIR ) ]] && \
    echo -e "INFO: moving data dir to another place in the same SD card\nIf you want to use an external mount, make sure it is properly set up"

  service apache2 stop

  cp -ra "$SRCDIR" "$DATADIR_" || return 1
  
  cd /var/www/nextcloud
  sudo -u www-data php occ config:system:set datadirectory --value=$DATADIR_
  service apache2 start
}

install() { :; }
cleanup() { :; }

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA


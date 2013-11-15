#!/bin/sh
#
#
# This file is part of knxd.
#
# ebusd is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ebusd is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ebusd. If not, see http://www.gnu.org/licenses/.
#

BUILD_DIR=/tmp
VERSION='1.0'

cd $BUILD_DIR
printf ">>> Build directory $BUILD_DIR create $BUILD_DIR/ebusd_build\n"
mkdir knxd-build
cd knxd-build

printf ">>> Checkout sources\n"
git clone https://github.com/JuMi2006/knxd.git
cd knxd

printf ">>> Remove hidden files\n"
find $PWD -name .svn -print0 | xargs -0 rm -r
find $PWD -name .gitignore -print0 | xargs -0 rm -r

printf ">>> Create Debian package related files\n"
mkdir trunk
mkdir trunk/DEBIAN
mkdir trunk/etc
mkdir trunk/usr

cp -R etc/* trunk/etc
cp -R usr/* trunk/usr

printf ">>> ../DEBIAN/control\n"
#ARCH=`dpkg --print-architecture`
ARCH="all"
echo "Package: knxd
Version: $VERSION
Section: net
Priority: required
Architecture: $ARCH
Maintainer: Mirko Hirsch <mirko.hirsch@gmx.de>
Depends: liblog-log4perl-perl, libproc-pid-file-perl (>= 1.25), libfile-touch-perl, librrds-perl, libmath-round-perl, libmath-round-perl, libconfig-std-perl, libproc-daemon-perl
Description: Daemon for EIB/KNX/(eBus)\n" > trunk/DEBIAN/control

printf ">>> ../DEBIAN/dirs\n"
echo "usr/sbin
usr/lib/perl5
etc/knxd
etc/knxd/plugin
etc/knxd/tools
etc/default
etc/init.d
etc/logrotate.d" > trunk/DEBIAN/dirs

printf ">>> ../DEBIAN/postinst\n"
echo "#! /bin/sh -e
update-rc.d knxd defaults
/etc/init.d/knxd restart" > trunk/DEBIAN/postinst
chmod +x trunk/DEBIAN/postinst

mkdir knxd-$VERSION
cp -R trunk/* knxd-$VERSION
dpkg -b knxd-$VERSION

printf ">>> Move Package to $BUILD_DIR\n"
mv knxd-$VERSION.deb $BUILD_DIR/knxd-${VERSION}_${ARCH}.deb

printf ">>> Remove Files\n"
cd $BUILD_DIR
rm -R knxd-build

printf ">>> Debian Package created at $BUILD_DIR/knxd-${VERSION}_${ARCH}.deb\n"

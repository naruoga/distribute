#!/bin/bash
#
# Aipo is a groupware program developed by TOWN, Inc.
# Copyright (C) 2004-2016 TOWN, Inc.
# http://www.aipo.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

cd `dirname $0` || exit 1

. ./install.conf
. ./func.conf

if [ "$1" = "update" ]; then
. ./update.conf
fi

#///////////////////////////////////////////////
# Extract jre.
#///////////////////////////////////////////////

tar xvzf $DIST_DIR/$JRE_DIST -C $AIPO_HOME
mv $AIPO_HOME/$JRE_DIST_DIRNAME $JAVA_HOME

#///////////////////////////////////////////////
# Export config file.
#///////////////////////////////////////////////

mkdir -p $AIPO_HOME/conf
cat << BODY > $AIPO_HOME/conf/jre.conf
JAVA_HOME=$JAVA_HOME
BODY

echoInfo "JRE installed to $JAVA_HOME."

#!/bin/bash
#
# Aipo is a groupware program developed by Aimluck,Inc.
# Copyright (C) 2004-2015 Aimluck,Inc.
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

if [ "$1" = "" ]; then
	AIPO_HOME=/usr/local/aipo
else
	AIPO_HOME=$1
fi

if [[ "$AIPO_HOME" =~ ^(/|~) ]]; then
	echo $AIPO_HOME
else
	AIPO_HOME=`pwd`/$AIPO_HOME
	echo $AIPO_HOME
fi

export AIPO_HOME=$AIPO_HOME

rm -rf install.log
sh bin/validate.sh 2>&1 | tee -a install.log
if [ "${PIPESTATUS[0]}" != "0" ]; then { exit 1; } fi

sh bin/jre.sh  2>&1 | tee -a install.log
if [ "${PIPESTATUS[0]}" != "0" ]; then { exit 1; } fi

sh bin/postgres.sh  2>&1 | tee -a install.log
if [ "${PIPESTATUS[0]}" != "0" ]; then { exit 1; } fi

sh bin/tomcat.sh  2>&1 | tee -a install.log
if [ "${PIPESTATUS[0]}" != "0" ]; then { exit 1; } fi

sh bin/aipo.sh 2>&1 | tee -a install.log
if [ "${PIPESTATUS[0]}" != "0" ]; then { exit 1; } fi


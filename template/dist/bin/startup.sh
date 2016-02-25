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

. ./func.conf
. ../conf/jre.conf
. ../conf/tomcat.conf
. ../conf/postgresql.conf
. ../conf/aipo.conf

export JRE_HOME=$JAVA_HOME
export CATALINA_OPTS=$CATALINA_OPTS

echo "Starting Aipo $AIPO_VERSION."

if [ -d $TOMCAT_HOME/work/Catalina/localhost/_ ]; then
	rm -rf $TOMCAT_HOME/work/Catalina/localhost/_
fi
if [ -d $TOMCAT_HOME/work/Catalina/localhost/container ]; then
	rm -rf $TOMCAT_HOME/work/Catalina/localhost/container
fi
cp -rf $AIPO_HOME/backup/xreg/*.xreg $TOMCAT_HOME/webapps/ROOT/WEB-INF/conf/

sudo -u ${POSTGRES_USER} $POSTGRES_HOME/bin/postmaster -D $POSTGRES_HOME/data -i > $TOMCAT_HOME/logs/startup.log 2>&1 &

portListenWait ${POSTGRES_PORT}

sh $TOMCAT_HOME/bin/startup.sh >> $TOMCAT_HOME/logs/startup.log 2>&1


ipaddr=`ip -f inet -o addr | grep -v "127.0.0.1" | cut -d\  -f 7 | cut -d/ -f 1 | awk 'NR == 1'`
if [ "$ipaddr" == "" ]; then
ipaddr="127.0.0.1"
fi

port=":$TOMCAT_PORT"
if [ "$port" == ":80" ]; then
port=
fi

echo "Access URL : http://${ipaddr}${port}"


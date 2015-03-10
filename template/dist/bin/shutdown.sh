#!/bin/sh
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

. ./func.conf
. ../conf/jre.conf
. ../conf/tomcat.conf
. ../conf/postgresql.conf
. ../conf/aipo.conf

export JRE_HOME=$JAVA_HOME
export CATALINA_OPTS=$CATALINA_OPTS

echo "Shutdown Aipo $AIPO_VERSION."

sh $TOMCAT_HOME/bin/shutdown.sh > $TOMCAT_HOME/logs/shutdown.log 2>&1

sudo -u ${POSTGRES_USER} $POSTGRES_HOME/bin/pg_ctl -D $POSTGRES_HOME/data -o "-i -p $POSTGRES_PORT" stop >> $TOMCAT_HOME/logs/shutdown.log 2>&1


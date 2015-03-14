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

. ./install.conf
. ./func.conf
. ./update.conf
. $AIPO_HOME/conf/jre.conf
. $AIPO_HOME/conf/tomcat.conf
. $AIPO_HOME/conf/postgresql.conf
. $AIPO_HOME/conf/aipo.conf

if [ "$1" = "" ]; then
	exit 1
fi

old_version=$1
backup_dir=$AIPO_HOME.backup${TIME}

#///////////////////////////////////////////////
# Copy data.
#///////////////////////////////////////////////

mkdir -p $AIPO_HOME/tomcat/data/

cp -rf $backup_dir/tomcat/webapps/aipo/WEB-INF/files $AIPO_HOME/tomcat/data/
cp -rf $backup_dir/tomcat/webapps/aipo/WEB-INF/mail $AIPO_HOME/tomcat/data/

cp -rf $backup_dir/tomcat/webapps/aipo/WEB-INF/conf/holidays_user.properties $AIPO_HOME/tomcat/webapps/ROOT/WEB-INF/conf/

#///////////////////////////////////////////////
# Restore Database.
#///////////////////////////////////////////////

databaseRestore

#///////////////////////////////////////////////
# Migration Database.
#///////////////////////////////////////////////

startPostgres
portListenWait ${POSTGRES_PORT}
applySQL "7020to8000"
stopPostgres

ipaddr=`ip -f inet -o addr | grep -v "127.0.0.1" | cut -d\  -f 7 | cut -d/ -f 1 | awk 'NR == 1'`
if [ "$ipaddr" == "" ]; then
        ipaddr="127.0.0.1"
fi

port=":$TOMCAT_PORT"
if [ "$port" == ":80" ]; then
        port=
fi

echo ""
echoInfo "============================================="
echoInfo "Aipo のアップデートが完了しました。"
echoInfo "バージョン　　　　　: $AIPO_VERSION"
echoInfo "インストール先　　　: $AIPO_HOME"
echoInfo "PostgreSQLユーザー　: $POSTGRES_USER"
echoInfo "PostgreSQLパスワード: $POSTGRES_PASSWORD"
echo ""
echoInfo "アクセス先:"
echoInfo "http://${ipaddr}${port}"
echo ""
echoInfo "起動方法:"
echoInfo "$AIPO_HOME/bin/startup.sh"
echoInfo "停止方法:"
echoInfo "$AIPO_HOME/bin/shutdown.sh"

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

. bin/update.conf

TIME=`date '+%Y%m%d%H%M%S'`
export TIME

if [ "$1" = "" ]; then
        export AIPO_VERSION=8.1.0.0
        echoError "アップデート先ディレクトリを指定してください。"
        exit 1
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

if [ -f $AIPO_HOME/tomcat/webapps/ROOT/WEB-INF/conf/AipoResources.properties ]; then
	tmp_str=`cat $AIPO_HOME/tomcat/webapps/ROOT/WEB-INF/conf/AipoResources.properties | grep aipo.version=`
	old_version=`echo "$tmp_str" | cut -f 2 -d "="`
else
	export AIPO_VERSION=8.1.0.0
	echoError "指定されたディレクトリに Aipo がインストールされていません。"
	exit 1
fi

if [ "$old_version" != "8.0.1.0" ]; then
	export AIPO_VERSION=8.1.0.0
	echoError "このアップデータは Aipo 8.0.1.0 で動作します。"
	exit 1
fi

rm -rf update.log
sh bin/validate.sh update 2>&1 | tee -a update.log
if [ "${PIPESTATUS[0]}" != "0" ]; then { exit 1; } fi

export UPDATE_START=1

(cd $AIPO_HOME/bin; sh shutdown.sh)

rm -rf $TMP_DIR
mkdir -p $TMP_DIR
chmod 777 $TMP_DIR

OLD_POSTGRES_USER=`cat ${AIPO_HOME}/tomcat/datasource/dbcp-org001.properties | sed -ne 's/^cayenne\.dbcp\.username=\([A-Za-z0-9]*\)/\1/gp' | tr -d '\r' | tr -d '\n'`
OLD_POSTGRES_PASS=`cat ${AIPO_HOME}/tomcat/datasource/dbcp-org001.properties | sed -ne 's/^cayenne\.dbcp\.password=\([A-Za-z0-9]\)/\1/gp' | tr -d '\r' | tr -d '\n'`
OLD_POSTGRES_PORT=`cat ${AIPO_HOME}/tomcat/datasource/dbcp-org001.properties | sed -ne 's/^cayenne\.dbcp\.url=.*:\([0-9]\+\)\/.*$/\1/gp' | tr -d '\r' | tr -d '\n'`

export OLD_POSTGRES_USER
export OLD_POSTGRES_PASS
export OLD_POSTGRES_PORT

databaseBackup

mv $AIPO_HOME ${AIPO_HOME}.backup${TIME}

if [ -e $AIPO_HOME ]; then
        echoError "$AIPO_HOME ディレクトリに Aipo がインストールされています。"
        exit 1
else
        mkdir -p $AIPO_HOME || { echoError "$AIPO_HOME ディレクトリが作成できませんでした。"; exit 1; }
fi

sh bin/jre.sh update  2>&1 | tee -a update.log
if [ "${PIPESTATUS[0]}" != "0" ]; then { exit 1; } fi

sh bin/postgresql.sh update 2>&1 | tee -a update.log
if [ "${PIPESTATUS[0]}" != "0" ]; then { exit 1; } fi

sh bin/tomcat.sh upadate 2>&1 | tee -a update.log
if [ "${PIPESTATUS[0]}" != "0" ]; then { exit 1; } fi

sh bin/aipo.sh update 2>&1 | tee -a update.log
if [ "${PIPESTATUS[0]}" != "0" ]; then { exit 1; } fi

sh bin/major-update.sh $old_version 2>&1 | tee -a update.log
if [ "${PIPESTATUS[0]}" != "0" ]; then { exit 1; } fi


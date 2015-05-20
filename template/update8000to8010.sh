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

. bin/update.conf

TIME=`date '+%Y%m%d%H%M%S'`
export TIME
export AIPO_VERSION=8.0.1.0

if [ "$1" = "" ]; then
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

if [ -f $AIPO_HOME/tomcat/webapps/aipo/WEB-INF/conf/AipoResources.properties ]; then
	tmp_str=`cat $AIPO_HOME/tomcat/webapps/aipo/WEB-INF/conf/AipoResources.properties | grep aipo.version=`
	old_version=`echo "$tmp_str" | cut -f 2 -d "="`
else
	if [ -f $AIPO_HOME/tomcat/webapps/ROOT/WEB-INF/conf/AipoResources.properties ]; then
        	tmp_str=`cat $AIPO_HOME/tomcat/webapps/ROOT/WEB-INF/conf/AipoResources.properties | grep aipo.version=`
        	old_version=`echo "$tmp_str" | cut -f 2 -d "="`
	else
        	echoError "指定されたディレクトリに Aipo がインストールされていません。"
        	exit 1
	fi
fi


if [ "$old_version" != "8.0.0.0" ]; then
	echoError "このアップデータは Aipo 8.0.0.0 で動作します。"
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

mv $AIPO_HOME/tomcat/webapps ${AIPO_HOME}/tomcat/webapps.backup${TIME}

export AIPO_NEW_VERSION=$AIPO_VERSION

sh bin/minor-update.sh $old_version 2>&1 | tee -a update.log
if [ "${PIPESTATUS[0]}" != "0" ]; then { exit 1; } fi

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
. ../conf/postgres.conf
. ../conf/aipo.conf

date_dir=`date +"%Y%m%d%H%M"`
count=0
tmp_dir=$date_dir
while [ $count -lt 100 ]; do
	test -d $tmp_dir
	tmp_str=$?
	if [ $tmp_str = 0 ]; then
		tmp_dir="$date_dir"$count
	else
		break
	fi
	let count=`expr $count + 1`
	if [ $count -ge 99 ]; then
		echoError "ディレクトリ生成中にエラーが発生しました。"
		exit 1
	fi
done
bg_dir=$date_dir$count
mkdir -p $AIPO_HOME/backup/$bg_dir
wait
chmod 757 $AIPO_HOME/backup/$bg_dir

sh $TOMCAT_HOME/bin/shutdown.sh
wait

hasError=0
sudo -u ${POSTGRES_USER} $AIPO_HOME/postgres/bin/pg_dump -c -b -o -Fp -U ${POSTGRES_USER} -p $POSTGRES_PORT -f $AIPO_HOME/backup/$bg_dir/aipo_db_sql.dump org001 > $AIPO_HOME/backup/dump1.log 2>&1 || { echoError "データベースダンプ中にエラーが発生しました。"; exit 1 }
sudo -u ${POSTGRES_USER} $AIPO_HOME/postgres/bin/pg_dump -c -b -o -Fc -U ${POSTGRES_USER} -p $POSTGRES_PORT -f $AIPO_HOME/backup/$bg_dir/aipo_db.dump org001 > $AIPO_HOME/backup/dump2.log 2>&1 || { echoError "データコピー中にエラーが発生しました。"; exit 1 }

mkdir -p $TOMCAT_HOME/data/files
mkdir -p $TOMCAT_HOME/data/mail
cp -rf $TOMCAT_HOME/data/files $AIPO_HOME/backup/$bg_dir/ || { echoError "データコピー中にエラーが発生しました。"; exit 1 }
cp -rf $TOMCAT_HOME/data/mail $AIPO_HOME/backup/$bg_dir/ || { echoError "データコピー中にエラーが発生しました。"; exit 1 }

cat << BODY > $AIPO_HOME/backup/$bg_dir/version.txt
[System]
version=$AIPO_VERSION
BODY

CATALINA_OPTS="-server -Xmx512M -Xms64M -Xss256k -Djava.awt.headless=true -Dsun.nio.cs.map=x-windows-iso2022jp/ISO-2022-JP"
sh $TOMCAT_HOME/bin/startup.sh

echoInfo "Aipo のバックアップが完了しました。"

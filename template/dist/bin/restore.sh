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

function listfunc {
	unset count
	for DIR in $*
	do
		count=`expr $count + 1`
		echo "[$count] `expr substr $DIR 1 4`年`expr substr $DIR 5 2`月`expr substr $DIR 7 2`日`expr substr $DIR 9 2`時`expr substr $DIR 11 2`分"
	done
	echo "[0] キャンセル"
	echoInfo "バックアップファイルを選んで番号を入力してください。"
	read select
	if [ $select = "0" ]; then
		echoError "リストアはキャンセルされました。"
		exit 1
	fi


	let str=`echo $* | cut -f $select -d " " `
	if [ `expr length "$str"` -le 0 ]; then
		listfunc $list
	fi
}

cd $AIPO_HOME/backup
list=`ls | grep ............[0-9]`
if [ `expr length "$list"` -le 0 ]; then
	echoError "バックアップファイルが見つかりません。"
	exit 1
fi

listfunc $list
bg_dir=$str

vsnc=$AIPO_VERSION
isCR=`expr match $vsnc .*[0-9]$ `
if [ "$isCR" = "0" ]; then
    len=`expr length $vsnc`
    len=`expr $len - 1`
    vsn=`expr substr $vsnc 1 $len`
fi

tmp_str=`grep "=" "$AIPO_HOME/backup/$bg_dir/version.txt"`
vsn=`echo "$tmp_str" | cut -f 2 -d "=" - `
isCR=`expr match $vsn .*[0-9]$ `
if [ "$isCR" = "0" ]; then
    len=`expr length $vsn`
    len=`expr $len - 1`
    vsn=`expr substr $vsn 1 $len`
fi

echo "Version $vsn"
if [ $vsn !=  $vsnc ]; then
	echoError "バックアップファイルのバージョンが一致しません。"
	exit 1
fi

sh $TOMCAT_HOME/bin/shutdown.sh
wait
sudo -u ${POSTGRES_USER} $AIPO_HOME/postgres/bin/pg_restore -Fc -c -U $POSTGRES_USER -p $POSTGRES_PORT $AIPO_HOME/backup/$bg_dir/aipo_db.dump -d org001

if [ $? -ne 0 ]; then
	echoError "リストアに失敗しました。";
else
	rm -rf $TOMCAT_HOME/data/*
	cp -rf $AIPO_HOME/backup/$bg_dir/files $TOMCAT_HOME/data/
	cp -rf $AIPO_HOME/backup/$bg_dir/mail $TOMCAT_HOME/data/
fi

wait

CATALINA_OPTS="-server -Xmx512M -Xms64M -Xss256k -Djava.awt.headless=true -Dsun.nio.cs.map=x-windows-iso2022jp/ISO-2022-JP"
sh $TOMCAT_HOME/bin/startup.sh

echoInfo "Aipo のリストアが完了しました。"

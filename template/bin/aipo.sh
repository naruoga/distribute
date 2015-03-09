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

. ./install.conf
. ./func.conf
. $AIPO_HOME/conf/jre.conf
. $AIPO_HOME/conf/tomcat.conf
. $AIPO_HOME/conf/postgres.conf

#///////////////////////////////////////////////
# Extract Aipo.
#///////////////////////////////////////////////

mkdir -p $TOMCAT_HOME/webapps/ROOT
unzip -o $DIST_DIR/$AIPO_WAR -d $TOMCAT_HOME/webapps/ROOT

mkdir -p $TOMCAT_HOME/webapps/container
unzip -o $DIST_DIR/$CONTAINER_WAR -d $TOMCAT_HOME/webapps/container

mkdir -p $AIPO_HOME/backup/xreg
cp -rf $TOMCAT_HOME/webapps/ROOT/WEB-INF/conf/*.xreg  $AIPO_HOME/backup/xreg

cp -rf $DIST_DIR/$POSTGRES_DRIVER $TOMCAT_HOME/lib/

mkdir -p $TOMCAT_HOME/datasource
cp -rf $TOMCAT_HOME/webapps/ROOT/WEB-INF/datasource/dbcp-org001.properties  $TOMCAT_HOME/datasource/

mkdir -p $TOMCAT_HOME/data

mkdir -p $AIPO_HOME/bin
cp -rf $DIST_DIR/bin/* $AIPO_HOME/bin/
chmod +x $AIPO_HOME/bin/*.sh

#///////////////////////////////////////////////
# Configure webapps.
#///////////////////////////////////////////////

sed -i "s/localhost:5432/localhost:${POSTGRES_PORT}/g" $TOMCAT_HOME/datasource/dbcp-org001.properties
sed -i "s/cayenne.dbcp.password=aipo/cayenne.dbcp.password=${POSTGRES_PASSWORD}/g" $TOMCAT_HOME/datasource/dbcp-org001.properties
sed -i "s/cayenne.dbcp.username=postgres/cayenne.dbcp.username=${POSTGRES_USER}/g" $TOMCAT_HOME/datasource/dbcp-org001.properties

seed="0123456789abcdefghijklmnopqrstuvwxyz"
key=""
count=0
while [ $count -lt 128 ]; do
        ran=`expr $RANDOM % 36 + 1`
        char=`expr substr $seed $ran 1`
        key=$key$char
        count=`expr $count + 1`
done
echo -n $key > $TOMCAT_HOME/webapps/ROOT/WEB-INF/conf/securityTokenKey.txt
echo -n $key > $TOMCAT_HOME/webapps/container/WEB-INF/classes/aipo/securityTokenKey.txt

#///////////////////////////////////////////////
# Start PostgreSQL.
#///////////////////////////////////////////////

cd $AIPO_HOME
sudo -u ${POSTGRES_USER} $POSTGRES_HOME/bin/postmaster -D $POSTGRES_HOME/data -i &
cd -

portListenWait ${POSTGRES_PORT}

#///////////////////////////////////////////////
# Create database.
#///////////////////////////////////////////////

tmp_dir=/tmp/.aipo.`date '+%Y%m%d'`
mkdir -p $tmp_dir
cp -rf $DIST_DIR/sql/org001.sql $tmp_dir/org001.sql
cd $AIPO_HOME
#sudo -u ${POSTGRES_USER} $POSTGRES_HOME/bin/createdb org001 -O ${POSTGRES_USER} -U ${POSTGRES_USER}
#sudo -u ${POSTGRES_USER} $POSTGRES_HOME/bin/psql -U ${POSTGRES_USER} -d org001 -p $POSTGRES_PORT -f $tmp_dir/org001.sql
cd -
rm -rf $tmp_dir

#///////////////////////////////////////////////
# Configure PostgreSQL.
#///////////////////////////////////////////////

cp $POSTGRES_HOME/data/pg_hba.conf $POSTGRES_HOME/data/pg_hba.conf~
sudo -u ${POSTGRES_USER} echo "alter user ${POSTGRES_USER} with password '$POSTGRES_PASSWORD';" | $POSTGRES_HOME/bin/psql -U ${POSTGRES_USER} -d org001 -p $POSTGRES_PORT

chown ${POSTGRES_USER}:${POSTGRES_USER} $POSTGRES_HOME/data/pg_hba.conf
sudo -u ${POSTGRES_USER} sed -i "s/ trust/ password/g" $POSTGRES_HOME/data/pg_hba.conf

sudo -u ${POSTGRES_USER} echo "localhost:$POSTGRES_PORT:org001:${POSTGRES_USER}:$POSTGRES_PASSWORD" > /home/${POSTGRES_USER}/.pgpass
chown ${POSTGRES_USER}:${POSTGRES_USER} /home/${POSTGRES_USER}/.pgpass
sudo -u ${POSTGRES_USER} chmod 0600 /home/${POSTGRES_USER}/.pgpass

#///////////////////////////////////////////////
# Stop PostgreSQL.
#///////////////////////////////////////////////

cd $AIPO_HOME
sudo -u ${POSTGRES_USER} $POSTGRES_HOME/bin/pg_ctl -D $POSTGRES_HOME/data -o "-i -p $POSTGRES_PORT" stop
cd -

#///////////////////////////////////////////////
# System settings.
#///////////////////////////////////////////////

export TZ=JST-9
date=`date '+%Y%m%d'`
mv /etc/localtime /etc/localtime."$date".bak
cp -rf /usr/share/zoneinfo/Japan /etc/localtime

#///////////////////////////////////////////////
# Export config file.
#///////////////////////////////////////////////

mkdir -p $AIPO_HOME/conf
cat << BODY > $AIPO_HOME/conf/aipo.conf
AIPO_VERSION=$AIPO_VERSION
AIPO_HOME=$AIPO_HOME
BODY


ipaddr=`ip -f inet -o addr | grep -v "127.0.0.1" | cut -d\  -f 7 | cut -d/ -f 1 | awk 'NR == 1'`
if [ "$ipaddr" == "" ]; then
	ipaddr="127.0.0.1"
fi

port=":$TOMCAT_PORT"
if [ "$port" == ":80" ]; then
	port=
fi

echo ""
echoIndo "============================================="
echoInfo "Aipo のインストールが完了しました。"
echoInfo "バージョン　　　　　: $AIPO_VERSION"
echoInfo "インストール先　　　: $AIPO_HOME"
echoInfo "PostgreSQLユーザー　: $POSTGRES_USER"
echoInfo "PostgreSQLパスワード: $POSTGRES_PASSWORD"
echoInfo "アクセス先　　　　　: http://${ipaddr}${port}"
echo ""
echoInfo "起動方法:"
echoInfo "$AIPO_HOME/bin/startup.sh"
echoInfo "停止方法:"
echoInfo "$AIPO_HOME/bin/shutdown.sh"


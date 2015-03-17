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

if [ "$1" = "update" ]; then
. ./update.conf
fi

#///////////////////////////////////////////////
# Extract tomcat.
#///////////////////////////////////////////////

tar xvzf $DIST_DIR/$TOMCAT_DIST -C $AIPO_HOME
mv $AIPO_HOME/$TOMCAT_DIST_DIRNAME $TOMCAT_HOME

rm -rf $TOMCAT_HOME/webapps/*

#///////////////////////////////////////////////
# Port check not used.
#///////////////////////////////////////////////

unset tmp_str
flag_1="0"
count="0"
while [ 1 ]; do
	unset tmp_str
	nmap -p $TOMCAT_PORT localhost | grep open > /dev/null
	if [ $? = 0 ]; then
		flag_2="0"
	else
		unset tmp_str
		tmp_str=`grep -x "$TOMCAT_PORT" ./servlist`
			if [ "$tmp_str" != "$TOMCAT_PORT" ]; then
			break
		fi
	fi

	count=`expr $count + 1`
	TOMCAT_PORT=`expr $TOMCAT_PORT + $count`

	if [ $count -ge 100 ]; then
		echo "error occurred during the port check."
		exit 1
	fi
done

unset tmp_str
flag_1="0"
count="0"
while [ 1 ]; do
	unset tmp_str
	nmap -p $TOMCAT_SHUTDOWN_PORT localhost | grep open > /dev/null
	if [ $? = 0 ]; then
		flag_2="0"
	else
		unset tmp_str
		tmp_str=`grep -x "$TOMCAT_SHUTDOWN_PORT" ./servlist`
			if [ "$tmp_str" != "$TOMCAT_SHUTDOWN_PORT" ]; then
			break
		fi
	fi

	count=`expr $count + 1`
	TOMCAT_SHUTDOWN_PORT=`expr $TOMCAT_SHUTDOWN_PORT + $count`

	if [ $count -ge 100 ]; then
                echo "error occurred during the port check."
		exit 1
	fi
done

#///////////////////////////////////////////////
# Configure.
#///////////////////////////////////////////////

sed -i 's|protocol="HTTP/1.1"|protocol="org.apache.coyote.http11.Http11NioProtocol"|g' $TOMCAT_HOME/conf/server.xml
sed -i "s|port=\"8080\"|port=\"$TOMCAT_PORT\"|g" $TOMCAT_HOME/conf/server.xml
sed -i "s|port=\"8005\"|port=\"$TOMCAT_SHUTDOWN_PORT\"|g" $TOMCAT_HOME/conf/server.xml
sed -i "s|<session-timeout>30</session-timeout>|<session-timeout>180</session-timeout>|g" $TOMCAT_HOME/conf/web.xml
tmp_str='<Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />'
sed -i 's|$tmp_str|<!--$tmp_str-->|g' $TOMCAT_HOME/conf/server.xml
echo "user.timezone=Asia/Tokyo" >> $TOMCAT_HOME/conf/catalina.properties

#///////////////////////////////////////////////
# Export config file.
#///////////////////////////////////////////////

mkdir -p $AIPO_HOME/conf
cat << BODY > $AIPO_HOME/conf/tomcat.conf
TOMCAT_HOME=$TOMCAT_HOME
TOMCAT_PORT=$TOMCAT_PORT
TOMCAT_SHUTDOWN_PORT=$TOMCAT_SHUTDOWN_PORT
BODY

echoInfo "Tomcat installed to $TOMCAT_HOME."

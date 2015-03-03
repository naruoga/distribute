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


#///////////////////////////////////////////////
# Check user.
#///////////////////////////////////////////////

current_user=`whoami`
if [ "${current_user}" != "root" ]; then
	echoError "インストールはroot権限で行ってください。"
	exit 1
fi

mkdir -p $AIPO_HOME-$AIPO_VERSION
tmp_str=`ls $AIPO_HOME-$AIPO_VERSION`
if [ "$tmp_str" != "" ]; then
        echoError "$AIPO_HOME-$AIPO_VERSION ディレクトリを空にしてください。"
        exit 1
fi

if [ -L $AIPO_HOME ]; then
        TMP_AIPO_HOME_LINK=`readlink $AIPO_HOME`
        unlink $AIPO_HOME
else
if [ -d $AIPO_HOME ]; then
        echoError "$AIPO_HOME ディレクトリにAipoがインストールされています。"
	exit 1
fi
fi

ln -s $AIPO_HOME-$AIPO_VERSION $AIPO_HOME

$tmp_packages
if [ -x /usr/bin/gcc ]; then
	echo "gcc OK."
else
        tmp_packages=$tmp_packages"gcc "
fi

if [ -x /usr/bin/nmap ]; then
	echo "nmap OK."
else
        tmp_packages=$tmp_packages"nmap "
fi

if [ -x /usr/sbin/lsof ]; then
	echo "lsof OK."
else
        tmp_packages=$tmp_packages"lsof "
fi

if [ -x /usr/bin/unzip ]; then
	echo "unzip OK."
else
        tmp_packages=$tmp_packages"unzip "
fi

if [ -f "/usr/include/readline/readline.h" ]; then
	echo "readline-devel OK."
else
	tmp_packages=$tmp_packages"readline-devel "
fi

if [ -f "/usr/include/zlib.h" ]; then
	echo "zlib-devel OK."
else
        tmp_packages=$tmp_packages"readline-devel "
fi

if [ "$tmp_packages" != "" ]; then
	echoError "以下のパッケージをインストールしてください。"
	if [ -x /usr/bin/yum ]; then
		echo "yum install $tmp_packages"
	else
	if [ -x /usr/bin/apt-get ]; then
		echo "apt-get install $tmp_packages"
	else
		echo $tmp_packages
	fi
	fi
	exit 1
fi


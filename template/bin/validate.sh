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

. ./install.conf
. ./func.conf

if [ "$1" = "update" ]; then
. ./update.conf
fi

#///////////////////////////////////////////////
# Check bit.
#///////////////////////////////////////////////

tmp_bit=`getconf LONG_BIT`
if [ "$tmp_bit" != "$LONG_BIT" ]; then
    echoError "$tmp_bit 版のインストーラ・アップデータを利用してください。"
    exit 1
fi


#///////////////////////////////////////////////
# Check user.
#///////////////////////////////////////////////

current_user=`whoami`
if [ "${current_user}" != "root" ]; then
	echoError "インストールはroot権限で行ってください。"
	exit 1
fi

#///////////////////////////////////////////////
# Check package.
#///////////////////////////////////////////////

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
        tmp_packages=$tmp_packages"zlib-devel "
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


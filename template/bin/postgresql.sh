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

#///////////////////////////////////////////////
# Whether PostgreSQL user exists.
#///////////////////////////////////////////////

unset tmp_str
tmp_str=`grep ${POSTGRES_USER} /etc/passwd`
tmp_user=${POSTGRES_USER}
count=0
tmp_user=${POSTGRES_USER}
while [ 1 ]; do
	tmp_str=`grep $tmp_user /etc/passwd`
	if [ "$tmp_str" != "" ];
	then
		tmp_user=${POSTGRES_USER}$count
		unset tmp_str
	else
		break
	fi
	count=`expr $count + 1`
	if [ $count -ge 100 ]; then
		echoError "error occurred during the user name generation."
		exit 1
	fi
done
POSTGRES_USER=$tmp_user

#///////////////////////////////////////////////
# Generate password for PostgreSQL.
#///////////////////////////////////////////////

str_seed1="abcdefghijklmnopqrstuvwxyz"
str_seed2="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
str_seed3="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
str_seed4="0123456789"
str_seed5="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

POSTGRES_PASSWORD=""
count=0
while [ $count -lt 1 ]; do
	ran=`expr $RANDOM % 26 + 1`
	char=`expr substr $str_seed1 $ran 1`
	POSTGRES_PASSWORD=$POSTGRES_PASSWORD$char
	count=`expr $count + 1`
done
count=0
while [ $count -lt 2 ]; do
	ran=`expr $RANDOM % 10 + 1`
	char=`expr substr $str_seed4 $ran 1`
	POSTGRES_PASSWORD=$POSTGRES_PASSWORD$char
	count=`expr $count + 1`
done
count=0
while [ $count -lt 4 ]; do
	ran=`expr $RANDOM % 62 + 1`
	char=`expr substr $str_seed5 $ran 1`
	POSTGRES_PASSWORD=$POSTGRES_PASSWORD$char
	count=`expr $count + 1`
done
count=0
while [ $count -lt 3 ]; do
	ran=`expr $RANDOM % 26 + 1`
	char=`expr substr $str_seed2 $ran 1`
	POSTGRES_PASSWORD=$POSTGRES_PASSWORD$char
	count=`expr $count + 1`
done
count=0
while [ $count -lt 2 ]; do
	ran=`expr $RANDOM % 52 + 1`
	char=`expr substr $str_seed3 $ran 1`
	POSTGRES_PASSWORD=$POSTGRES_PASSWORD$char
	count=`expr $count + 1`
done

#///////////////////////////////////////////////
# Create PostgreSQL user.
#///////////////////////////////////////////////

unset tmp_str
tmp_str=`grep ${POSTGRES_USER} /etc/group`
if [ "${tmp_str}" != "" ]; then
		echo "group ${POSTGRES_USER} exists."
	else
		groupadd ${POSTGRES_USER}
fi

useradd ${POSTGRES_USER} -g ${POSTGRES_USER}
ADD_USER=1

echo ${POSTGRES_USER}:$POSTGRES_PASSWORD | chpasswd
if [ -d /home/${POSTGRES_USER} ]; then
	echo "home directory exists."
else
	mkdir -p /home/${POSTGRES_USER}
	if [ -s  /etc/skel/.bashrc ]; then
		cp /etc/skel/.bashrc /home/${POSTGRES_USER}/
	else
		touch /home/${POSTGRES_USER}/.bashrc
	fi
	if [ -s /etc/skel/.bash_profile ]; then
		cp /etc/skel/.bash_profile /home/${POSTGRES_USER}/
	else
		touch /home/${POSTGRES_USER}/.bash_profile
	fi

	chown ${POSTGRES_USER}:${POSTGRES_USER} /home/${POSTGRES_USER}/.bashrc
	chown ${POSTGRES_USER}:${POSTGRES_USER} /home/${POSTGRES_USER}/.bash_profile
fi
chown ${POSTGRES_USER}:${POSTGRES_USER} /home/${POSTGRES_USER}

echo "${POSTGRES_USER} created."

#///////////////////////////////////////////////
# Port check not used.
#///////////////////////////////////////////////

unset tmp_str
flag_1="0"
count="0"
while [ 1 ]; do
	unset tmp_str
	nmap -p $POSTGRES_PORT localhost | grep open > /dev/null
	if [ $? = 0 ]; then
		flag_2="0"
	else
		unset tmp_str
		tmp_str=`grep -x "$POSTGRES_PORT" ./servlist`
			if [ "$tmp_str" != "$POSTGRES_PORT" ]; then
			break
		fi
	fi

	count=`expr $count + 1`
	POSTGRES_PORT=`expr $POSTGRES_PORT + $count`

	if [ $count -ge 100 ]; then
                echoError "error occurred during the port check."
        	userdel -r ${POSTGRES_USER}
		exit 1
	fi
done

#//////////////////////////////////////////////////
# Delete PostgreSQL tmp file, lock file if exsists.
#//////////////////////////////////////////////////

tmp_file=/tmp/.s.PGSQL.$POSTGRES_PORT
lock_file=/tmp/.s.PGSQL.$POSTGRES_PORT.lock

if [ -e $tmp_file ]; then
  rm -f $tmp_file
fi

if [ -f $lock_file ]; then
  rm -f $lock_file
fi

#//////////////////////////////////////////////////
# Build PostgreSQL.
#//////////////////////////////////////////////////

mkdir -p $POSTGRES_HOME
chown -R ${POSTGRES_USER}:${POSTGRES_USER} $POSTGRES_HOME

tmp_dir=/tmp/.aipo.`date '+%Y%m%d'`
mkdir -p $tmp_dir
tar xvzf $DIST_DIR/$POSTGRES_SRC -C $tmp_dir

cd $tmp_dir/$POSTGRES_SRC_DIRNAME

sudo -u ${POSTGRES_USER} ./configure --prefix=$POSTGRES_HOME --with-pgport=$POSTGRES_PORT || { echoError "error occurred during the configure."; exit 1; }

sudo -u ${POSTGRES_USER} make all || { echoError "error occurred during the make."; exit 1; }

make install || { echoError "error occurred during the make install."; exit 1; }
cd -

rm -rf $tmp_dir

#///////////////////////////////////////////////
# Initdb.
#///////////////////////////////////////////////

mkdir -p $POSTGRES_HOME/data
chown ${POSTGRES_USER}:${POSTGRES_USER} $POSTGRES_HOME/data
rm -rf $POSTGRES_HOME/data/*
sudo -u ${POSTGRES_USER} $POSTGRES_HOME/bin/initdb --encoding=UTF8 --no-locale --pgdata=$POSTGRES_HOME/data

tmp_str=`grep "#port =" $POSTGRES_HOME/data/postgresql.conf`

chown ${POSTGRES_USER}:${POSTGRES_USER} $POSTGRES_HOME/data/postgresql.conf
sudo -u ${POSTGRES_USER} sed -i "s/$tmp_str/port = $POSTGRES_PORT/g" $POSTGRES_HOME/data/postgresql.conf

#///////////////////////////////////////////////
# Setting env.
#///////////////////////////////////////////////

sudo -u ${POSTGRES_USER} cp -rf /home/${POSTGRES_USER}/.bash_profile /home/${POSTGRES_USER}/.bash_profile~

cat << BODY >> /home/${POSTGRES_USER}/.bash_profile
export PATH=$POSTGRES_HOME/bin:"$PATH"
export POSTGRES_HOME=$POSTGRES_HOME
export PGLIB=$POSTGRES_HOME/lib
export PGDATA=$POSTGRES_HOME/data
export MANPATH="$MANPATH":$POSTGRES_HOME/man
export LD_LIBRARY_PATH=/usr/local/lib:"$LD_LIBRARY_PATH":"$PGLIB"
BODY

#///////////////////////////////////////////////
# Export config file.
#///////////////////////////////////////////////

mkdir -p $AIPO_HOME/conf
cat << BODY > $AIPO_HOME/conf/postgresql.conf
POSTGRES_HOME=$POSTGRES_HOME
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_PORT=$POSTGRES_PORT
BODY

echoInfo "PostgreSQL installed to $POSTGRES_HOME."

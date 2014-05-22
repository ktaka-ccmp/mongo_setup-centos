#!/bin/bash

usage(){
	echo "Usage: setup.sh port_number"
	echo "\"$1\" must be an integer within [$PORT_MIN...$PORT_MAX]"
	exit 1
}

setup(){

	[ "$svc" = "" ] && echo "Function Error" && exit 1

	DIRS="/var/lib/mongo.$svc /var/log/mongo.$svc"

	for dir in $DIRS ; do
		mkdir -p $dir && chown -R mongod.mongod $dir
		[ ! -d $dir ] && echo Error: Could not make $dir 
	done

	FILES="etc/mongod.$svc.conf etc/init.d/mongod.$svc"

	for file in $FILES ; do
       		[ -f /$file ] && mv /$file /$file.$(date +"%Y%m%d%H%M" -r /$file)
		cp -p $file /$file
	done

	chkconfig --add mongod.$svc
	chkconfig --list mongod.$svc > /dev/null || echo Error: Could not register $svc
}

genfile(){
	if [ ! -f $file ] ; then
		echo Generating $file
		sed -e "s/%port%/$svc/g" $template > $file
	fi
}

genfiles(){
	file=./etc/mongod.$svc.conf
	template=./etc/mongod.templ.conf
	genfile

	file=./etc/init.d/mongod.$svc
	template=./etc/init.d/mongod.templ
	genfile
	
	chmod 755 $file

#exit 0 #for testing
}

[ ! -d ./etc ] && echo Error: ./etc not found! && exit 1

PORT_MIN=1024
PORT_MAX=65535

[[ ! $1 =~ ^-?[0-9]+$ ]]  && usage $1
if ! (( $PORT_MIN <= $1 && $1 <= $PORT_MAX )); then usage $1 ; fi

SERVICES=$1

DIRS="/var/run/mongodb/ "

for dir in $DIRS ; do
	[ ! -d $dir ] && mkdir -p $dir && chown -R mongod.mongod $dir
	[ ! -d $dir ] && echo Error: Could not make $dir
done

for svc in $SERVICES ; do 
	echo [$svc]
	genfiles
	setup 

	echo -e "\tEverything is OK."
	echo -e "\tStarting Command: service mongod.$svc start"
done


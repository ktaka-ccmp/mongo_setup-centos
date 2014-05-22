#!/bin/bash

SERVICES="feed putter"
#SERVICES="feed"
#SERVICES="putter"

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


[ ! -d ./etc ] && echo Error: ./etc not found! && exit 1

DIRS="/var/run/mongodb/ "

for dir in $DIRS ; do
	[ ! -d $dir ] && mkdir -p $dir && chown -R mongod.mongod $dir
	[ ! -d $dir ] && echo Error: Could not make $dir
done

for svc in $SERVICES ; do 
	echo [$svc]
	setup 

	echo -e "\tEverything is OK."
	echo -e "\tStarting Command: service mongod.$svc start"
done


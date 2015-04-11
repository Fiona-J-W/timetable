#!/bin/sh

DEBUG_ARGS="-d -g -unittest -debug"
RELEASE_ARGS="-O -inline -release"

ARGS="-w"

#LIBS="-L-lpthread -L-lrt"

if [[ $# > 0 ]]; then
	if [[ $1 == "-d"  || $1 == "--debug" ]]; then
		ARGS=$ARGS" "$DEBUG_ARGS
	elif [[ $1 == "-r" || $1 == "--release" ]];then
		ARGS=$ARGS" "$RELEASE_ARGS
	else # default to debugmode
		ARGS=$ARGS" "$DEBUG_ARGS
	fi
fi

if test ! -d "build"; then
	mkdir "build"
fi

if test ! -d "doc"; then
	mkdir "doc"
fi

dmd -D -Dddoc -odbuild $ARGS src/*.d $LIBS -oftimetable 
#ldc2 -D -Dd=doc -od=build $ARGS src/*.d $LIBS -of=timetable 

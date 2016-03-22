#!/bin/sh

OCAML=/usr/bin/ocaml
QBE=lisc
TMP=`mktemp -d abifuzz.XXXXXX`

failure() {
	echo "Failure at stage:" $1 >&2
	exit 1
}

once() {
	if test -z "$1"
	then
		$OCAML tools/abi.ml $TMP c ssa
	else
		$OCAML tools/abi.ml -s $1 $TMP c ssa
	fi

	./$QBE -o $TMP/callee.s $TMP/callee.ssa ||
		failure "qbe"

	c99 -g -o $TMP/abitest $TMP/caller.c $TMP/callee.s ||
		failure "cc + linking"

	$TMP/abitest ||
		failure "runtime"
}

if ! test -x $QBE
then
	echo "error: I must run in the directory containing $QBE." >&2
	exit 1
fi

once "$1"
rm -fr $TMP
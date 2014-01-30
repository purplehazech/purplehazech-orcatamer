#!/bin/sh

find 	manifests/site.pp \
	manifests/nodes/ \
	manifests/role/ \
	manifests/profile/ \
	-name '*.pp' \
	-exec grep '#' {} \; | \
sed -e 's/[ ]*# //' | \
awk '/^#/ {print "\n"} {print $0} ' - \
> "`dirname $0`/../Puppetdoc.md" && \
git rev-parse --verify HEAD \
> "`dirname $0`/../Puppetdoc.lock"

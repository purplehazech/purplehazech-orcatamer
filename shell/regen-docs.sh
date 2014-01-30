#!/bin/sh

find 	manifests/site.pp \
	manifests/nodes/ \
	manifests/role/ \
	manifests/profile/ \
	-name '*.pp' \
	-exec grep '#' {} \; | \
sed -e 's/[ ]*# //' | \
awk '
	/^#/ {
		print "";
	}
	!/^\* / {
		if (LIST) {
			print "";
			LIST="";
		}
	}
	/^\* / {
		LIST="true";
	}
	{
		print $0;
	}
' - | \
uniq - | \
sed -e 's/^#//'  \
> "`dirname $0`/../Puppetdoc.md" && \
git rev-parse --verify HEAD \
> "`dirname $0`/../Puppetdoc.lock"

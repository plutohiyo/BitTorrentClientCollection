#!/bin/sh
#
#    purge-old-kernels - remove old kernel packages
#    Copyright (C) 2012 Dustin Kirkland <kirkland@ubuntu.com>
#
#    Authors: Dustin Kirkland <kirkland@ubuntu.com>
#             Kees Cook <kees@ubuntu.com>
#             Alexandre Frade <kernel@xanmod.org>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Ensure we're running as root
if [ "$(id -u)" != 0 ]; then
	echo "\n\033[1;33mWARNING: This script must run as root.  Hint...\033[0m" 1>&2
	echo " \033[1;37msudo $0 $@\033[0m\n" 1>&2
	exit 1
fi

# NOTE: This script will ALWAYS keep the currently running kernel
# NOTE: Default is to keep 2 more, user overrides with --keep N
KEEP=2
# NOTE: Any unrecognized option will be passed straight through to apt
APT_OPTS=
while [ ! -z "$1" ]; do
	case "$1" in
		--keep)
			# User specified the number of kernels to keep
			KEEP="$2"
			shift 2
		;;
		*)
			APT_OPTS="$APT_OPTS $1"
			shift 1
		;;
	esac
done

# Build our list of kernel packages to purge
LINUX415=$(ls -tr /boot/vmlinuz-4.15*xanmod* | head -n -${KEEP} | grep -v "$(uname -r)$" | cut -d- -f2- | awk '{print "linux-image-" $0 " linux-headers-" $0}' )
for c in $LINUX415; do
	dpkg-query -s "$c" >/dev/null 2>&1 && PURGE="$PURGE $c"
done

if [ -z "$PURGE" ]; then
	echo " \n\033[1;32mNo kernels are eligible for removal\033[0m\n"
	exit 0
fi

	apt $APT_OPTS remove --purge $PURGE

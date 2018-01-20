#!/bin/sh

usage() {
	printf "Usage: %s -n <lvname> -s <lvsize> [-y]\n" "$0"
	printf -- "\t-y disable confirmation prompt\n"
	printf "Example: %s -n steam -s 50G\n" "$0"

	exit 1
}


mkpart() {
	vgname=$(sudo vgs --noheadings |awk '{print $1 }')

	printf "\n"

	sudo lvcreate -n $lvname -L $lvsize system
	sudo mkfs.ext4 /dev/mapper/${vgname}-${lvname}
	sudo mkdir /${lvname}
	sudo chown -R ${USER}: /${lvname}
	sudo mount /dev/mapper/${vgname}-${lvname} /${lvname}

	printf "\n"
	printf "Partition created and mounted but add in fstab:\n"
	printf "fstab content: /dev/mapper/${vgname}-%s /%s ext4 rw,noatime,data=ordered 0 0\n" "$lvname" "$lvname"
}


interactive=1

while getopts "s:n:y" opt; do
	case "$opt" in
		s)
			lvsize="$OPTARG"
			;;
		n)
			lvname="$OPTARG"
			;;
		y)
			[[ -n $OPTARG ]] && interactive=0
			;;
		*)
			usage
			;;
		\?)
			usage
			;;
	esac
done

[ -z $lvsize ] || [ -z $lvname ] && usage

printf "Will create a logical volume with these properties:\n"
printf -- "- lvname: %s\n" "$lvname"
printf -- "- lvsize: %s\n" "$lvsize"

confirm="N"
if [[ "$interactive" -eq 1 ]]; then
	printf "Confirm? [y/N] " && read confirm

	case "$confirm" in
		y|Y)
			mkpart
			;;
		n|N|*)
			printf "Exit\n"
			exit 0
			;;
	esac
else
	mkpart
fi

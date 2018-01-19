#!/bin/bash


echo "====================="
echo "======= PREREQUISITES"
echo "The company the time slots are to be assigned to (optional, else use tags)."

# TODO Use source </path/to/base/repo/file>
# Definitions:
# cwd := current working directory
# rel := relative
# dir := directory


function delay {
IFS=''
action='Continuing'
if [ ! -z $1 ]; then
	action=$1
fi
echo -e "Press [ENTER] to continue or [ESC] to abort"
echo ""
t=10
echo -e "\e[0K\r$action in $t seconds..."
for (( i=${t}; i>0; i--)); do

#	echo -en "\e[1A";  # amend line 1 before

	read -s -N 1 -t 1 key

	if [ "$key" = $'\e' ]; then
		echo -e "\nAborting"
		exit 0
	elif [ "$key" == $'\x0a' ] ;then
		echo -e "\nContinuing"
		break
	fi
done
}


echo ""
echo "====================="
echo "======= INPUT"
echo "Processing input ..."
destination_prefix='/root'
company="/firmamichel"
tags=""  # no tag means free, project unbound
step="start"
starttime=$(date --utc '+%H.%M')
stoptime=$(date --utc '+%H.%M')

# Parse the arguments given to this script:
while :
do
	echo $1
	# Note: Space is delimiter! => $1 is first, $2 is first argument.
	case $1 in

		-h | --help | -\?)
			# TODO Create help function to call?
			echo "Usage:"
			echo "<script> [OPTIONS]"
			echo "e.g. timeslot.sh --start --tags='topic project ...' --prefix=/root/firmamichel"
			echo "e.g. timeslot.sh --stop=<starttime_%H.%M_of_slot_to_stop> --prefix=/root --company=firmamichel"
			exit 0  # This is not an error, User asked for help. Don't "exit 1".
			;;

		--copy)
			printf >&2 'Copying symbolically instead of linking the files.'
			link_instead_of_copy=0  # return code = 0 := true
			shift
			;;

		--prefix=*)
			destination_prefix=${1#*=}
			shift 1
			;;

		--start)
			starttime=$(date --utc '+%H.%M')
			shift 1
			;;

		--start=*)
			starttime=${1#*=}
			if [ -z $starttime ]; then
				echo 'Start parameter given but empty. Using current time.'
				starttime = $(date --utc '+%H.%M')
			fi
			shift 1
			;;

		--stop=*)
			step='stop'
			starttime=${1#*=}
			if [ -z $starttime ]; then
				echo 'Stop parameter given but empty. TODO Check if only one dir in filesys, then use that.'
				exit 1
			fi
			stoptime=$(date --utc '+%H.%M')
			shift 1
			;;

		--company=*)
			company="/"${1#*=}
			shift
			;;

		--tags=*)
			tags=${1#*=}
			shift
			;;


		--)  # End of all options
			break
			;;

		-*)
			printf >&2 'WARN: Unknown option (ignored): %s\n' "$1"
			shift
			;;

		*)
			remaining_input=$1
			break
			;;

	esac
done


today=`date --utc '+%Y-%m-%d'`
destination="$destination_prefix$company/$today/$starttime"




case $step in

	start)
# TODO check if filepath is writable and only get root permissions on demand.
#case "$destination" in
#	*root*)
#sudo su
#		;;
#esac

cd
mkdir -p $destination
tag_file=$destination"/tags"
for t in $tags
	do
		echo $t >> $tag_file
done
cat $tag_file | sort | uniq > $tag_file
echo "Started slot $starttime on topics: $tags"
		;;


	stop)
stop_file=$destination"/stop"
echo $stoptime >> $stop_file
echo "Stopped slot $starttime at $stoptime"
		;;

esac




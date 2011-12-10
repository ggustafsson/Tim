#!/usr/bin/env zsh
# vim: ft=zsh

###############################################################################
# Written by Göran Gustafsson <gustafsson.g@gmail.com>                        #
#                                                                             #
# Web: http://ggustafsson.github.com/Timer-Script-Improved                    #
# Git: https://github.com/ggustafsson/Timer-Script-Improved                   #
###############################################################################

stty -echo # Disable display of keyboard input.

VERSION=0.2
FILENAME=$(echo $0 | sed 's/.*\///') # Get filename from full path.


###############################################################################
# CONFIGURATION SECTION                                                       #
###############################################################################
[ -f ~/.timrc ] && source ~/.timrc # Lazy fix. This is just temporary.

if [[ $OSTYPE == darwin* ]]; then
	COMMAND=afplay # Comes with Mac OS X.
else
	COMMAND=aplay  # Comes with alsa-utils.
fi

# If these variables are not found in ~/.timrc then set them now.
[ -z $TIMER_CMD ] && TIMER_CMD=$COMMAND
[ -z $TIMER_ARG ] && TIMER_ARG=~/.tim/alarm.wav

[ -z $WORK_CMD ] && WORK_CMD=$COMMAND
[ -z $WORK_ARG ] && WORK_ARG=~/.tim/work.wav

[ -z $BREAK_CMD ] && BREAK_CMD=$COMMAND
[ -z $BREAK_ARG ] && BREAK_ARG=~/.tim/break.wav

[ -z $INTERVAL       ] && INTERVAL=15
[ -z $POMODORO_WORK  ] && POMODORO_WORK=25
[ -z $POMODORO_BREAK ] && POMODORO_BREAK=5
[ -z $POMODORO_STOP  ] && POMODORO_STOP=4


###############################################################################
# ENVIRONMENT CHECK SECTION                                                   #
###############################################################################
# Check if commands, files etc exist here.


###############################################################################
# INFORMATION SECTION                                                         #
###############################################################################
function usage {
	echo "Usage: $FILENAME [OPTION]... [NUMBER]..."
	echo "Try '--help' for more information."
}

function help {
<<'EOT'
Usage: $FILENAME [OPTION]... [NUMBER]...

 [NUMBER]                 wait [NUMBER] minutes before starting alarm.
 -i, --interval [NUMBER]  work [NUMBER] minutes and pause [NUMBER] minutes.
                            defaults to 15 minutes work and pause.
 -p, --pomodoro           work x minutes and pause x minutes. run x times.
                            defaults to 25 minutes work, 5 minutes break and
                            stop after 4 times.
                            <http://en.wikipedia.org/wiki/Pomodoro_Technique>
 -h, --help               display this help and exit.
 -v, --version            output version information and exit.

Examples:

  $FILENAME 5      # wait 5 minutes before starting alarm.
  $FILENAME -i 10  # work for 10 minutes and pause for 10 minutes.
  $FILENAME -i     # same as above but use the default/timrc setting.
  $FILENAME -p     # pomodoro mode. using default/timrc settings.
EOT
}

function version {
	echo "Tim (Timer Script Improved) $VERSION\n"

	echo "Web: http://ggustafsson.github.com/Timer-Script"
	echo "Git: https://github.com/ggustafsson/Timer-Script-Improved\n"

	echo "Written by Göran Gustafsson <gustafsson.g@gmail.com>."
}


###############################################################################
# TIMER MODE SECTION                                                          #
###############################################################################
function timer {
	(( MINUTES_IN_SECONDS = $1 * 60 ))

	echo -n "Waiting for $1 "
	if [[ $1 > 1 ]]; then
		echo "minutes."
	else
		echo "minute."
	fi

	sleep $MINUTES_IN_SECONDS
	echo -e "\n\033[1;31mALARM SET OFF!\033[0m"

	$TIMER_CMD $TIMER_ARG
}


###############################################################################
# INTERVAL MODE SECTION                                                       #
###############################################################################
function interval {
	if [[ -z $1 ]]; then
		MINUTES=$INTERVAL
	else
		MINUTES=$1
	fi
	(( MINUTES_IN_SECONDS = $MINUTES * 60 ))

	CURRENT_MODE=work

	echo -n "Starting timer. Interval of $MINUTES "
	if [[ $MINUTES > 1 ]]; then
		echo "minutes."
	else
		echo "minute."
	fi

	echo "Start working now. Stop with Ctrl+C."

	while true; do
		sleep $MINUTES_IN_SECONDS

		if [ -z $LINEBREAK ]; then
			LINEBREAK=0
			echo
		fi

		if [[ $CURRENT_MODE == work ]]; then
			echo "\033[1;32mTAKE A LITTLE BREAK!\033[0m"
			$BREAK_CMD $BREAK_ARG

			CURRENT_MODE=break
		else
			echo "\033[1;31mSTART WORKING AGAIN!\033[0m"
			$WORK_CMD $WORK_ARG

			CURRENT_MODE=work
		fi
	done
}


###############################################################################
# POMODORO MODE SECTION                                                       #
###############################################################################
function pomodoro {
	(( POMODORO_WORK_IN_SECONDS  = $POMODORO_WORK  * 60 ))
	(( POMODORO_BREAK_IN_SECONDS = $POMODORO_BREAK * 60 ))

	CURRENT_MODE=work
	CURRENT_RUN=0
	MINUTES_IN_SECONDS=$POMODORO_WORK_IN_SECONDS

	echo "Starting timer. Pomodoro mode:"
	echo "  Work $POMODORO_WORK min. Break $POMODORO_BREAK min. Stop after $POMODORO_STOP.\n"

	echo "Start working now. Stop with Ctrl+C."

	while [[ $CURRENT_RUN < $POMODORO_STOP ]]; do
		sleep $MINUTES_IN_SECONDS

		if [ -z $LINEBREAK ]; then
			LINEBREAK=0
			echo
		fi

		if [[ $CURRENT_MODE == work ]]; then
			echo "\033[1;32mTAKE A LITTLE BREAK!\033[0m"
			$BREAK_CMD $BREAK_ARG

			CURRENT_MODE=break
			MINUTES_IN_SECONDS=$POMODORO_BREAK_IN_SECONDS
		else
			echo "\033[1;31mSTART WORKING AGAIN!\033[0m"
			$WORK_CMD $WORK_ARG

			CURRENT_MODE=work
			MINUTES_IN_SECONDS=$POMODORO_WORK_IN_SECONDS
		fi

		(( CURRENT_RUN = $CURRENT_RUN + 1 ))
	done
}


###############################################################################
# OPTIONS AND EXECUTION SECTION                                               #
###############################################################################
case $# in
	1)
		case $1 in
			[0-9])           timer    $1 ;;
			-i | --interval) interval    ;;
			-p | --pomodoro) pomodoro    ;;
			-h | --help)     help        ;;
			-v | --version)  version     ;;
			*)
				usage && return 1
			;;
		esac
	;;
	2)
		if ([[ $1 == -i ]] && [[ $2 == [0-9] ]]); then
			interval $2
		else
			usage && return 1
		fi
	;;
	*) usage && return 1 ;;
esac


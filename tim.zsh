#!/usr/bin/env zsh

# Copyright (c) 2011, Göran Gustafsson. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#  Redistributions of source code must retain the above copyright notice, this
#  list of conditions and the following disclaimer.
#
#  Redistributions in binary form must reproduce the above copyright notice,
#  this list of conditions and the following disclaimer in the documentation
#  and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

###############################################################################
# Web: http://ggustafsson.github.com/Timer-Script-Improved                    #
# Git: https://github.com/ggustafsson/Timer-Script-Improved                   #
###############################################################################

stty -echo # Disable display of keyboard input.

VERSION=0.7
FILENAME=$0:t # Get filename from full path.
DIRECTORY=$0:A:h # Directory the script is in.

###############################################################################
# CONFIGURATION SECTION                                                       #
###############################################################################
[ -f ~/.timrc ] && source ~/.timrc # Lazy fix. This is just temporary.

if [[ $OSTYPE == darwin* ]]; then
	DEFAULT_COMMAND=afplay # Comes with Mac OS X.
else
	DEFAULT_COMMAND=aplay # Comes with alsa-utils.
fi

# If these variables are not found in ~/.timrc then set them. Tim checks for
# audio files in this order: 1. ~/.timrc, 2. ~/.tim folder and 3. script $PWD.
[ -z $TIMER_CMD ] && TIMER_CMD=$DEFAULT_COMMAND
if [ -z $TIMER_ARG ]; then
	if [ -f ~/.tim/alarm.wav ]; then
		TIMER_ARG=~/.tim/alarm.wav
	elif [ -f $DIRECTORY/audio_files/alarm.wav ]; then
		TIMER_ARG=$DIRECTORY/audio_files/alarm.wav
	fi
fi
[ -z $TIMER_REPEAT_ALARM ] && TIMER_REPEAT_ALARM=0

[ -z $WORK_CMD ] && WORK_CMD=$DEFAULT_COMMAND
if [ -z $WORK_ARG ]; then
	if [ -f ~/.tim/work.wav ]; then
		WORK_ARG=~/.tim/work.wav
	elif [ -f $DIRECTORY/audio_files/work.wav ]; then
		WORK_ARG=$DIRECTORY/audio_files/work.wav
	fi
fi

[ -z $BREAK_CMD ] && BREAK_CMD=$DEFAULT_COMMAND
if [ -z $BREAK_ARG ]; then
	if [ -f ~/.tim/break.wav ]; then
		BREAK_ARG=~/.tim/break.wav
	elif [ -f $DIRECTORY/audio_files/break.wav ]; then
		BREAK_ARG=$DIRECTORY/audio_files/break.wav
	fi
fi

[ -z $POMODORO_CMD ] && POMODORO_CMD=$DEFAULT_COMMAND
if [ -z $POMODORO_ARG ]; then
	if [ -f ~/.tim/alarm.wav ]; then
		POMODORO_ARG=~/.tim/alarm.wav
	elif [ -f $DIRECTORY/audio_files/alarm.wav ]; then
		POMODORO_ARG=$DIRECTORY/audio_files/alarm.wav
	fi
fi
[ -z $POMODORO_REPEAT_ALARM ] && POMODORO_REPEAT_ALARM=0

[ -z $POMODORO_WORK  ] && POMODORO_WORK=25
[ -z $POMODORO_BREAK ] && POMODORO_BREAK=5
[ -z $POMODORO_STOP  ] && POMODORO_STOP=4

[ -z $INTERVAL      ] && INTERVAL=15
[ -z $NO_FILE_CHECK ] && NO_FILE_CHECK=0


###############################################################################
# ENVIRONMENT CHECK SECTION                                                   #
###############################################################################
CMD_SETTINGS=(TIMER_CMD WORK_CMD BREAK_CMD POMODORO_CMD)
ARG_SETTINGS=(TIMER_ARG WORK_ARG BREAK_ARG POMODORO_ARG)

INT_SETTINGS=(NO_FILE_CHECK TIMER_REPEAT_ALARM INTERVAL POMODORO_REPEAT_ALARM \
              POMODORO_WORK POMODORO_BREAK POMODORO_STOP)

for x in $CMD_SETTINGS; do
	if ! $(type -p ${(P)x} > /dev/null); then # Check if command exists.
		echo "$x: Command '${(P)x}' doesn't exist." && ERROR=1
	fi
done

if [[ ! $NO_FILE_CHECK == 1 ]]; then
	for x in $ARG_SETTINGS; do
		if [ ! -f ${(P)x} ]; then # Check if file exists.
			echo "$x: File '${(P)x}' doesn't exist." && ERROR=1
		fi
	done
fi

for x in $INT_SETTINGS; do
	if [[ ! ${(P)x} == <-> ]]; then
		echo "$x: Setting '${(P)x}' is not valid. Numbers only!" && ERROR=1
	fi
done

[[ ! -z $ERROR ]] && return 1


###############################################################################
# INFORMATION SECTION                                                         #
###############################################################################
function usage {
	echo "Usage: $FILENAME [OPTION]... [NUMBER]...
Try '--help' for more information."
}

function help {
	echo "Usage: $FILENAME [OPTION]... [NUMBER]...

  [NUMBER]                 Wait [NUMBER] minutes before starting alarm.
  -i, --interval [NUMBER]  Work [NUMBER] minutes and pause [NUMBER] minutes.
                            (Default: 15 minutes work and pause.)
  -p, --pomodoro           Work X minutes and pause X minutes. Run X times.
                            (Default: 25 minutes work, 5 minutes break and
                             stop after 4 times.)
                            <http://en.wikipedia.org/wiki/Pomodoro_Technique>
  -h, --help               Display this help and exit.
  -v, --version            Output version information and exit.

Examples:

  $FILENAME 5      # Wait 5 minutes before starting alarm.
  $FILENAME -i 10  # Work for 10 minutes and pause for 10 minutes.
  $FILENAME -i     # Same as above but use the timrc (or default) setting.
  $FILENAME -p     # Pomodoro mode. Using timrc (or default) settings."
}

function version {
	echo "Tim (Timer Script Improved) $VERSION

Web: http://ggustafsson.github.com/Timer-Script-Improved
Git: https://github.com/ggustafsson/Timer-Script-Improved

Written by Göran Gustafsson <gustafsson.g@gmail.com>.
Released under the BSD 2-Clause license."
}


###############################################################################
# TIMER MODE SECTION                                                          #
###############################################################################
function timer {
	(( MINUTES_IN_SECONDS = $1 * 60 ))

	echo -n "Starting timer. Waiting for $1 "
	if [[ $1 > 1 ]]; then
		echo "minutes."
	else
		echo "minute."
	fi
	echo "Stop with Ctrl+C."

	sleep $MINUTES_IN_SECONDS
	echo -e "\n\033[1;31mALARM SET OFF!\033[0m"

	if [[ $TIMER_REPEAT_ALARM == 1 ]]; then
		while true; do
			$TIMER_CMD $TIMER_ARG
		done
	else
		$TIMER_CMD $TIMER_ARG
	fi
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

		[ -z $LINEBREAK ] && LINEBREAK=0 && echo

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
	CURRENT_RUN=1
	MINUTES_IN_SECONDS=$POMODORO_WORK_IN_SECONDS

	echo "Starting timer. Pomodoro mode:
 Work $POMODORO_WORK min. Break $POMODORO_BREAK min. Stop after $POMODORO_STOP.

Start working now. Stop with Ctrl+C."

	while [[ $CURRENT_RUN < $POMODORO_STOP ]]; do
		sleep $MINUTES_IN_SECONDS

		[ -z $LINEBREAK ] && LINEBREAK=0 && echo

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

			(( CURRENT_RUN = $CURRENT_RUN + 1 ))
		fi
	done

	sleep $MINUTES_IN_SECONDS
	echo "\nWorking session is over!"

	if [[ $POMODORO_REPEAT_ALARM == 1 ]]; then
		while true; do
			$POMODORO_CMD $POMODORO_ARG
		done
	else
		$POMODORO_CMD $POMODORO_ARG
	fi
}


###############################################################################
# DEBUG SECTION (DISPLAY VARIABLES)                                           #
###############################################################################
function debug {
	echo "FILENAME: $FILENAME"
	echo "DIRECTORY: $DIRECTORY"
	echo "VERSION: $VERSION"
	echo "ERROR: $ERROR"
	echo "DEFAULT_COMMAND: $DEFAULT_COMMAND"

	echo "TIMER_CMD: $TIMER_CMD"
	echo "TIMER_ARG: $TIMER_ARG"
	echo "TIMER_REPEAT_ALARM: $TIMER_REPEAT_ALARM"

	echo "WORK_CMD: $WORK_CMD"
	echo "WORK_ARG: $WORK_ARG"

	echo "BREAK_CMD: $BREAK_CMD"
	echo "BREAK_ARG: $BREAK_ARG"

	echo "POMODORO_CMD: $POMODORO_CMD"
	echo "POMODORO_ARG: $POMODORO_ARG"
	echo "POMODORO_REPEAT_ALARM: $POMODORO_REPEAT_ALARM"

	echo "POMODORO_WORK: $POMODORO_WORK"
	echo "POMODORO_STOP: $POMODORO_STOP"
	echo "POMODORO_BREAK: $POMODORO_BREAK"

	echo "INTERVAL: $INTERVAL"
	echo "NO_FILE_CHECK: $NO_FILE_CHECK"
}


###############################################################################
# OPTIONS AND EXECUTION SECTION                                               #
###############################################################################
case $# in
	0) usage ;;
	1)
		case $1 in
			<->) # Check if $1 is integer.
				if [[ $1 > 0 ]]; then
					timer $1 # Send argument $1 to function timer.
				else
					usage && return 1
				fi
			;;
			wtf)             debug    ;;
			-i | --interval) interval ;;
			-p | --pomodoro) pomodoro ;;
			-h | --help)     help     ;;
			-v | --version)  version  ;;
			*)
				usage && return 1
			;;
		esac
	;;
	2)
		if ([[ $1 == -i ]] && [[ $2 == <-> ]]); then # Check if $2 is integer.
			if [[ $2 > 0 ]]; then
				interval $2 # Send argument $2 to function interval.
			else
				usage && return 1
			fi
		else
			usage && return 1
		fi
	;;
	*) usage && return 1 ;;
esac


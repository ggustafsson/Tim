#!/usr/bin/env zsh

# Göran Gustafsson <gustafsson.g@gmail.com>

# Find latest version at: https://github.com/ggustafsson/Timer-Script-Improved

VERSION=0.1
FILENAME=$(echo $0 | sed 's/.*\///')

if [ -f ~/.timrc ]; then

fi

if [[ $OSTYPE == darwin* ]]; then
	COMMAND=afplay
else
	COMMAND=aplay
fi

[[ -z COUNTDOWN_CMD ]] && COUNTDOWN_CMD=$COMMAND
[[ -z COUNTDOWN_ARG ]] && COUNTDOWN_ARG=./audio_files/alarm.wav

[[ -z WORK_CMD ]] && WORK_CMD=$COMMAND
[[ -z WORK_ARG ]] && WORK_ARG=./audio_files/work.wav

[[ -z BREAK_CMD ]] && BREAK_CMD=$COMMAND
[[ -z BREAK_ARG ]] && BREAK_ARG=./audio_files/break.wav

[[ -z INTERVAL       ]] && INTERVAL=15
[[ -z POMODORO_WORK  ]] && POMODORO_WORK=25
[[ -z POMODORO_BREAK ]] && POMODORO_BREAK=5
[[ -z POMODORO_STOP  ]] && POMODORO_STOP=4

function usage {
	echo "Usage: $FILENAME [OPTION]... [NUMBER]..."
	echo "Try '--help' for more information."
}

function help {
	echo "Usage: $FILENAME [OPTION]... [NUMBER]...\n"

	echo " [NUMBER]                 wait [NUMBER] minutes before starting alarm."
	echo " -i, --interval [NUMBER]  work [NUMBER] minutes and pause [NUMBER] minutes."
	echo "                            defaults to 15 minutes work and pause."
	echo " -p, --pomodoro           work x minutes and pause x minutes. run x times."
	echo "                            defaults to 25 minutes work, 5 minutes break"
	echo "                            and stop after 4 times."
	echo "                            <http://en.wikipedia.org/wiki/Pomodoro_Technique>"
	echo " -h, --help               display this help and exit."
	echo " -v, --version            output version information and exit.\n"

	echo "Examples:\n"

	echo "  $FILENAME 5      # wait 5 minutes before starting alarm."
	echo "  $FILENAME -i 10  # work for 10 minutes and pause for 10 minutes."
	echo "  $FILENAME -i     # same as above but use the default/timrc setting."
	echo "  $FILENAME -p     # pomodoro mode. using default/timrc settings."
}

function version {
	echo "Tim (Timer Script Improved) $VERSION\n"

	echo "Web site: <http://x>."
	echo "Git repository: <http://x>.\n"

	echo "Written by Göran Gustafsson <gustafsson.g@gmail.com>."
}

function countdown {
	echo "countdown mode. $1"
}

function interval {
	echo "interval mode. $1"
}

function pomodoro {
	echo "pomodoro mode."
}

case $# in
	1)
		case $1 in
			[0-9])         countdown $1 ;;
			-i|--interval) interval     ;;
			-p|--pomodoro) pomodoro     ;;
			-h|--help)     help         ;;
			-v|--version)  version      ;;
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
	*) usage ;;
esac


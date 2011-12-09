Tim (Timer Script Improved)
===========================

Description
-----------


Usage
-----
**./tim.sh --help**

Configuration
-------------
Read the file **timrc.example**.

Dependencies
------------
You need to have Zsh installed to run this. Port it to Bash if you want, I'm
not going to waste my time.

When using the default settings Tim depends on:

 Mac OS X: **afplay**.
GNU/Linux: **aplay**.

Tips
----
If you use Mac OS X you can put this in ~/.timrc:

WORK_CMD=say
WORK_ARG="start working again"

BREAK_CMD=say
BREAK_ARG="take a little break"


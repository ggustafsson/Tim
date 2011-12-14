Tim (Timer Script Improved)
===========================

Description
-----------
Terminal countdown timer with several modes written in Zsh shell script.

Usage
-----
	./tim.zsh --help

Configuration
-------------
Read the file **timrc.example**.

Dependencies
------------
You need to have Zsh installed to run this.

When using the default settings Tim depends on:

- Mac OS X:
  - **afplay**
- GNU/Linux:
  - **aplay**

Tips
----
If you use Mac OS X you can put this in ~/.timrc to make it speak:

	NO_FILE_CHECK=1

	WORK_CMD=say
	WORK_ARG="start working again"

	BREAK_CMD=say
	BREAK_ARG="take a little break"

	POMODORO_CMD=say
	POMODORO_ARG="working session is over. take a break"

License
-------
Released under the BSD 2-Clause License.

	Copyright (c) 2011, Göran Gustafsson. All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	 Redistributions of source code must retain the above copyright notice, this
	 list of conditions and the following disclaimer.

	 Redistributions in binary form must reproduce the above copyright notice,
	 this list of conditions and the following disclaimer in the documentation
	 and/or other materials provided with the distribution.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.


#CRT设置虚拟终端类型，Terminal--Emulation 中选择ANSI/linux/xterm,必须钩上 ANSI Colour
#ANSI 颜色代码查看https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
#在'\E[0x;3y;4zm'中：x代表是否加粗，1为加粗，2为正常；y和z分别代表文字前景色和背景色，使用默认值的话可省略
#
TERM=xterm
PS1='\[\e[37;40m\][\[\e[33;40m\]\u\[\e[32;40m\]@\[\e[31;40m\]\h \[\e[36;40m\]\w\[\e[37;40m\]]\[\e[35;40m\]=>\[\e[92;40m\] '
# forbit ^D to logout , use "exit" to logout
umask 002
set -o ignoreeof
set -o vi
#
#       Environment variable configuration
#
export EDITOR='vi'
#display The line num and the function when used '-x'
export PS4='+{$LINENO:${FUNCNAME[0]}} '
export TZ='Asia/Beijing'
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
export LANGUGAE=zh_CN.UTF-8
export GREP_COLOR="2;91"
export LESS="-R -M -I"
export LESS_TERMCAP_mb=$'\E[01;35m'     # begin bold
export LESS_TERMCAP_md=$'\E[01;31m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'         # reset bold/blink
export LESS_TERMCAP_so=$'\E[02;32;43m'  # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'         # reset reverse video
export LESS_TERMCAP_us=$'\E[01;36m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'         # reset underline
export GROFF_NO_SGR=1                   # for konsole and gnome-terminal
#
#       Terminal related
#
#stty erase ^?
stty erase ^H
stty intr ^C
stty sane
#
#       Aliases
#
alias cls='clear'
alias cp='cp -i'
alias cd..='cd ..'
alias cat='cat -n'
alias ..='cd ..'
alias ...='cd ../..'
alias df='df -h'
#alias diff='diff --color=auto'  #version 3.4 includes the --color option
alias du='du -sm * | sort -nr | more'
alias free='free -m'
alias grep="grep --color=auto"
#alias ls='ls $LS_OPTIONS' #SUSE is ok,CentOS is not ok!
alias ls='ls --color=always'
alias ll='ls -al'
alias la='ls -a'
alias l='ls -alrt'
alias mv='mv -i'
alias rm='rm -i'
alias sql='sqlplus CVMS/CVMS'
alias type='type -a'
alias vi='vim'         #解决VI没有颜色
#

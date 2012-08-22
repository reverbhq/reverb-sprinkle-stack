#! /bin/bash
### BEGIN INIT INFO
# Provides:          nginx
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: nginx init.d bash script for debian/ubuntu
# Description:       nginx init.d bash script for debian/ubuntu
### END INIT INFO
#------------------------------------------------------------------------------
# nginx - This is a bash script for starting/stopping/restarting nginx on
#		  debian-based distributions such as Ubuntu, Mint, Mepis, etc.
#
# description:  Nginx is an HTTP(S) server, HTTP(S) reverse
#               proxy and IMAP/POP3 proxy server.  This
#				script will manage the initiation of the
#				server and it's process state.
#
# processname: nginx
# Provides:    nginx
#
#------------------------------------------------------------------------------
#                               Author
#------------------------------------------------------------------------------
#
# Copyright (c) 2012 Dave Hulihan, www.hulihanapplications.com
#   * Fork this at https://github.com/hulihanapplications/nginx-init-debian
#   * Based on Jason Giedymin's nginx-init-ubuntu: http://code.google.com/p/nginx-init-ubuntu/
#
#------------------------------------------------------------------------------
#                               MIT X11 License
#------------------------------------------------------------------------------
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#------------------------------------------------------------------------------
#                               Functions
#------------------------------------------------------------------------------
. /lib/lsb/init-functions

#------------------------------------------------------------------------------
#                               Consts
#------------------------------------------------------------------------------

# Change these to match your nginx configuration
DAEMON=/usr/local/nginx/sbin/nginx
NGINX_CONF_FILE="/usr/local/nginx/conf/nginx.conf"
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
PS="nginx"								# process name
PIDNAME="nginx"							# lets you do $PS-slave
DESCRIPTION="Nginx Server..."			#
PIDFILE=$PIDNAME.pid                    # pid file
PIDSPATH=/var/run						#
RUNAS=root                              # user to run as
SCRIPT_OK=0                             # ala error codes
SCRIPT_ERROR=1                          # ala error codes
TRUE=1                                  # boolean
FALSE=0                                 # boolean

#------------------------------------------------------------------------------
#                               Simple Tests
#------------------------------------------------------------------------------

#test if nginx is a file and executable
test -x $DAEMON || exit 0

# Include nginx defaults if available
if [ -f /etc/default/nginx ] ; then
        . /etc/default/nginx
fi

#set exit condition
#set -e

#------------------------------------------------------------------------------
#                               Functions
#------------------------------------------------------------------------------

setFilePerms(){

        if [ -f $PIDSPATH/$PIDFILE ]; then
                chmod 400 $PIDSPATH/$PIDFILE
        fi
}

configtest() {
	$DAEMON -t -c $NGINX_CONF_FILE
}

getPSCount() {
	return `pgrep -f $PS | wc -l`
}

isRunning() {
        if [ $1 ]; then
                pidof_daemon $1
                PID=$?

                if [ $PID -gt 0 ]; then
                        return 1
                else
                        return 0
                fi
        else
                pidof_daemon
                PID=$?

                if [ $PID -gt 0 ]; then
                        return 1
                else
                        return 0
                fi
        fi
}

#courtesy of php-fpm
wait_for_pid () {
        try=0

        while test $try -lt 35 ; do

                case "$1" in
                        'created')
                        if [ -f "$2" ] ; then
                                try=''
                                break
                        fi
                        ;;

                        'removed')
                        if [ ! -f "$2" ] ; then
                                try=''
                                break
                        fi
                        ;;
                esac

                #echo -n .
                try=`expr $try + 1`
                sleep 1
        done
}

status(){
	isRunning
	isAlive=$?

	if [ "${isAlive}" -eq $TRUE ]; then
                echo "$PIDNAME found running with processes:  `pidof $PS`"
        else
                echo "$PIDNAME is NOT running."
        fi


}

removePIDFile(){
	if [ $1 ]; then
                if [ -f $1 ]; then
        	        rm -f $1
	        fi
        else
		#Do default removal
		if [ -f $PIDSPATH/$PIDFILE ]; then
        	        rm -f $PIDSPATH/$PIDFILE
	        fi
        fi
}

start() {
    log_daemon_msg "Starting $DESCRIPTION"

	#isRunning
	#isAlive=$?

    #if [ "${isAlive}" -eq $TRUE ]; then
    #        log_end_msg $SCRIPT_ERROR
    #else
    #        #start-stop-daemon --start --quiet --chuid $RUNAS --make-pidfile --pidfile $PIDSPATH/$PIDFILE --exec $DAEMON -- -c $NGINX_CONF_FILE
	#		start-stop-daemon --start --quiet --chuid $RUNAS --name $PS --exec $DAEMON -- -c $NGINX_CONF_FILE
    #        setFilePerms
    #        log_end_msg $SCRIPT_OK
    #fi

    start-stop-daemon --start --quiet --chuid $RUNAS --exec $DAEMON -- -c $NGINX_CONF_FILE
    log_end_msg $SCRIPT_OK
    return 0
}

stop() {
	log_daemon_msg "Stopping $DESCRIPTION"

	#log_daemon_msg "Checking if $PS is running..."
	#isRunning
	#isAlive=$?

    #if [ "${isAlive}" -eq $TRUE ]; then
    # 	log_end_msg $SCRIPT_OK
    # else
    #    log_end_msg $SCRIPT_ERROR
    #    log_daemon_msg "Cannot tell if $PS is running. Trying to stop anyway..."
    # fi

    log_end_msg $SCRIPT_OK
    start-stop-daemon --stop --quiet --exec $DAEMON
    return 0
}

reload() {
	configtest || return $?

	log_daemon_msg "Reloading (via HUP) $DESCRIPTION"

        isRunning
        if [ $? -eq $TRUE ]; then
		`killall -HUP $PS` #to be safe

                log_end_msg $SCRIPT_OK
        else
                log_end_msg $SCRIPT_ERROR
        fi
}

quietupgrade() {
	log_daemon_msg "Peforming Quiet Upgrade $DESCRIPTION"

        isRunning
        isAlive=$?
        if [ "${isAlive}" -eq $TRUE ]; then
		kill -USR2 `cat $PIDSPATH/$PIDFILE`
		kill -WINCH `cat $PIDSPATH/$PIDFILE.oldbin`

		isRunning
		isAlive=$?
		if [ "${isAlive}" -eq $TRUE ]; then
			kill -QUIT `cat $PIDSPATH/$PIDFILE.oldbin`
			wait_for_pid 'removed' $PIDSPATH/$PIDFILE.oldbin
                        removePIDFile $PIDSPATH/$PIDFILE.oldbin

			log_end_msg $SCRIPT_OK
		else
			log_end_msg $SCRIPT_ERROR

			log_daemon_msg "ERROR! Reverting back to original $DESCRIPTION"

			kill -HUP `cat $PIDSPATH/$PIDFILE`
			kill -TERM `cat $PIDSPATH/$PIDFILE.oldbin`
			kill -QUIT `cat $PIDSPATH/$PIDFILE.oldbin`

			wait_for_pid 'removed' $PIDSPATH/$PIDFILE.oldbin
                        removePIDFile $PIDSPATH/$PIDFILE.oldbin

			log_end_msg $SCRIPT_ok
		fi
        else
                log_end_msg $SCRIPT_ERROR
        fi
}

terminate() {
    log_daemon_msg "Force terminating (via KILL) $DESCRIPTION"

	PIDS=`pidof $PS` || true

	[ -e $PIDSPATH/$PIDFILE ] && PIDS2=`cat $PIDSPATH/$PIDFILE`

	for i in $PIDS; do
		if [ "$i" = "$PIDS2" ]; then
                kill $i
                        wait_for_pid 'removed' $PIDSPATH/$PIDFILE
			removePIDFile
		fi
	done

	log_end_msg $SCRIPT_OK
}

destroy() {
	log_daemon_msg "Force terminating and may include self (via KILLALL) $DESCRIPTION"
	killall $PS -q >> /dev/null 2>&1
	log_end_msg $SCRIPT_OK
}

pidof_daemon() {
    PIDS=`pidof $PS` || true

    [ -e $PIDSPATH/$PIDFILE ] && PIDS2=`cat $PIDSPATH/$PIDFILE`

    for i in $PIDS; do
        if [ "$i" = "$PIDS2" ]; then
            return 1
        fi
    done
    return 0
}


# Handle signals
#trap "echo 'Exiting Prematurely.'; exit 1" SIGTERM

case "$1" in
  start)
	start
        ;;
  stop)
	stop
        ;;
  restart|force-reload)
	stop
	sleep 1
	start
        ;;
  reload)
	$1
	;;
  status)
	status
	;;
  configtest)
        $1
        ;;
  quietupgrade)
	$1
	;;
  terminate)
	$1
	;;
  destroy)
	$1
	;;
  *)
	FULLPATH=/etc/init.d/$PS
	echo "Usage: $FULLPATH {start|stop|restart|force-reload|status|configtest|quietupgrade|terminate|destroy}"
	echo "       The 'destroy' command should only be used as a last resort."
	exit 1
	;;
esac

exit 0

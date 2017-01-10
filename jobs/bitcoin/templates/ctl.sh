#!/bin/bash

DATA_DIR=/var/vcap/store/bitcoin
LOG_DIR=/var/vcap/sys/log/bitcoin
RUN_DIR=/var/vcap/sys/run/bitcoin
PIDFILE=${RUN_DIR}/bitcoin.pid

case $1 in

  start)

    mkdir -p $RUN_DIR $LOG_DIR $DATA_DIR
    chown -R vcap:vcap $RUN_DIR
    chown -R vcap:vcap $LOG_DIR
    chown -R vcap:vcap $DATA_DIR

    exec chpst -u vcap:vcap /var/vcap/packages/bitcoin/bitcoin-0.13.2/bin/bitcoind -printtoconsole -datadir=$DATA_DIR -pid=$PIDFILE -maxconnections=<%= properties.maxconnections %> -daemon >>  $LOG_DIR/bitcoin.stdout.log \
      2>> $LOG_DIR/bitcoin.stderr.log

    ;;

  stop)

    PID=$(cat $PIDFILE)
    if [ -n $PID ]; then
      SIGNAL=TERM
      N=1
      while kill -$SIGNAL $PID 2>/dev/null; do
        if [ $N -eq 1 ]; then
          echo "waiting for pid $PID to die"
        fi
        if [ $N -eq 11 ]; then
          echo "giving up on pid $PID with kill -TERM; trying -KILL"
          SIGNAL=KILL
        fi
        if [ $N -gt 20 ]; then
          echo "giving up on pid $PID"
          break
        fi
        N=$(($N+1))
        sleep 1
      done
    fi

    rm -f $PIDFILE

    ;;

  *)
    echo "Usage: ctl {start|stop}" ;;

esac

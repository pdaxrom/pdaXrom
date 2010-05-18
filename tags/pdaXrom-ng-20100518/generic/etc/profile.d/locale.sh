#!/bin/sh

if [ -r /etc/default/locale ]; then
  . /etc/default/locale
  export LANG LANGUAGE
elif [ -r /etc/environment ]; then
  . /etc/environment
  export LANG LANGUAGE
fi

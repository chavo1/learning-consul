#!/usr/bin/env bash

HOST=$(hostname)
envconsul -prefix $HOST /vagrant/scripts/nginx.sh
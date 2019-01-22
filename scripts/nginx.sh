#!/usr/bin/env bash

which nginx &>/dev/null || {
    sudo apt get update -y
    sudo apt install nginx -y
    }

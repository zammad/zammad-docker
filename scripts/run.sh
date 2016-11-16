#!/bin/bash

service start elasticsearch
service start postgresql
service start postfix
service start nginx

zammad run worker
zammad run websockets
zammad run web


/bin/bash


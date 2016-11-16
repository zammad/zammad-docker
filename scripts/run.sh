#!/bin/bash

systemctl start postgresql
systemctl start elasticsearch
systemctl start postfix
systemctl start nginx
systemctl start zammad

/bin/bash


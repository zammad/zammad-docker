FROM centos:centos6
MAINTAINER Roy Kaldung <rk@znuny.com>

# Prepare OS
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN yum -y update
RUN yum -y install mysql which tar patch libyaml-devel glibc-headers autoconf gcc-c++ glibc-devel readline-devel zlib-devel libffi-devel openssl-devel bzip2 automake libtool bison sqlite-devel

# Install RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN \curl -sSL https://get.rvm.io | bash -s stable --ruby=2.1.2



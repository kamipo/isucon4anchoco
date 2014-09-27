#!/bin/bash

if type yum > /dev/null; then
  sudo yum install -y git zsh vim screen dstat ngrep
  sudo yum install -y pcre pcre-devel
elif type apt-get > /dev/null; then
  sudo apt-get install -y git zsh vim screen dstat ngrep
  sudo apt-get install -y libpcre3 libpcre3-dev
fi

# lltsv
wget https://github.com/sonots/lltsv/releases/download/v0.2.0/lltsv_linux_amd64 -O lltsv
chmod +x lltsv

mkdir src && cd src

# openresty
wget http://openresty.org/download/ngx_openresty-1.7.2.1.tar.gz
tar zxvf ngx_openresty-1.7.2.1.tar.gz
cd ngx_openresty-1.7.2.1

./configure --prefix=$HOME/openresty --with-pcre-jit --with-luajit --with-http_gzip_static_module

make install

cd $HOME

ln -nfs openresty/nginx nginx
ln -nfs nginx/logs logs

#sudo service httpd stop
#sudo chkconfig --del httpd

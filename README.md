# ISUCON4あんちょこ

## 予選

#### インスタンス起動

```
ec2-run-instances -t m3.xlarge -g default -g isucon4 -k isucon -n 3 ami-xxxxxxxx
```

#### スポットインスタンス起動(m3.xlarge $0.280/h)

```
ec2-request-spot-instances -p 0.350 -t m3.xlarge -g default -g isucon4 -k isucon -n 3 ami-xxxxxxxx
```

### スロークエリログの分析

#### スロークエリログを有効にする

```
SET GLOBAL slow_query_log = 1;
SET GLOBAL slow_query_log_file = '/tmp/mysql-slow.log';
SET GLOBAL long_query_time = 0.0;
```

#### スロークエリログを無効にする

```
SET GLOBAL slow_query_log = 0;
```

#### インデックスが効いてないような遅いクエリだけ出す

```
SET GLOBAL long_query_time = 10.0;
```

##### 時間順に出す

```
sudo mysqldumpslow -s t /tmp/mysql-slow.log
```

##### 回数順に出す

```
sudo mysqldumpslow -s c /tmp/mysql-slow.log
```

### アクセスログの分析

```
cat /var/log/httpd/access_log | ./logstats.pl time
cat /home/isucon/logs/access.log | ./logstats.pl count
```

### ログのローテート

```
sudo ./logrotate.pl nginx /home/isucon/logs/access.log
sudo ./logrotate.pl mysql /tmp/mysql-slow.log
```

### プロファイリング

[Plack アプリのプロファイリング by Devel::NYTProf - @bayashi Wiki](http://bayashi.net/wiki/perl/plack_profile)

### インストールするやつ

#### setup.sh

```
git clone git@github.com:kamipo/isucon4anchoco.git
cd isucon4anchoco
./setup.sh
```

```bash:setup.sh
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
```

※ supervisordでopenrestyを自動起動するようにする


#### yumパッケージの場合

```
sudo yum install -y git zsh vim screen dstat ngrep
sudo yum install -y pcre pcre-devel
sudo yum --enablerepo=epel install -y redis
```

#### debパッケージの場合

```
sudo apt-get install -y git zsh vim screen dstat ngrep
sudo apt-get install -y libpcre3 libpcre3-dev
sudo apt-get install -y redis-server
```

#### コンフィグ

* .ssh/authorized_keys
* リポジトリのetcにコンフィグ入れといてopenrestyとかsupervisordのetcにシンボリックリンクを張る

### コマンドあんちょこ

#### コンフィグテスト

```
sudo /home/isucon/nginx/sbin/nginx -t
```

#### supervisord

```
sudo supervisorctl status
sudo supervisorctl reload
```

#### apache

```
sudo vi /etc/httpd/conf/httpd.conf

sudo chmod 777 /var/log/httpd/
sudo rm /var/log/httpd/access_log

sudo service httpd restart

cat /var/log/httpd/access_log | ./lltsv -k req,reqtime,reqtime_microsec

sudo service httpd stop
sudo chkconfig --del httpd
```

#### memcached

```
sudo service memcached stop
memcached -d -s /tmp/memcached.sock -u memcached -m 64 -c 1024
```

#### plackup

```
plackup -s Starlet -E production -p 5000 --spawn-interval=2 --max-workers=10 --keepalive-timeout=300 --max-keepalive-reqs=100000 --max-reqs-per-child=100000 app.psgi
```

#### plackup(UNIX domain socket)

```
plackup -s Starlet -E production -S /tmp/starlet.sock --spawn-interval=2 --max-workers=10 --keepalive-timeout=300 --max-keepalive-reqs=100000 --max-reqs-per-child=100000 app.psgi
```

#### gzip圧縮

```
gzip -r js css
gzip -k index.html
```

#### netstat

```
sudo netstat -tlnp
sudo netstat -tnp | grep ESTABLISHED
```

#### lsof

```
sudo lsof -nP -i4TCP -sTCP:LISTEN
sudo lsof -nP -i4TCP -sTCP:ESTABLISHED
```

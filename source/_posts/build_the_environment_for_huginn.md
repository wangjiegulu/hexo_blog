---
title: Huginn及环境搭建
subtitle: "使用Huginn实现你自己的自动化信息流"
tags: ["huginn", "ifttt", "integromat", "zapier", "automate", "geek"]
categories: ["huginn", "automate"]
header-img: "https://camo.githubusercontent.com/f7da893be2c2f5f765f2436296656e7d25962437/68747470733a2f2f7261772e6769746875622e636f6d2f687567696e6e2f687567696e6e2f6d61737465722f6d656469612f687567696e6e2d6c6f676f2e706e67"
centercrop: false
hidden: false
---

# Huginn 及环境搭建

## 什么是 Huginn ？

Huginn 是一个可以通过构建 agents 来帮你实现在线自动化任务的系统。它们可以理解 web，监听事件，按你所需地去执行一些行为。Huginn 的 agents 创建和消费事件，通过有向图表来进行转播。你可以把它当作部署在你自己的服务器上的破解版本的 IFTTT 或 Zapier。

![](https://raw.githubusercontent.com/huginn/huginn/master/doc/imgs/the-name.png)

你可以用 Huginn 做什么？

- 追踪天气并在明天下雨（雪）的时候邮件通知给你（明天不要忘记带伞）。
- 列出你关心的条目，并在 Twitter 发生改变的时候电子邮件通知给你。（例如，想知道在机器学习领域发生了什么有趣的事情吗？Huginn 将在 Twitter 上观察“machine learning”这个词，并告诉你什么时候讨论会高高峰。）
- 帮你观察旅游机票和购物优惠信息。
- 抓取任意网站并在发生变化时电子邮件通知你。
- 连接到 Adioso, HipChat, Basecamp, Growl, FTP, IMAP, Jabber, JIRA, MQTT, nextbus, Pushbullet, Pushover, RSS, Bash, Slack, StubHub, translation APIs, Twilio, Twitter, Wunderground, and 微博等第三方.
- 发送和接收 WebHooks。
- 其它很多很多你能想到的。


## 环境搭建

以 `Debian` 服务器为例，进行环境搭建（大家可以选择购买VPS）。

### 概述

Huginn 的安装主要包括以下组件：

1. Packages / Dependencies
2. Ruby
3. System Users
4. Database
5. Huginn
6. Nginx

### 1. Packages / Dependencies

Debian 中 `sudo` 并没有默认安装。确保你的系统是最新的，然后安装它。

```
# run as root!
apt-get update -y
apt-get upgrade -y
apt-get install sudo -y
```

> **注意：**在安装过程中，需要手动编辑一些文件。如果你熟悉 vim，请使用下面的命令将其设置为默认编辑器。如果你对 vim 不熟悉，请跳过此操作并继续使用默认编辑器。

```
# Install vim and set as default editor
sudo apt-get install -y vim
sudo update-alternatives --set editor /usr/bin/vim.basic
```

导入 node.js 库 (如果是 Ubuntu 或者 Debian Jessie 的话可以跳过)：

```
curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
```

安装需要的 packages：

```
sudo apt-get install -y runit build-essential git zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate python-docutils pkg-config cmake nodejs graphviz
```

#### Debian Stretch

由于 Debian Stretch 的 runit 不会自动启动，但是这会被init系统处理。另外，Ruby需要 OpenSSL 1.0 开发包而不是 1.1的。对于默认安装使用这些包：

```
sudo apt-get install -y runit-systemd libssl1.0-dev
```

### 2. Ruby

在生产中使用带有 Huginn 的 Ruby 版本管理器（如 [RVM](http://rvm.io/)，[rbenv](https://github.com/sstephenson/rbenv) 或 [chruby](https://github.com/postmodern/chruby)）会频繁导致难以诊断的问题。版本管理器不受支持，我们强烈建议所有人按照以下说明使用系统 Ruby。

如果存在的话，删除旧版本的 Ruby：

```
sudo apt-get remove -y ruby1.8 ruby1.9
```

下载 Ruby，然后编译：

```
mkdir /tmp/ruby && cd /tmp/ruby
curl -L --progress http://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.2.tar.bz2 | tar xj
cd ruby-2.4.2
./configure --disable-install-rdoc
make -j`nproc`
sudo make install
```

安装 bundler 和 foreman:

```
sudo gem install rake bundler foreman --no-ri --no-rdoc
```

### 3. System Users

为 Huginn 创建一个用户：

```
sudo adduser --disabled-login --gecos 'Huginn' huginn
```

### 4. Database

安装数据库

```
sudo apt-get install -y mysql-server mysql-client libmysqlclient-dev

# 选择一个 MySQL root 密码 (可以任意), 输入并按回车,
# 重复输入 MySQL root 密码 然后按回车
```

对于 Debian Stretch, 替换 libmysqlclient-dev 为 default-libmysqlclient-dev。

检查你安装的 MySQL 版本：

```
mysql --version
```

```
sudo mysql_secure_installation
```

登录 MySQL：

```
mysql -u root -p

# 输入 MySQL root 密码
```

为 Huginn 创建一个用户，替换 命令中的 $password 为你真实的密码：

```
mysql> CREATE USER 'huginn'@'localhost' IDENTIFIED BY '$password';
```

支持 long indexes，你需要确保可以使用 InnoDB engine：

```
mysql> SET default_storage_engine=INNODB;

# 如果失败，检查你的 MySQL 配置文件 (e.g. `/etc/mysql/*.cnf`, `/etc/mysql/conf.d/*`)
# 设置 "innodb = off"
```

给予 Huginn 用户必要的数据库相关权限：

```
mysql> GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES ON `huginn_production`.* TO 'huginn'@'localhost';
```

退出 database 会话：

```
mysql> \q
```

尝试使用新的用户链接到新的数据库

```
sudo -u huginn -H mysql -u huginn -p -D huginn_production

# Type the password you replaced $password with earlier
```

你应该回看到 `ERROR 1049 (42000): Unknown database 'huginn_production'`，这是正常的，因为我们会稍后创建数据库。

### 5. Huginn

#### Clone 源代码

```
# We'll install Huginn into the home directory of the user "huginn"
cd /home/huginn

# Clone Huginn repository
sudo -u huginn -H git clone https://github.com/huginn/huginn.git -b master huginn

# Go to Huginn installation folder
cd /home/huginn/huginn

# Copy the example Huginn config
sudo -u huginn -H cp .env.example .env

# Create the log/, tmp/pids/ and tmp/sockets/ directories
sudo -u huginn mkdir -p log tmp/pids tmp/sockets

# Make sure Huginn can write to the log/ and tmp/ directories
sudo chown -R huginn log/ tmp/
sudo chmod -R u+rwX,go-w log/ tmp/

# Make sure permissions are set correctly
sudo chmod -R u+rwX,go-w log/
sudo chmod -R u+rwX tmp/
sudo -u huginn -H chmod o-rwx .env

# Copy the example Unicorn config
sudo -u huginn -H cp config/unicorn.rb.example config/unicorn.rb
```

#### 配置它

```
# Update Huginn config file and follow the instructions
sudo -u huginn -H editor .env
```

```
DATABASE_ADAPTER=mysql2
DATABASE_RECONNECT=true
DATABASE_NAME=huginn_production
DATABASE_POOL=20
DATABASE_USERNAME=huginn
DATABASE_PASSWORD='$password'
#DATABASE_HOST=your-domain-here.com
#DATABASE_PORT=3306
#DATABASE_SOCKET=/tmp/mysql.sock

DATABASE_ENCODING=utf8
# MySQL only: If you are running a MySQL server >=5.5.3, you should
# set DATABASE_ENCODING to utf8mb4 instead of utf8 so that the
# database can hold 4-byte UTF-8 characters like emoji.
#DATABASE_ENCODING=utf8mb4
```

**重要：** 取消注释 RAILS_ENV 设置，以便于在生产环节运行 Huginn。

```
RAILS_ENV=production
```

如果需要改变 Unicorn 配置：

```
# Increase the amount of workers if you expect to have a high load instance.
# 2 are enough for most use cases, if the server has less then 2GB of RAM
# decrease the worker amount to 1
sudo -u huginn -H editor config/unicorn.rb
```

**重要：**确保 `.env` 和 `unicorn.rb` 都符合你的配置。

#### 安装 Gems

```
sudo -u huginn -H bundle install --deployment --without development test
```

#### 初始化 Database

```
# Create the database
sudo -u huginn -H bundle exec rake db:create RAILS_ENV=production

# Migrate to the latest version
sudo -u huginn -H bundle exec rake db:migrate RAILS_ENV=production

# Create admin user and example agents using the default admin/password login
sudo -u huginn -H bundle exec rake db:seed RAILS_ENV=production SEED_USERNAME=admin SEED_PASSWORD=password
```


#### 编译 Assets

```
sudo -u huginn -H bundle exec rake assets:precompile RAILS_ENV=production
```

#### 安装初始脚本

Huginn 使用 [foreman](http://ddollar.github.io/foreman/) 来生成基于 `Procfile` 的初始化脚本。

编辑 [`Procfile`](https://github.com/huginn/huginn/blob/master/Procfile) 来针对生产选择一个推荐的版本。

```
sudo -u huginn -H editor Procfile
```

注释[这两行](https://github.com/huginn/huginn/blob/master/Procfile#L6-L7)：

```
web: bundle exec rails server -p ${PORT-3000} -b ${IP-0.0.0.0}
jobs: bundle exec rails runner bin/threaded.rb
```

取消注释[这几行](https://github.com/huginn/huginn/blob/master/Procfile#L6-L7)或者[这些](https://github.com/huginn/huginn/blob/master/Procfile#L28-L31)

```
# web: bundle exec unicorn -c config/unicorn.rb
# jobs: bundle exec rails runner bin/threaded.rb
```

Export 初始化 scripts:

```
sudo bundle exec rake production:export
```

> **注意：**每次你修改了 `.env` 或者你的 procfile 文件，你都必须要重新 export 出事 script。

#### 设置 Logrotate

```
sudo cp deployment/logrotate/huginn /etc/logrotate.d/huginn
```

#### 确保你的 Huginn 实例正在运行

sudo bundle exec rake production:status

### 6. Nginx

> **注意：**Nginx 是 Huginn 官方支持的 web 服务器。如果你不会或者不想使用 Nginx 作为你的 web 服务器，参考 wiki 的文章来使用配置 [apache](https://github.com/huginn/huginn/wiki/Apache-Huginn-configuration)

#### 安装

```
sudo apt-get install -y nginx
```

#### 网站配置

复制示例网站配置：

```
sudo cp deployment/nginx/huginn /etc/nginx/sites-available/huginn
sudo ln -s /etc/nginx/sites-available/huginn /etc/nginx/sites-enabled/huginn
```

确保编辑配置文件以匹配你的设置，如果你正在运行多个nginx站点，请从 `listen` 指令中删除 `default_server` 参数：

```
# Change YOUR_SERVER_FQDN to the fully-qualified
# domain name of your host serving Huginn.
sudo editor /etc/nginx/sites-available/huginn
```

**如果 huginn 是唯一可用的 nginx 网站**，删除默认的 nginx 网站：

```
sudo rm /etc/nginx/sites-enabled/default
```

### Restart

```
sudo service nginx restart
```

完成。


## 参考

1. https://github.com/huginn/huginn
2. https://github.com/huginn/huginn/blob/master/doc/manual/installation.md



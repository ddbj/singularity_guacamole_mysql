# singularity_guacamole_mysql
Remote Desktop や VNC の接続を HTTP に変換して HTML5 ウェブブラウザで表示する Apache Guacamole を singularity instance で実行するためのレシピファイル・初期化スクリプトです。ユーザー認証にMySQLを使用します。

## singularity image のビルド
以下のコマンドで singularity image をビルドしてください。
```
$ sudo singularity build guacamole.sif Singularity
```
## 初期設定
以下のコマンドで singularity isntance 起動のための初期設定を行います。実行前に init.sh 内の MYSQL_ROOT_PASSWD, MYSQL_GUACAMOLE_USER_PASSWD, MYSQL_PORT, GUACAMOLE_PORT, TOMCAT_SHUTDOWN_PORT, TOMCAT_PORT の値を適宜修正してください。

"Enter current password for root (enter for none):" と表示されたところで処理がインタラクティブになります。ここではリターンキーを押してください。

次に、"Set root password? [Y/n]" と表示されたところでYを入力し、MySQLのrootユーザーのパスワードを設定します。ここで、init.shのMYSQL_ROOT_PASSWDに設定した値を入力してください。以降はすべてYを入力してください。

処理が完了すると、dataディレクトリとstart_container.shファイルが生成されています。

```
$ bash init.sh
exec init_mysql.sh
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = "ja_JP",
	LC_ALL = (unset),
	LANG = "ja_JP.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
WARNING: Could not write to config file ./my.cnf: Read-only file system

Installing MySQL system tables...2021-03-17 18:46:46 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2021-03-17 18:46:46 0 [Note] Ignoring --secure-file-priv value as server is running with --bootstrap.
2021-03-17 18:46:46 0 [Note] ./bin/mysqld (mysqld 5.6.51) starting as process 18851 ...
2021-03-17 18:46:46 18851 [Note] InnoDB: Using atomics to ref count buffer pool pages
2021-03-17 18:46:46 18851 [Note] InnoDB: The InnoDB memory heap is disabled
2021-03-17 18:46:46 18851 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
2021-03-17 18:46:46 18851 [Note] InnoDB: Memory barrier is not used
2021-03-17 18:46:46 18851 [Note] InnoDB: Compressed tables use zlib 1.2.11
2021-03-17 18:46:46 18851 [Note] InnoDB: Using CPU crc32 instructions
2021-03-17 18:46:46 18851 [Note] InnoDB: Initializing buffer pool, size = 128.0M
2021-03-17 18:46:46 18851 [Note] InnoDB: Completed initialization of buffer pool
2021-03-17 18:46:46 18851 [Note] InnoDB: The first specified data file ./ibdata1 did not exist: a new database to be created!
2021-03-17 18:46:46 18851 [Note] InnoDB: Setting file ./ibdata1 size to 12 MB
2021-03-17 18:46:46 18851 [Note] InnoDB: Database physically writes the file full: wait...
2021-03-17 18:46:46 18851 [Note] InnoDB: Setting log file ./ib_logfile101 size to 48 MB
2021-03-17 18:46:46 18851 [Note] InnoDB: Setting log file ./ib_logfile1 size to 48 MB
2021-03-17 18:46:47 18851 [Note] InnoDB: Renaming log file ./ib_logfile101 to ./ib_logfile0
2021-03-17 18:46:47 18851 [Warning] InnoDB: New log files created, LSN=45781
2021-03-17 18:46:47 18851 [Note] InnoDB: Doublewrite buffer not found: creating new
2021-03-17 18:46:47 18851 [Note] InnoDB: Doublewrite buffer created
2021-03-17 18:46:47 18851 [Note] InnoDB: 128 rollback segment(s) are active.
2021-03-17 18:46:47 18851 [Warning] InnoDB: Creating foreign key constraint system tables.
2021-03-17 18:46:47 18851 [Note] InnoDB: Foreign key constraint system tables created
2021-03-17 18:46:47 18851 [Note] InnoDB: Creating tablespace and datafile system tables.
2021-03-17 18:46:47 18851 [Note] InnoDB: Tablespace and datafile system tables created.
2021-03-17 18:46:47 18851 [Note] InnoDB: Waiting for purge to start
2021-03-17 18:46:47 18851 [Note] InnoDB: 5.6.51 started; log sequence number 0
2021-03-17 18:46:47 18851 [Note] RSA private key file not found: /usr/local/mysql/data//private_key.pem. Some authentication plugins will not work.
2021-03-17 18:46:47 18851 [Note] RSA public key file not found: /usr/local/mysql/data//public_key.pem. Some authentication plugins will not work.
2021-03-17 18:46:53 18851 [Note] Binlog end
2021-03-17 18:46:53 18851 [Note] InnoDB: FTS optimize thread exiting.
2021-03-17 18:46:53 18851 [Note] InnoDB: Starting shutdown...
2021-03-17 18:46:54 18851 [Note] InnoDB: Shutdown completed; log sequence number 1625977
OK

Filling help tables...2021-03-17 18:46:54 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2021-03-17 18:46:54 0 [Note] Ignoring --secure-file-priv value as server is running with --bootstrap.
2021-03-17 18:46:54 0 [Note] ./bin/mysqld (mysqld 5.6.51) starting as process 18875 ...
2021-03-17 18:46:54 18875 [Note] InnoDB: Using atomics to ref count buffer pool pages
2021-03-17 18:46:54 18875 [Note] InnoDB: The InnoDB memory heap is disabled
2021-03-17 18:46:54 18875 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
2021-03-17 18:46:54 18875 [Note] InnoDB: Memory barrier is not used
2021-03-17 18:46:54 18875 [Note] InnoDB: Compressed tables use zlib 1.2.11
2021-03-17 18:46:54 18875 [Note] InnoDB: Using CPU crc32 instructions
2021-03-17 18:46:54 18875 [Note] InnoDB: Initializing buffer pool, size = 128.0M
2021-03-17 18:46:54 18875 [Note] InnoDB: Completed initialization of buffer pool
2021-03-17 18:46:54 18875 [Note] InnoDB: Highest supported file format is Barracuda.
2021-03-17 18:46:54 18875 [Note] InnoDB: 128 rollback segment(s) are active.
2021-03-17 18:46:54 18875 [Note] InnoDB: Waiting for purge to start
2021-03-17 18:46:55 18875 [Note] InnoDB: 5.6.51 started; log sequence number 1625977
2021-03-17 18:46:55 18875 [Note] RSA private key file not found: /usr/local/mysql/data//private_key.pem. Some authentication plugins will not work.
2021-03-17 18:46:55 18875 [Note] RSA public key file not found: /usr/local/mysql/data//public_key.pem. Some authentication plugins will not work.
2021-03-17 18:46:55 18875 [Note] Binlog end
2021-03-17 18:46:55 18875 [Note] InnoDB: FTS optimize thread exiting.
2021-03-17 18:46:55 18875 [Note] InnoDB: Starting shutdown...
2021-03-17 18:46:56 18875 [Note] InnoDB: Shutdown completed; log sequence number 1625987
OK

To start mysqld at boot time you have to copy
support-files/mysql.server to the right place for your system

PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER !
To do so, start the server, then issue the following commands:

  ./bin/mysqladmin -u root password 'new-password'
  ./bin/mysqladmin -u root -h dbod04 password 'new-password'

Alternatively you can run:

  ./bin/mysql_secure_installation

which will also give you the option of removing the test
databases and anonymous user created by default.  This is
strongly recommended for production servers.

See the manual for more instructions.

You can start the MySQL daemon with:

  cd . ; ./bin/mysqld_safe &

You can test the MySQL daemon with mysql-test-run.pl

  cd mysql-test ; perl mysql-test-run.pl

Please report any problems at http://bugs.mysql.com/

The latest information about MySQL is available on the web at

  http://www.mysql.com

Support MySQL by buying support/licenses at http://shop.mysql.com

WARNING: Could not copy config file template ./support-files/my-default.cnf to
./my.cnf, may not have access rights to do so.
You may want to copy the file manually, or create your own,
it will then be used by default by the server when you start it.

exec mysql_secure_installation
INFO:    instance started successfully
setup guacamole database
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = "ja_JP",
	LC_ALL = (unset),
	LANG = "ja_JP.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").



NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MySQL
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MySQL to secure it, we'll need the current
password for the root user.  If you've just installed MySQL, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none): 
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MySQL
root user without the proper authorisation.

Set root password? [Y/n] Y
New password: 
Re-enter new password: 
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MySQL installation has an anonymous user, allowing anyone
to log into MySQL without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] Y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] Y
 ... Success!

By default, MySQL comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] Y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] Y
 ... Success!




All done!  If you've completed all of the above steps, your MySQL
installation should now be secure.

Thanks for using MySQL!


Cleaning up...
Warning: Using a password on the command line interface can be insecure.
Warning: Using a password on the command line interface can be insecure.
Warning: Using a password on the command line interface can be insecure.
Warning: Using a password on the command line interface can be insecure.
Warning: Using a password on the command line interface can be insecure.
INFO:    Stopping guacamole instance of /home/okuda/singularity/ubuntu-18.04-guacamole-1.3.0-mysql/guacamole.sif (PID=18915)
create server.xml
create guacamole_home
INFO:    instance started successfully
INFO:    Stopping guacamole instance of /home/okuda/singularity/ubuntu-18.04-guacamole-1.3.0-mysql/guacamole.sif (PID=19214)
create guacamole.properties
create start_container.sh
```

## singularity instance の起動
以下のコマンドで singularity instance を起動します。instance の起動後、instance 内でmysqld, guacd, tomcat　が起動されます。
```
$ bash start_container.sh
INFO:    instance started successfully
guacd[22]: INFO:	Guacamole proxy daemon (guacd) version 1.3.0 started
Using CATALINA_BASE:   /opt/tomcat
Using CATALINA_HOME:   /opt/tomcat
Using CATALINA_TMPDIR: /opt/tomcat/temp
Using JRE_HOME:        /usr
Using CLASSPATH:       /opt/tomcat/bin/bootstrap.jar:/opt/tomcat/bin/tomcat-juli.jar
Using CATALINA_OPTS:   
Tomcat started.
```

## guacamole へのアクセス
http://localhost:<TOMCAT_PORTの値>/guacamole をウェブブラウザで開いてください。

起動直後のユーザー名、パスワードはいずれも guacadmin に設定されています。

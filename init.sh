#!/bin/bash

CONTAINER_HOME=$(cd $(dirname $0); pwd)
IMAGE="${CONTAINER_HOME}/guacamole.sif"
INSTANCE="guacamole"

DATADIR="${CONTAINER_HOME}/data"

MYSQL_DATADIR="${DATADIR}/mysql_data"
MYSQL_CNF="${DATADIR}/my_mysql.cnf"
MYSQL_ROOT_PASSWD="testddbj"
MYSQL_GUACAMOLE_USER_PASSWD="testddbj"
MYSQL_PORT="53306"

GUACAMOLE_HOME="${DATADIR}/guacamole_home"
GUACAMOLE_PORT="54822"

TOMCAT_LOG="${DATADIR}/tomcat_logs"
TOMCAT_SHUTDOWN_PORT="58005"
TOMCAT_PORT="58080"


if [ ! -e ${DATADIR} ]; then
    mkdir ${DATADIR}
fi

if [ ! -e ${MYSQL_CNF} ]; then
    cat <<EOF > ${MYSQL_CNF}
[client]
port = ${MYSQL_PORT}
socket = /usr/local/mysql/data/mysql.sock
[mysql]
default-character-set = utf8
[mysqld]
port = ${MYSQL_PORT}
bind-address = 127.0.0.1
pid-file = /usr/local/mysql/data/mysql.pid
socket = /usr/local/mysql/data/mysql.sock
datadir = /usr/local/mysql/data/
skip-character-set-client-handshake
character-set-server = utf8
collation-server = utf8_general_ci
sql_mode = NO_ENGINE_SUBSTITUTION
EOF
fi

if [ ! -e ${MYSQL_DATADIR} ]; then
    mkdir ${MYSQL_DATADIR}

    echo 'exec init_mysql.sh'

    singularity exec \
    -B ${MYSQL_DATADIR}:/usr/local/mysql/data \
    -B ${MYSQL_CNF}:/usr/local/mysql/my_mysql.cnf \
    -B ${CONTAINER_HOME}/init_mysql.sh:/usr/local/bin/init_mysql.sh \
    -H ${DATADIR} \
    ${IMAGE} \
    bash /usr/local/bin/init_mysql.sh

    echo 'exec mysql_secure_installation'

    sleep 10

    singularity instance start \
    -B ${MYSQL_DATADIR}:/usr/local/mysql/data \
    -B ${MYSQL_CNF}:/usr/local/mysql/my_mysql.cnf \
    -B ${CONTAINER_HOME}/start_mysqld.sh:/usr/local/bin/start_mysqld.sh \
    -H ${DATADIR} \
    ${IMAGE} \
    ${INSTANCE}

    sleep 10

    singularity exec instance://${INSTANCE} bash /usr/local/bin/start_mysqld.sh

    echo 'setup guacamole database'

    singularity exec instance://${INSTANCE} ln -s /usr/local/mysql/data/mysql.sock /tmp/mysql.sock
    singularity exec instance://${INSTANCE} mysql_secure_installation
    singularity exec instance://${INSTANCE} rm /tmp/mysql.sock

    singularity exec instance://${INSTANCE} \
    mysql --defaults-file=/usr/local/mysql/my_mysql.cnf -uroot -p${MYSQL_ROOT_PASSWD} \
    -e "CREATE DATABASE guacamole_db";

    singularity exec instance://${INSTANCE} \
    bash -c "cat /usr/local/src/guacamole-auth-jdbc-1.3.0/mysql/schema/*.sql | mysql -uroot -p${MYSQL_ROOT_PASSWD} guacamole_db"

    singularity exec instance://${INSTANCE} \
    mysql --defaults-file=/usr/local/mysql/my_mysql.cnf -uroot -p${MYSQL_ROOT_PASSWD} \
    -e "CREATE USER 'guacamole_user'@'localhost' IDENTIFIED BY '${MYSQL_GUACAMOLE_USER_PASSWD}'";


    singularity exec instance://${INSTANCE} \
    mysql --defaults-file=/usr/local/mysql/my_mysql.cnf -uroot -p${MYSQL_ROOT_PASSWD} \
    -e "GRANT SELECT,INSERT,UPDATE,DELETE ON guacamole_db.* TO 'guacamole_user'@'localhost';"

    singularity exec instance://${INSTANCE} \
    mysql --defaults-file=/usr/local/mysql/my_mysql.cnf -uroot -p${MYSQL_ROOT_PASSWD} \
    -e 'FLUSH PRIVILEGES;'

    singularity instance stop ${INSTANCE}

    sleep 10
fi

echo 'create server.xml'

if [ ! -e "${DATADIR}/server.xml" ]; then
    cat <<EOF > "${DATADIR}/server.xml"
<?xml version="1.0" encoding="UTF-8"?>
<Server port="${TOMCAT_SHUTDOWN_PORT}" shutdown="SHUTDOWN">
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
  <GlobalNamingResources>
    <Resource name="UserDatabase" auth="Container"
              type="org.apache.catalina.UserDatabase"
              description="User database that can be updated and saved"
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
              pathname="conf/tomcat-users.xml" />
  </GlobalNamingResources>
  <Service name="Catalina">
    <Connector port="${TOMCAT_PORT}" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
    <Engine name="Catalina" defaultHost="localhost">
      <Realm className="org.apache.catalina.realm.LockOutRealm">
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
               resourceName="UserDatabase"/>
      </Realm>
      <Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log" suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b" />
      </Host>
    </Engine>
  </Service>
</Server>
EOF
fi

if [ ! -e "${DATADIR}/tomcat_logs" ]; then
    mkdir "${DATADIR}/tomcat_logs"
fi

echo 'create guacamole_home'

if [ ! -e "${GUACAMOLE_HOME}" ]; then
    mkdir ${GUACAMOLE_HOME}
    mkdir ${GUACAMOLE_HOME}/extensions
    mkdir ${GUACAMOLE_HOME}/lib

    singularity instance start \
    -B ${GUACAMOLE_HOME}:/etc/guacamole \
    ${IMAGE} \
    ${INSTANCE}

    sleep 10

    singularity exec instance://${INSTANCE} ln -s /usr/local/src/guacamole-auth-jdbc-1.3.0/mysql/guacamole-auth-jdbc-mysql-1.3.0.jar /etc/guacamole/extensions/guacamole-auth-jdbc-mysql-1.3.0.jar
    singularity exec instance://${INSTANCE} ln -s /usr/local/src/mysql-connector-java-5.1.49/mysql-connector-java-5.1.49-bin.jar /etc/guacamole/lib/mysql-connector-java-5.1.49-bin.jar

    singularity instance stop ${INSTANCE}

    sleep 10
fi

echo 'create guacamole.properties'

if [ ! -e "${GUACAMOLE_HOME}/guacamole.properties" ]; then
cat <<EOF > "${GUACAMOLE_HOME}/guacamole.properties"
guacd-hostname: localhost
guacd-port: ${GUACAMOLE_PORT}
#user-mapping: /etc/guacamole/user-mapping.xml
auth-provider: net.sourceforge.guacamole.net.auth.mysql.MySQLAuthenticationProvider
mysql-hostname: localhost
mysql-port: ${MYSQL_PORT}
mysql-database: guacamole_db
mysql-username: guacamole_user
mysql-password: testddbj
EOF

fi

echo 'create start_container.sh'

if [ ! -e "${CONTAINER_HOME}/start_container.sh" ]; then
cat <<EOF > "${CONTAINER_HOME}/start_container.sh"
#!/bin/bash
CONTAINER_HOME=\$(cd \$(dirname \$0); pwd)
IMAGE="\${CONTAINER_HOME}/guacamole.sif"
INSTANCE="guacamole"
GUACAMOLE_PORT="${GUACAMOLE_PORT}"

singularity instance start \\
-B \${CONTAINER_HOME}/start_mysqld.sh:/usr/local/bin/start_mysqld.sh \\
-B \${CONTAINER_HOME}/data/mysql_data:/usr/local/mysql/data \\
-B \${CONTAINER_HOME}/data/my_mysql.cnf:/usr/local/mysql/my_mysql.cnf \\
-B \${CONTAINER_HOME}/data/tomcat_logs:/opt/tomcat/logs \\
-B \${CONTAINER_HOME}/data/server.xml:/opt/tomcat/conf/server.xml \\
-B \${CONTAINER_HOME}/data/guacamole_home:/etc/guacamole \\
\${IMAGE} \\
\${INSTANCE}

sleep 10

singularity exec instance://\${INSTANCE} /usr/local/bin/start_mysqld.sh
singularity exec instance://\${INSTANCE} guacd -p /etc/guacamole/guacamole.pid -l \${GUACAMOLE_PORT}
singularity exec instance://\${INSTANCE} /opt/tomcat/bin/startup.sh
EOF

fi

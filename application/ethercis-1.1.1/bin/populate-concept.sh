#!/bin/bash
# description: Populate the concept table from terminology xml
#
# SCRIPT created 18-12-2015, CCH
#-----------------------------------------------------------------------------------
UNAME=`uname`
HOSTNAME=`hostname`
export ECIS_DEPLOY_BASE=/opt/ecis
export SYSLIB=${ECIS_DEPLOY_BASE}/lib/system
export COMMONLIB=${ECIS_DEPLOY_BASE}/lib/common
export APPLIB=${ECIS_DEPLOY_BASE}/lib/application
export LIB=${ECIS_DEPLOY_BASE}/lib/deploy


# Mailer configuration
ECIS_MAILER=echo

#force to use IPv4 so Jetty can bind to it instead of IPv6...
export _JAVA_OPTIONS="-Djava.net.preferIPv4Stack=true"

# runtime parameters
export JVM=${JAVA_HOME}/bin/java
export RUNTIME_HOME=/opt/ecis
export RUNTIME_ETC=/etc/opt/ecis
export RUNTIME_LOG=/var/opt/ecis
export RUNTIME_DIALECT=EHRSCAPE  #specifies the query dialect used in HTTP requests (REST)
export SERVER_PORT=8080 # the port address to bind to
export SERVER_HOST=`hostname` # the network address to bind to

export MAILER_CONF=${RUNTIME_ETC}/xcmail.cf

export JOOQ_DIALECT=POSTGRES
JOOQ_DB_PORT=5432
JOOQ_DB_HOST=postgres
JOOQ_DB_SCHEMA=ethercis
export JOOQ_URL=jdbc:postgresql://${JOOQ_DB_HOST}:${JOOQ_DB_PORT}/${JOOQ_DB_SCHEMA}
export JOOQ_DB_LOGIN=postgres
export JOOQ_DB_PASSWORD=postgres

CLASSPATH=./:\
${JAVA_HOME}/lib:\
${LIB}/ecis-core-1.1.0-SNAPSHOT.jar:\
${LIB}/ecis-knowledge-cache-1.1.0-SNAPSHOT.jar:\
${LIB}/ecis-ehrdao-1.1.0-SNAPSHOT.jar:\
${LIB}/jooq-pg-1.1.0-SNAPSHOT.jar:\
${APPLIB}/ehrxml.jar:\
${APPLIB}/oet-parser.jar:\
${APPLIB}/ecis-openehr.jar:\
${APPLIB}/types.jar:\
${APPLIB}/adl-parser-1.0.9.jar:\
${SYSLIB}/fst-2.40-onejar.jar:\
${SYSLIB}/jersey-json-1.19.jar:\
${SYSLIB}/gson-2.4.jar:\
${SYSLIB}/commons-collections4-4.0.jar:\
${SYSLIB}/jooq-3.5.3.jar:\
${SYSLIB}/postgresql-9.4-1204.jdbc42.jar:\
${SYSLIB}/dom4j-1.6.1.jar

# launch server
# ecis server is run as user ethercis
su - ethercis << _CONCEPT
    echo "populating concept table"
	${JVM} \
	-Xmx256M \
	-Xms256M \
	-cp ${CLASSPATH} \
	-Djava.util.logging.config.file=${RUNTIME_ETC}/logging.properties \
	-Dlog4j.configuration=file:${RUNTIME_ETC}/log4j.xml \
	-Djdbc.drivers=org.postgresql.Driver \
    -Dfile.encoding=UTF-8 \
	-Djooq.url=${JOOQ_URL} \
	-Djooq.login=${JOOQ_DB_LOGIN} \
	-Djooq.password=${JOOQ_DB_PASSWORD} \
	-Druntime.etc=${RUNTIME_ETC} \
	 com.ethercis.dao.access.support.TerminologySetter \
	-url ${JOOQ_URL} \
    -login ${JOOQ_DB_LOGIN} \
    -password ${JOOQ_DB_PASSWORD} \
    -terminology /etc/opt/ecis/terminology.xml
 2>> ${RUNTIME_LOG}/concept.log >> ${RUNTIME_LOG}/concept.log
_CONCEPT
exit 0
# end of file

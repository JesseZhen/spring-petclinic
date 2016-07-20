FROM ubuntu:16.04

MAINTAINER Alan Niu <wei-feng.niu@hpe.com>

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV MAVEN_HOME /opt/maven
ENV TOMCAT_HOME /opt/tomcat
ENV PATH $JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH

RUN apt-get -q update && apt-get install -y wget git-core software-properties-common

# Sets language to UTF8 : this works in pretty much all cases
ENV LANG en_US.UTF-8
RUN locale-gen $LANG

# Setup the openjdk 8 repo
RUN add-apt-repository ppa:openjdk-r/ppa

# Install java8
RUN apt-get update && apt-get install -y openjdk-8-jdk

# get maven 3.3.9
RUN wget --no-verbose -O /tmp/apache-maven-3.3.9-bin.tar.gz  http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz

# verify checksum
RUN echo "516923b3955b6035ba6b0a5b031fbd8b /tmp/apache-maven-3.3.9-bin.tar.gz" | md5sum -c

# install maven
RUN tar xzf /tmp/apache-maven-3.3.9-bin.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.3.9 ${MAVEN_HOME}
RUN ln -s ${MAVEN_HOME}/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.3.9-bin.tar.gz



#install tomcat7
ENV TOMCATVER 7.0.70
RUN (wget -O /tmp/tomcat7.tar.gz http://www.apache.org/dist/tomcat/tomcat-7/v${TOMCATVER}/bin/apache-tomcat-${TOMCATVER}.tar.gz && \
	echo "a551502b9f963e58e84d973216185e70 /tmp/tomcat7.tar.gz" | md5sum -c && \
	cd /opt && \
	tar zxf /tmp/tomcat7.tar.gz && \
	mv /opt/apache-tomcat* ${TOMCAT_HOME} && \
	chmod +x ${TOMCAT_HOME}/bin/* && \
	rm /tmp/tomcat7.tar.gz)
RUN rm -rf ${TOMCAT_HOME}/webapps/docs ${TOMCAT_HOME}/webapps/examples

# remove download archive files
RUN apt-get clean

# Pull project
RUN mkdir -p /home/spring-petclinic
RUN (git clone https://github.com/alanniu99/spring-petclinic.git /home/spring-petclinic && \
	 cd /home/spring-petclinic && \
	 mvn package && \
	 cp target/petclinic.war ${TOMCAT_HOME}/webapps/)

EXPOSE 8080
CMD ${TOMCAT_HOME}/bin/startup.sh && tail -f ${TOMCAT_HOME}/logs/catalina.out


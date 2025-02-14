FROM jenkins/jenkins:lts-jdk17

USER root

RUN apt update && apt -y upgrade && apt clean

ADD ./apache-maven-3.9.9-bin.tar.gz /usr/local/
ADD ./sonar-scanner-cli-4.8.0.2856.tar.gz /usr/local/

ENV MAVEN_HOME=/usr/local/apache-maven-3.9.9
ENV PATH=$JAVA_HOME/bin:/$MAVEN_HOME/bin:$PATH

RUN echo "jenkins ALL=NOPASSWORD: ALL" >> /etc/sudoers

USER jenkins
FROM jenkins/jenkins:lts-jdk17
ADD ./apache-maven-3.9.9-bin.tar.gz /usr/local/
ADD ./sonar-scanner-cli-4.8.0.2856.tar.gz /usr/local/

ENV MAVEN_HOME=/usr/local/apache-maven-3.9.9
ENV PATH=$JAVA_HOME/bin:/$MAVEN_HOME/bin:$PATH

USER root

RUN echo "jenkins ALL=NOPASSWORD: ALL" >> /etc/sudoers

USER jenkins
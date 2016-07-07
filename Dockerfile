FROM yfix/jenkins

# if we want to install via apt
USER root 

ENV COMPOSER_HOME "/usr/local/share/composer"
ENV PATH $PATH:$COMPOSER_HOME/vendor/bin/
ENV DEBIAN_FRONTEND noninteractive

# Bash as default shell
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

COPY ansible /tmp/ansible

RUN echo "===> Installing Docker" \
  && apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
  \
  && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
  && echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list \
  \
  && apt-get update && apt-get install -y \
    docker-engine \
  \
  && curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose \
  \
  \
  \
  && echo "===> Adding Ansible" \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7BB9C367 \
  && echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" | tee /etc/apt/sources.list.d/ansible.list \
  && apt-get -y update && apt-get install -y --no-install-recommends \
    ansible \
  \
  && echo "===> Adding ansible hosts" \
  && echo '[local]\nlocalhost\n' > /etc/ansible/hosts \
  \
  && echo "===> Installing ansible roles" \
  && ansible-galaxy install -ir /tmp/ansible/requirements.txt \
  \
  && echo "===> Run ansible playbook" \
  && ls -lr /tmp/ansible \
  && ansible-playbook --version \
  && ansible-playbook -vv -i "localhost," -c local /tmp/ansible/main.yml \
  \
  \
  \
  && echo "===> Cleanup" \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && rm -rf /usr/{{lib,share}/share/{man,doc,info,gnome/help,cracklib},{lib,lib64}/gconv} \
  \
  && echo "===> Done"

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 5.9.1
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
# Set up our PATH correctly so we don't have to long-reference npm, node, &c.
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
# Install nvm with node and npm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash \
  && source $NVM_DIR/nvm.sh \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default \
  && npm -g install \
    casperjs \
    phantomjs \
  \
  && echo "===> Done"

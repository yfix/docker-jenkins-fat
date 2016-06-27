FROM jenkins

# if we want to install via apt
USER root 

COPY ansible /tmp/ansible

ENV COMPOSER_HOME "/usr/local/share/composer"
ENV PATH $PATH:$COMPOSER_HOME/vendor/bin/

RUN echo "===> Adding Ansible..."  && \
	echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" | tee /etc/apt/sources.list.d/ansible.list && \
	echo "deb-src http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/ansible.list && \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7BB9C367 && \
	DEBIAN_FRONTEND=noninteractive apt-get -y update && \
	apt-get install -y ansible && \
	\
	echo "===> Adding hosts for convenience..." && \
	echo '[local]\nlocalhost\n' > /etc/ansible/hosts && \
	\
	echo "===> Installing ansible roles..." && \
	ansible-galaxy install -ir /tmp/ansible/requirements.txt && \
	\
	echo "===> Run ansible playbook..." && \
	ls -lr /tmp/ansible && \
	ansible-playbook --version && \
	ansible-playbook -vv -i "localhost," -c local /tmp/ansible/main.yml && \
	\
	\
	echo "===> Cleanup..." && \
	apt-get -y autoremove && \
	apt-get -y clean && \
	rm -rf /var/lib/apt/lists/*  /etc/apt/sources.list.d/ansible.list && \
	\
	echo "===> Done!"

#	\
#	\
#	echo "===> Adding Docker Engine..."  && \
#	echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | tee /etc/apt/sources.list.d/docker.list && \
#	apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
#	DEBIAN_FRONTEND=noninteractive apt-get -y update && \
#	apt-get install -y docker-engine && \


ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 5.9.1
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
# Set up our PATH correctly so we don't have to long-reference npm, node, &c.
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Bash as default shell
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install nvm with node and npm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash && \
    source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default && \
    npm -g install casperjs phantomjs && \
    \
    echo "===> Done!"

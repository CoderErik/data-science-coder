FROM ubuntu:20.04

USER root

# Basic utilities
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    bash \
    build-essential \
    ca-certificates \
    curl \
    docker.io \
    gcc \
    gdebi-core \
    git \
    htop \
    jq \
    locales \
    man \
    net-tools \
    openssl \
    python3 \
    python3-pip \
    r-base \
    rsync \
    software-properties-common \
    ssh \
    sudo \
    systemd \
    systemd-sysv \
    unzip \
    vim \
    wget
    
# Packages required for multi-editor support
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    libxtst6 \
    libxrender1 \
    libfontconfig1 \
    libxi6 \
    libgtk-3-0

# Install python packages
 RUN pip3 install pandas \
    scikit-learn \
    sklearn \
    matplotlib \
    flask \
    django \
    pyyaml \
    scipy \
    keras \
    tensorflow \
    beautifulsoup4 
  
# Install poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3

# Add poetry to path
ENV PATH $PATH:/home/coder/.poetry/bin

# Globally install jupyter
RUN pip3 install jupyterlab

# Install pycharm.
RUN mkdir -p /opt/pycharm
RUN curl -L "https://download.jetbrains.com/product?code=PCC&latest&distribution=linux" | sudo tar -C /opt/pycharm --strip-components 1 -xzvf -


# Add a binary to the PATH that points to the pycharm startup script.
RUN ln -s /opt/pycharm/bin/pycharm.sh /usr/bin/pycharm-community

# Install RStudio
RUN wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.4.1717-amd64.deb && \
	gdebi --non-interactive rstudio-server-1.4.1717-amd64.deb

# Create coder user
RUN useradd coder \
	--create-home \
	--shell=/bin/bash \
	--uid=1000 \
	--user-group && \
echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

# Ensure rstudio files can be written to by the coder user.
RUN chown -R coder:coder /var/lib/rstudio-server
RUN echo "server-pid-file=/tmp/rstudio-server.pid" >> /etc/rstudio/rserver.conf
RUN echo "server-data-dir=/tmp/rstudio" >> /etc/rstudio/rserver.conf

# Assign password "rstudio" to coder user.
RUN echo 'coder:rstudio' | chpasswd

# Assign locale
RUN locale-gen en_US.UTF-8

# Run as coder user
USER coder

# Add RStudio to path
ENV PATH /usr/lib/rstudio-server/bin:${PATH}

# Enables Docker starting with systemd
RUN systemctl enable docker

# go to coder home directory
WORKDIR /home/coder

# Set back to coder user
USER coder

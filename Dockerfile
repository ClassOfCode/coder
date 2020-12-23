FROM debian:latest

RUN apt-get update \
 && apt-get install -y \
    git \
    zip \
    ssh \
    man \
    nano \
    sudo \
    curl \
    htop \
    wget \
    unzip \
    procps \
    httpie \
    screen \
    python3 \
    locales \
    apt-utils \
    dumb-init \
    pkg-config \
    python3-pip \
    build-essential \
  && rm -rf /var/lib/apt/lists/*
 
# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen
ENV LANG=en_US.UTF-8

RUN chsh -s /bin/bash
ENV SHELL=/bin/bash

RUN adduser --gecos '' --disabled-password coder && \
  echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4.1/fixuid-0.4.1-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml

RUN cd /tmp && \
  curl -L --silent \
  `curl --silent "https://api.github.com/repos/cdr/code-server/releases/latest" \
    | grep '"browser_download_url":' \
    | grep "linux-amd64" \
    |  sed -E 's/.*"([^"]+)".*/\1/' \
  `| tar -xzf - && \
  mv code-server* /usr/local/lib/code-server && \
  ln -s /usr/local/lib/code-server/bin/code-server /usr/local/bin/code-server

USER coder
WORKDIR /home/coder

#Using Direct Installers
#Install Starship
RUN wget -q https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz && \
    tar -zxvf starship*.tar.gz && \
    sudo cp starship /usr/bin/ && \
    rm starship-x86_64-unknown-linux-gnu.tar.gz starship && \
    #Install ffsend
    wget -q https://github.com/timvisee/ffsend/releases/download/v0.2.68/ffsend-v0.2.68-linux-x64-static && \
    mv ./ffsend-* ./ffsend && chmod a+x ./ffsend && \
    sudo mv ./ffsend /usr/bin/

#Setting Up Node
#Installing Node (LTS) & NPM (LTS)
RUN curl -sL https://deb.nodesource.com/setup_lts.x | sudo bash - && sudo apt-get install -y nodejs

#Install Extensions
RUN code-server --force --install-extension github.github-vscode-theme

#BASHRC Commands (Template :  echo 'x' >> .bashrc)
#This adds Starship to BASH
RUN echo '{\n    "workbench.colorTheme": "GitHub Dark" \n}' >> /home/coder/.local/share/code-server/User/settings.json && \
    echo 'eval "$(starship init bash)"' >> .bashrc

CMD /usr/local/bin/code-server --disable-telemetry --bind-addr 0.0.0.0:$PORT /home/coder/
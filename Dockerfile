FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Add architecture for Wine
RUN dpkg --add-architecture i386

# Install stuff
RUN apt update && apt install -y \
    xfce4 xfce4-goodies \
    tightvncserver \
    wget curl \
    git gitg \
    python3 python3-pip \
    net-tools supervisor \
    novnc websockify \
    chromium-browser \
    software-properties-common \
    wine64 wine32 \
    gnome-terminal \
    && apt clean

# Install Code-OSS (VS Code open source build)
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' && \
    apt update && apt install -y code && rm microsoft.gpg

# Create user
RUN useradd -m dev && echo "dev:dev" | chpasswd && adduser dev sudo

USER dev
WORKDIR /home/dev

# Set up VNC
RUN mkdir ~/.vnc && \
    echo "dev" | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd && \
    echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &' > ~/.vnc/xstartup && \
    chmod +x ~/.vnc/xstartup

# Add launcher
RUN echo "vncserver :1 -geometry 1280x800 -depth 24" > ~/start.sh && chmod +x ~/start.sh

EXPOSE 6080

# Default command: Start VNC and noVNC
CMD ["bash", "-c", "vncserver :1 && websockify --web=/usr/share/novnc/ 6080 localhost:5901"]

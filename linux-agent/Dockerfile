# syntax=docker/dockerfile:1
FROM ubuntu:24.04

# Use bash for RUN steps
SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV QT_VERSION=6.10.0
ENV PATH="/opt/Qt/${QT_VERSION}/gcc_64/bin:${PATH}"

# ---------------------------------------------------------------
# 1. Core build dependencies for Azure self-hosted Linux agent
# ---------------------------------------------------------------
RUN set -eux; \
    mkdir -p /var/lib/apt/lists/partial && chmod 755 /var/lib/apt/lists/partial; \
    apt-get clean; \
    apt-get update -o Acquire::CompressionTypes::=gz; \
    apt-get install -y --no-install-recommends ca-certificates tzdata curl wget gnupg apt-transport-https unzip xz-utils \
        build-essential gcc-14 g++-14 make clang lld lldb ninja-build cmake git python3 python3-venv python3-pip \
        libglib2.0-0 libdbus-1-3 libxext-dev libxrandr-dev libxinerama-dev libxi-dev libxcursor-dev libxkbcommon-x11-0 libxcb-cursor0 libxcb-icccm4 \
        libxcb-image0 libxcb-keysyms1 libxcb-render-util0 libxcb-util1 libgl1-mesa-dev libglu1-mesa-dev libglx-dev \
        libpulse-dev libasound2-dev libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 libopencv-dev \
        libtiff-dev libtiff6 libjpeg-turbo8 libpng-dev file patchelf desktop-file-utils zsync \
        libssl-dev libicu-dev libkrb5-3 zlib1g-dev fuse3 libfuse2 libxcb-xfixes0; \
    apt-get upgrade -y; \
    rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------------------
# 2. Fix Qt AppImage plugin expecting libtiff.so.5
# -------------------------------------------------------------------
RUN set -eux; \
    if [ -f /usr/lib/x86_64-linux-gnu/libtiff.so.6 ]; then \
        ln -sf /usr/lib/x86_64-linux-gnu/libtiff.so.6 /usr/lib/x86_64-linux-gnu/libtiff.so.5; \
    fi

# ------------------------------------------------------------------
# 3. Set GCC/G++ 14 as default system compilers
# ------------------------------------------------------------------
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 100

# ------------------------------------------------------------------
# 4. Python pip + aqtinstall
# ------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir --upgrade --ignore-installed pip setuptools wheel aqtinstall --break-system-packages

# ------------------------------------------------------------------
# 5. Install Qt 6.10.0 (desktop GCC)
# ------------------------------------------------------------------
RUN mkdir -p /opt/Qt && \
    python3 -m aqt install-qt linux desktop 6.10.0 -m all --outputdir /opt/Qt

# ------------------------------------------------------------------
# 6. Azure Pipelines (Azure DevOps) agent 4.264.2
# ------------------------------------------------------------------
USER root
RUN useradd -m -s /bin/bash azureuser
WORKDIR /home/azureuser/linux-agent

RUN wget -q https://download.agent.dev.azure.com/agent/4.264.2/vsts-agent-linux-x64-4.264.2.tar.gz -O agent.tar.gz && \
    tar -xzf agent.tar.gz -C /home/azureuser/linux-agent && \
    rm agent.tar.gz

# ------------------------------------------------------------------
# 7. Copy project and start script
# ------------------------------------------------------------------
WORKDIR /home/azureuser/linux-agent
COPY start.sh .
RUN apt-get update && apt-get install -y dos2unix && \
    dos2unix /home/azureuser/linux-agent/start.sh && \
    chown -R azureuser:azureuser /home/azureuser/linux-agent && \
    chmod +x /home/azureuser/linux-agent/start.sh && \
    rm -rf /var/lib/apt/lists/*

USER azureuser
ENTRYPOINT ["./start.sh"]

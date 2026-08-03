# syntax=docker/dockerfile:1
FROM ubuntu:24.04

# Use bash for RUN steps
SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV QT_VERSION=6.10.2
ENV PATH="/opt/Qt/${QT_VERSION}/gcc_64/bin:${PATH}"

# ---------------------------------------------------------------
# 1. Core build dependencies for Azure self-hosted Linux agent
# ---------------------------------------------------------------
RUN set -eux; \
    mkdir -p /var/lib/apt/lists/partial && chmod 755 /var/lib/apt/lists/partial; \
    apt-get clean; \
    apt-get update -o Acquire::CompressionTypes::=gz; \
    apt-get install -y --no-install-recommends ca-certificates tzdata curl wget gnupg apt-transport-https unzip xz-utils usbutils \
        build-essential gcc-14 g++-14 make clang lld lldb ninja-build cmake git python3 python3-venv python3-pip \
        libglib2.0-0 libdbus-1-3 libxext-dev libxrandr-dev libxinerama-dev libxi-dev libxcursor-dev libxkbcommon-x11-0 libxkbcommon-x11-dev \
        libxcb-cursor0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-render-util0 libxcb-util1 libgl1-mesa-dev libglu1-mesa-dev libglx-dev \
        libpulse-dev libasound2-dev libopencv-dev libleptonica-dev libtesseract-dev tesseract-ocr libusb-1.0-0-dev \
        libtiff-dev libtiff6 libjpeg-turbo8 libpng-dev file patchelf desktop-file-utils zsync libsystemd-dev \
        libssl-dev libicu-dev libkrb5-3 zlib1g-dev kmod fuse3 libfuse2 libxcb-xfixes0 p7zip-full \
        libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl \
        gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio gstreamer1.0-qt6 libvulkan-dev ninja-build \
        libwayland-dev libwayland-client0 libwayland-cursor0 libwayland-egl1 libwayland-server0 qt6-wayland libxkbfile-dev libxkbfile1 \
        libpcsclite-dev libpcsclite1; \
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
# 4. Python pip + aqtinstall + pyusb + pyserial
# ------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir --upgrade --ignore-installed pip setuptools wheel aqtinstall pyusb pyserial --break-system-packages

# ------------------------------------------------------------------
# 5. Install onnxruntime + onnxruntime-gpu + CUDA
# ------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir --upgrade onnxruntime onnxruntime-gpu --break-system-packages
RUN python3 -m pip install --pre --index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/ort-cuda-13-nightly/pypi/simple/ --no-cache-dir --upgrade onnxruntime-gpu --break-system-packages

# ------------------------------------------------------------------
# 6. Install Qt 6.10.2 (desktop GCC)
# ------------------------------------------------------------------
RUN mkdir -p /opt/Qt && aqt install-qt linux desktop 6.10.2 -m all --outputdir /opt/Qt

# ------------------------------------------------------------------
# 7. Download, build, install Qt 6.10.2 multimedia source
# ------------------------------------------------------------------
RUN wget -q https://download.qt.io/official_releases/qt/6.10/6.10.2/submodules/qtmultimedia-everywhere-src-6.10.2.tar.xz && \
    tar xf qtmultimedia-everywhere-src-6.10.2.tar.xz && \
    cd qtmultimedia-everywhere-src-6.10.2 && \
    sed -i '/qt_build_repo()/i find_package(Qt6 REQUIRED COMPONENTS GuiPrivate QuickPrivate)' CMakeLists.txt && \
    /opt/Qt/6.10.2/gcc_64/bin/qt-cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/Qt/6.10.2/gcc_64 . && \
    cmake --build . --parallel && \
    cmake --install .

# ------------------------------------------------------------------
# 8. Azure Pipelines (Azure DevOps) agent 4.269.0 and libdpp@10.0.28
# ------------------------------------------------------------------
USER root
RUN useradd -m -s /bin/bash azureuser
WORKDIR /home/azureuser/linux-agent

RUN wget -q https://github.com/brainboxdotcc/DPP/releases/download/v10.1.5/libdpp-10.1.5-linux-x64.deb -O libdpp.deb && \
    apt install ./libdpp.deb -f && \
    rm libdpp.deb

RUN wget -q https://download.agent.dev.azure.com/agent/5.277.0/vsts-agent-linux-x64-5.277.0.tar.gz -O agent.tar.gz && \
    tar -xzf agent.tar.gz -C /home/azureuser/linux-agent && \
    rm agent.tar.gz

# ------------------------------------------------------------------
# 9. Copy project and start script
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

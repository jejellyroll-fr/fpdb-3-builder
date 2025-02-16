FROM mcr.microsoft.com/vscode/devcontainers/base:0-bullseye

# Installer les dépendances nécessaires pour la compilation de Python
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    cmake \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    sudo

# Télécharger et installer Python 3.11
RUN wget https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tgz && \
    tar -xf Python-3.11.0.tgz && \
    cd Python-3.11.0 && \
    ./configure --enable-optimizations && \
    make -j $(nproc) && \
    make altinstall && \
    rm -rf Python-3.11.0 Python-3.11.0.tgz

# Créer un utilisateur non-root pour installer Homebrew
RUN useradd -m brewuser && echo "brewuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER brewuser
WORKDIR /home/brewuser

# Installer Homebrew et ajouter au PATH
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/brewuser/.profile

ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

# Installer les dépendances MacOS via Homebrew
RUN brew install cmake

# Revenir à l'utilisateur root pour le reste du Dockerfile
USER root
WORKDIR /app

# Copier le projet dans le conteneur
COPY . /app

# Installer les dépendances Python
RUN pip3.11 install -r fpdb-3/requirements_macos.txt

# Construire poker-eval
RUN cd fpdb-3/pypoker-eval/poker-eval && \
    mkdir -p build && cd build && \
    cmake .. && make

# Construire pypoker-eval
RUN cd fpdb-3/pypoker-eval && \
    mkdir -p build && cd build && \
    cmake -DPython3_EXECUTABLE=$(which python3.11) \
          -DPython3_INCLUDE_DIR=/usr/local/include/python3.11 \
          -DPython3_LIBRARY=/usr/local/lib/libpython3.11.so \
          .. && make

# Copier la bibliothèque générée
RUN find fpdb-3/pypoker-eval/build -name "pypokereval.so" -exec cp {} fpdb-3/pypoker-eval/_pokereval_3_11.so \;

# Construire le projet final
RUN chmod +x ./build_fpdb-osx.sh && ./build_fpdb-osx.sh



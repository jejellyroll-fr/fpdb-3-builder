FROM mcr.microsoft.com/vscode/devcontainers/base:0-bullseye

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    cmake \
    python3.11 \
    python3-pip \
    build-essential

# Installer brew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

# Installer les dépendances MacOS via brew
RUN brew install cmake

# Copier le projet dans le conteneur
COPY . /app
WORKDIR /app

# Installer les dépendances Python
RUN pip install -r fpdb-3/requirements_macos.txt

# Construire poker-eval
RUN cd fpdb-3/pypoker-eval/poker-eval && \
    mkdir -p build && cd build && \
    cmake .. && make

# Construire pypoker-eval
RUN cd fpdb-3/pypoker-eval && \
    mkdir -p build && cd build && \
    cmake -DPython3_EXECUTABLE=$(which python3) \
          -DPython3_INCLUDE_DIR=/usr/include/python3.11 \
          -DPython3_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.11.so \
          .. && make

# Copier la bibliothèque générée
RUN find fpdb-3/pypoker-eval/build -name "pypokereval.so" -exec cp {} fpdb-3/pypoker-eval/_pokereval_3_11.so \;

# Construire le projet final
RUN chmod +x ./build_fpdb-osx.sh && ./build_fpdb-osx.sh

FROM archlinux:base-devel
# makepkg cannot run on root so that create user
ARG USERNAME=u1and0
ARG UID=1000
ARG GID=1000
COPY mirrorlist /etc/pacman.d/mirrorlist
RUN pacman -Syu --noconfirm && \
    echo "USERNAME: $USERNAME UID: $UID GID: $GID" &&\
    groupadd -g ${GID} ${USERNAME} &&\
    useradd -u ${UID} -g ${GID} -m -s /bin/bash ${USERNAME} &&\
    passwd -d ${USERNAME} &&\
    mkdir -p /etc/sudoers.d &&\
    touch /etc/sudoers.d/${USERNAME} &&\
    echo "${USERNAME} ALL=(ALL) ALL" > /etc/sudoers.d/${USERNAME} &&\
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME} &&\
    sudo pacman -S --noconfirm \
        # base
        cmake git openssh \
        # tesseract
        tesseract-data-eng tesseract-data-jpn &&\
    # install OpenCV(enable tesseract support)
    mkdir -p /tmp/install_opencv &&\
    cd /tmp/install_opencv &&\
    curl -sSL https://github.com/yumetodo/tesseract_opencv_pkg/releases/download/v4.5.0-1/opencv-tesseract-4.5.0-1-x86_64.pkg.tar.zst -o opencv-tesseract-4.5.0-1-x86_64.pkg.tar.zst &&\
    pacman -U --noconfirm opencv-tesseract-4.5.0-1-x86_64.pkg.tar.zst &&\
    cd /tmp &&\
    rm -rf install_opencv &&\
    # sudo pacman -Scc <-- doen't work. Why??
    # Workaround of above, erase /var/cache/pacman/pkg/* files
    rm -f /var/cache/pacman/pkg/*

USER ${USERNAME}
WORKDIR /home/${USERNAME}
CMD ["/bin/bash"]

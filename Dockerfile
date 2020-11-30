FROM archlinux:base-devel
# makepkg cannot run on root so that create user
ARG USERNAME=u1and0
ARG UID=1000
ARG GID=1000
RUN pacman -Syu --noconfirm && \
    echo "USERNAME: $USERNAME UID: $UID GID: $GID" &&\
    groupadd -g ${GID} ${USERNAME} &&\
    useradd -u ${UID} -g ${GID} -m -s /bin/bash ${USERNAME} &&\
    passwd -d ${USERNAME} &&\
    mkdir -p /etc/sudoers.d &&\
    touch /etc/sudoers.d/${USERNAME} &&\
    echo "${USERNAME} ALL=(ALL) ALL" > /etc/sudoers.d/${USERNAME} &&\
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}
COPY --chown=${USERNAME}:${USERNAME} PKGBUILD /home/${USERNAME}/build/
USER ${USERNAME}
WORKDIR /home/${USERNAME}/build/
RUN ls -la &&\
    sudo pacman -S --noconfirm \
        # base
        cmake git openssh \
        # tesseract
        tesseract tesseract-data-eng tesseract-data-jpn \
        # opencv depends
        tbb openexr gst-plugins-base libdc1394 cblas lapack libgphoto2 openjpeg2 ffmpeg &&\
    # Build OpenCV(enable tesseract support)
    sudo -u ${USERNAME} makepkg --noconfirm -sir &&\
    cd .. &&\
    rm -rf build &&\
    sudo pacman -Scc
WORKDIR /home/${USERNAME}
CMD ["/bin/bash"]

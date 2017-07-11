FROM debian:jessie
ENV container docker

RUN apt-get -y update && \
    apt-get -y install \
        git vim parted \
        quilt realpath qemu-user-static debootstrap zerofree pxz zip dosfstools \
        bsdtar libcap2-bin rsync grep \
        sudo systemd systemd-sysv\
    && rm -rf /var/lib/apt/lists/*

RUN useradd -p '$1$9q2vAGyh$CxldNzX2DDlLSGA4kymTB1' tim
RUN adduser tim sudo


#RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); 
#RUN rm -f /lib/systemd/system/multi-user.target.wants/*; \
####rm -f /etc/systemd/system/*.wants/*;
RUN  rm -f /lib/systemd/system/local-fs.target.wants/*; \
 rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
 rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
 rm -f /lib/systemd/system/basic.target.wants/*; 

COPY . /pi-gen/

VOLUME [ "/sys/fs/cgroup", "/pi-gen/work", "/pi-gen/deploy"]

CMD ["/sbin/init"]

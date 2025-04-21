FROM sql4mpp/greenplum_adgp

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y openssh-server && apt-get install nano
RUN apt-get update && apt-get install -y net-tools && apt-get install -y ufw && \
    apt-get install --reinstall locales && locale-gen "en_US.UTF-8" && echo "gpadmin ALL=(ALL) ALL" >> /etc/sudoers

# Create user and set password for user and root user
RUN groupadd gpadmin
RUN  useradd -rm -d /home/gpadmin -s /bin/bash -g gpadmin -G sudo -u 1100 gpadmin && \
    echo 'gpadmin:gpadmin' | chpasswd && \
    ssh-keygen -A && \
    sudo usermod -aG sudo gpadmin && \
    sudo usermod -aG root gpadmin

RUN mkdir /tmp/gpdb/ && chmod 777 -R /tmp/gpdb/
RUN mv /root/repos/gpdb/* /tmp/gpdb/
RUN chmod 777 -R /tmp/gpdb/

RUN chmod 777 /usr/local/gpdb/greenplum_path.sh


USER gpadmin:gpadmin

RUN echo "y" | ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#RUN /usr/local/gpdb/greenplum_path.sh
WORKDIR /tmp/gpdb/gpAux/gpdemo


RUN echo "export MASTER_DATA_DIRECTORY=/tmp/gpdb/gpdemo/qddir/demoDataDir-1" >> ~/.bashrc && \
    echo "cd /tmp/gpdb/gpAux/gpdemo" >> ~/.bashrc && \
    echo "source /usr/local/gpdb/greenplum_path.sh" >> ~/.bashrc && \
    echo "echo GPADMIN LOADED =======================================" >> ~/.bashrc && \
    echo "export DATADIRS=/tmp/gpdb/gpdemo" >> ~/.bashrc && \
    echo "#!/bin/bash" >> /tmp/first_start.sh && \
    echo "whoami" >> /tmp/first_start.sh && \
#    echo "find /tmp/gpdb/gpdemo/" >> /tmp/first_start.sh && \
    echo "/usr/sbin/sshd -D" >> /tmp/first_start.sh && \
    echo "chmod 777 -R /tmp/gpdb/" >> /tmp/first_start.sh && \
    echo "mkdir /tmp/gpdb/gpdemo/" >> /tmp/first_start.sh && \
    echo "mkdir /tmp/gpdb/gpdemo/dbfast1" >> /tmp/first_start.sh && \
    echo "mkdir /tmp/gpdb/gpdemo/dbfast2" >> /tmp/first_start.sh && \
    echo "mkdir /tmp/gpdb/gpdemo/dbfast_mirror1" >> /tmp/first_start.sh && \
    echo "mkdir /tmp/gpdb/gpdemo/dbfast_mirror2" >> /tmp/first_start.sh && \
    echo "mkdir /tmp/gpdb/gpdemo/qddir" >> /tmp/first_start.sh && \
    echo "mkdir /tmp/gpdb/gpdemo/gpAdminLogs" >> /tmp/first_start.sh && \
    echo "chmod 777 -R /tmp/gpdb" >> /tmp/first_start.sh && \
    echo "make cluster" >> /tmp/first_start.sh && \
    echo "echo 'y' | gpstop" >> /tmp/first_start.sh && \
    echo "find /tmp/gpdb/gpdemo/" >> /tmp/first_start.sh && \
    echo "ls -l /tmp/gpdb/gpdemo/" >> /tmp/first_start.sh && \
    echo "ls -l /tmp/" >> /tmp/first_start.sh && \
    echo "env" >> /tmp/first_start.sh && \
    echo "cat /tmp/first_start.sh" >> /tmp/first_start.sh && \
    chmod +x /tmp/first_start.sh

RUN /usr/local/gpdb/greenplum_path.sh

ENV MASTER_DATA_DIRECTORY=/tmp/gpdb/gpdemo/qddir/demoDataDir-1
ENV DATADIRS=/tmp/gpdb/gpdemo
ENV GPHOME=/usr/local/gpdb/
ENV PYTHONPATH=/usr/local/gpdb/lib/python
ENV PATH=$PATH:/usr/local/gpdb/bin/
ENV OPENSSL_CONF=/usr/local/gpdb/etc/openssl.cnf
ENV LD_LIBRARY_PATH=/usr/local/gpdb/lib

# Expose the SSH port
EXPOSE 22
EXPOSE 6000

USER root
RUN chmod 777 -R /tmp/

RUN mkdir /var/run/sshd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile
CMD ["/usr/sbin/sshd", "-D"]

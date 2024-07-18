# 使用 Ubuntu 22.04 镜像作为基础镜像
FROM ubuntu:22.04

# 定义作者信息
LABEL author="corner" version="1.0"

# 工作目录
WORKDIR /root

# 安装所需软件包
RUN apt update && \
   apt upgrade -y && \
   DEBIAN_FRONTEND=noninteractive apt-get install -y \
   vim \
   build-essential \
   g++ \
   gdb \
   cmake \
   make \
   openssh-server \
   git \
   mysql-server \
   libmysqlclient-dev


# ssh，允许 root 密码登录，并设置密码为 1
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
   sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
   echo 'root:1' | chpasswd

# 拷贝 ssh 启动脚本
COPY startup.sh /root/startup.sh

# 增加可执行权限
RUN chmod +x /root/startup.sh

# 写追加到 .bashrc 文件
ADD bashrc /root/bashrc  
RUN echo "$(cat /root/bashrc)" >> /root/.bashrc
RUN rm -f /root/bashrc

# 创建 /root/project 文件夹
RUN mkdir /root/project

# 创建 MySQL 数据库和表格
# COPY create_tables.sql /root/create_tables.sql
# RUN service mysql start && \
#     mysql -u root -p1 < /root/create_tables.sql && \
#     service mysql stop

# 默认启动 /bin/bash
CMD ["/bin/bash"]

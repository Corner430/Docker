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
   libboost-dev \
   mysql-server \
   libmysqlclient-dev \
   redis-server


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

# 下载 json.hpp 到 /usr/include
# RUN wget https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp -O /usr/include/json.hpp

# 下载 muduo 到 /root 目录
RUN git clone https://github.com/chenshuo/muduo.git /root/muduo

# 注释掉 muduo 的 examples
RUN sed -i 's/^\s*option(MUDUO_BUILD_EXAMPLES/# &/' /root/muduo/CMakeLists.txt

# 进入 muduo 目录并编译
WORKDIR /root/muduo
RUN $PWD/build.sh
RUN $PWD/build.sh install

# 安装 muduo 到系统目录
RUN mv /root/build/release-install-cpp11/include/muduo /usr/include/muduo
RUN mv /root/build/release-install-cpp11/lib/libmuduo* /usr/local/lib

# 变更工作目录
WORKDIR /root

# 创建数据库
RUN service mysql start && \
    mysql -u root -p1 -e "CREATE DATABASE IF NOT EXISTS chat;" && \
    service mysql stop

# 复制 SQL 文件并导入数据
COPY chat.sql /root/chat.sql
RUN service mysql start && \
    mysql -u root -p1 chat < /root/chat.sql && \
    service mysql stop

# 编译安装 redis 开发工具 hiredis
RUN git clone https://github.com/redis/hiredis
WORKDIR /root/hiredis
RUN make && make install
RUN ldconfig /usr/local/lib

# 变更工作目录
WORKDIR /root

# 编译安装 nginx
RUN git clone https://github.com/nginx/nginx.git
RUN apt install -y libpcre3 libpcre3-dev
WORKDIR /root/nginx

# 编译 nginx，激活 tcp 负载均衡模块
RUN ./auto/configure --with-stream  
RUN make && make install

# 变更工作目录
WORKDIR /root

# 拷贝 nginx 配置文件自动脚本
COPY insert_stream.sh /usr/local/nginx/conf/insert_stream.sh

# 增加可执行权限
RUN chmod +x /usr/local/nginx/conf/insert_stream.sh

# 运行 nginx 配置文件自动脚本
RUN /usr/local/nginx/conf/insert_stream.sh

# 删除自动脚本
RUN rm -f /usr/local/nginx/conf/insert_stream.sh

# 删除 muduo 目录
RUN rm -rf /root/muduo
RUN rm -rf /root/build

# 删除 hiredis 文件夹
RUN rm -rf /root/hiredis

# 删除 nginx 文件夹
RUN rm -rf /root/nginx

# 默认启动 /bin/bash
CMD ["/bin/bash"]

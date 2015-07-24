FROM centos:7
MAINTAINER "david k" <davidk@palantir.com>
ENV version=2.2.2 dir=ruby-2.2.2
RUN yum -y install wget tar
RUN wget http://cache.ruby-lang.org/pub/ruby/2.2/${dir}.tar.gz
RUN tar xf ${dir}.tar.gz
RUN yum groupinstall -y "Development Tools" "Development Libraries"
RUN yum install -y openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel
RUN pushd ruby-${version}; \
    ./configure --prefix=/opt/ruby-${version} --enable-load-relative --disable-install-capi --disable-debug --disable-dependency-tracking --disable-install-doc --enable-shared; \
    make -j2; \
    make install; \
    popd;
RUN rm -rf ruby-${version}

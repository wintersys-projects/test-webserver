apt-get install bison build-essential ca-certificates curl dh-autoreconf doxygen flex gawk git iputils-ping libcurl4-gnutls-dev libexpat1-dev libgeoip-dev liblmdb-dev libpcre3-dev libpcre++-dev libssl-dev libtool libxml2 libxml2-dev libyajl-dev locales lua5.3-dev pkg-config wget zlib1g-dev zlibc libxslt libgd-dev


cd /opt 
/usr/bin/git clone https://github.com/SpiderLabs/ModSecurity
cd ModSecurity
usr/bin/git submodule init
/usr/bin/git submodule update
./build.sh 
./configure
/usr/bin/make
/usr/bin/make install
cd /opt 
/usr/bin/git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git

apt-get install git g++ apt-utils autoconf automake build-essential libcurl4-openssl-dev libgeoip-dev liblmdb-dev libpcre2-dev libtool libxml2-dev libyajl-dev pkgconf zlib1g-dev

cd /opt
/usr/bin/git clone https://github.com/owasp-modsecurity/ModSecurity
cd ModSecurity/
/usr/bin/git submodule init
/usr/bin/git submodule update
/bin/sh build.sh
./configure --with-pcre2
make
make install

cd /opt
/usr/bin/git clone https://github.com/owasp-modsecurity/ModSecurity-nginx.git

Add this to the nginx build from source part when building nginx from source
./configure --add-module=/opt/ModSecurity-nginx

BuildModSecurity (generic for all webserver types)
1. Compile libmodsecurity as above
For nginx clone modsecurity-nginx  as above
2. Clone ModSecurity-nginx as above
3. compile nginx from source with mod-security added to the configure command

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




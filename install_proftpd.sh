sudo apt update -y
sudo apt install -y git make libpq-dev libssl-dev build-essential
git clone https://github.com/proftpd/proftpd.git
cd proftpd
./configure \
    --disable-auth-file --disable-ncurses --disable-ident --disable-shadow \
    --enable-openssl \
    --with-modules=mod_sql:mod_sql_postgres:mod_sql_passwd:mod_tls
make -j4
sudo make install
cd ..
sudo cp proftpd.conf /usr/local/etc/proftpd.conf
# start
sudo proftpd

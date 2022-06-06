if (test $DBHOST && test $DBNAME && test $DBUSER && test $DBPASS)
then
    cat << EOF > /etc/dovecot/dovecot-sql.conf.ext
driver = pgsql
connect = host=$DBHOST dbname=$DBNAME user=$DBUSER password=$DBPASS
default_pass_scheme = BLF-CRYPT
password_query = SELECT username,domain,password FROM users WHERE username='%u';
EOF
else
    echo 'No db configured'
fi

if (test $TLS_KEY_PATH && test $TLS_CERT_PATH)
then

    sed -i "s/^smtpd_tls_cert_file=.*/smtpd_tls_cert_file=$TLS_CERT_PATH/" /etc/postfix/main.cf
    sed -i "s/^smtpd_tls_key_file=.*/smtpd_tls_cert_file=$TLS_KEY_PATH/" /etc/postfix/main.cf
cat << EOF >> /etc/postfix/main.cf
smtpd_use_tls=yes
smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache
EOF
fi

exec supervisord -c /etc/supervisord.conf

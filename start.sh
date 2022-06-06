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

exec supervisord -c /etc/supervisord.conf

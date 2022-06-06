# Simple postfix relay

## Testing

```pwsh
$name = "postfix-test"
```

```sh
name=postfix-test
```

```sh
docker build . -t $name
docker run -p 25:25 -p 587:587 --name $name $name
```

## Note
The rsyslog stuff doesn't really work. Not removing it, may fix it later.


## Wip - users in SQL

```sh
$networkName = "postfix-relay"
docker network create $networkName
docker run -d --network $networkName -e POSTGRES_PASSWORD=$password --name postfix-postgres postgres

# Create table and enable crypto extension
docker exec -i --user postgres postfix-postgres psql -d postgres -q <<-EOSQL
CREATE EXTENSION pgcrypto;
CREATE TABLE users(
    username TEXT NOT NULL
    ,password TEXT NOT NULL
    ,domain TEXT NOT NULL
);
EOSQL

# Create a user with password
docker exec -i --user postgres postfix-postgres psql -d postgres -q <<-EOSQL
INSERT INTO users (username, password, domain) VALUES (
    'test',
    crypt('password', gen_salt('bf', 8)),
    ''
);
EOSQL

docker run -d -p 25:25 -p 587:587 -e DBHOST=postfix-postgres -e DBNAME=postgres -e DBUSER=postgres -e DBPASS=$password --network $networkName --name $name $name
```

## View postfix / dovecot logs
```sh
docker exec -it $name cat /var/log/mail.log
```

## Testing

Send a mail from powershell:
```pwsh
Send-MailMessage -SmtpServer localhost `
    -To user@example.lan `
    -From user@example.lan `
    -Subject test -Body test -Port 25 `
    -Credential ([PSCredential]::new("test",
        ("password" | ConvertTo-SecureString -AsPlainText -Force))) `
    -WarningAction SilentlyContinue
```
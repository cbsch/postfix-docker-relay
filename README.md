# Simple postfix relay


## Running the relay

This code example is with powershell. Examples for running the psql queries with bash is below

```powershell
$prefix = "pfrelay"
# Should be fine to have a simple password, the db is not network reachable
$dbPassword = "postgres"
$networkName = "$prefix-network"
$dbContainer = "$prefix-db"
$postfixContainer = "$prefix-postfix"

docker network create $networkName
mkdir -p /data/docker/pfrelay-db
docker run -d -v /data/docker/pfrelay-db:/var/lib/postgresql/data --restart=always --network $networkName -e POSTGRES_PASSWORD=$dbPassword --name $dbContainer postgres

# Create table and enable crypto extension
@"
CREATE EXTENSION pgcrypto;
CREATE TABLE users (
    username TEXT NOT NULL PRIMARY KEY
    ,password TEXT NOT NULL
    ,domain TEXT NOT NULL
);
"@ | docker exec -i --user postgres $dbContainer psql

# Create a user with password
@"
INSERT INTO users (username, password, domain) VALUES (
    'test',
    crypt('password', gen_salt('bf', 8)),
    ''
);
"@ | docker exec -i --user postgres $dbContainer psql

docker build . -t $postfixContainer

docker run -d --restart=always -p 25:25 -p 465:465 -e DBHOST=$dbContainer -e DBNAME=postgres -e DBUSER=postgres -e DBPASS=$dbPassword --network $networkName --name $postfixContainer $postfixContainer
```

### View postfix / dovecot logs
```sh
docker logs $postfixContainer
docker exec -it $postfixContainer cat /var/log/mail.log
```

## Note
The rsyslog stuff doesn't really work. Not removing it, may fix it later.


queries with shell
```sh
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

## Useful 3rd party testing tools

* https://mxtoolbox.com/diagnostic.aspx
* https://www.mail-tester.com/

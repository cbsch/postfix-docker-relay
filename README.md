# Simple postfix relay

## Testing

```pwsh
$name="postfix-test"
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
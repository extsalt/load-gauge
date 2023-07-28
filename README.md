#### httpl

Build

```shell
rebar3 escriptize
```

Run

```shell
_build/default/bin/httpl
```

Dev

```shell
rebar3 escriptize
_build/default/bin/httpl
```

Request

```shell
curl -X GET 'http://localhost:8008'
```

```shell
curl -X GET 'http://localhost:8008/ping'
```

```shell
curl -X POST \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "field1=value1&field2=value2&field3=value3" \
     http://localhost:8008/form
```

```shell
curl -X POST \
    -F "field1=value1" \
    -F "field2=value2" \
    http://localhost:8008/form
```
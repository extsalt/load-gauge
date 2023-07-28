FROM erlang:alpine

WORKDIR /app

COPY . .

ENTRYPOINT ['erlc']
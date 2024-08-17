FROM alpine:3.18.2

RUN apk add curl git bash postgresql-client aws-cli

COPY entrypoint.sh /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]

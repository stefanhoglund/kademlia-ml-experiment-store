
# # Run
# FROM alpine:3.20
# RUN apk add --no-cache socat bind-tools netcat-openbsd
# COPY entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]
# =======
FROM alpine

WORKDIR /
COPY ./bin/helloworld /bin

CMD ["helloworld", "talk"]

FROM alpine:latest

RUN apk add --no-cache samba samba-common-tools shadow bash

COPY smb.conf /etc/samba/smb.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 139 445

ENTRYPOINT ["/entrypoint.sh"]

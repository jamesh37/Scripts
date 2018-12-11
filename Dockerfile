FROM alpine:latest

# Install Curl
RUN apk update && apk add --no-cache curl

# Add crontab
COPY crontab /var/spool/cron/crontabs/root

# Copy script files
WORKDIR /bin/monitorscript/
COPY monitor.sh sites.txt ./

# Run crond
CMD crond -l 2 -f

#!/bin/bash

# ddev-webserver healthcheck

set -eo pipefail

sleeptime=59

# Make sure that both phpstatus, mounted code NOT mailhog
# (mailhog is excluded on hardened/prod)
# are working.
# Since docker doesn't provide a lazy period for startup,
# we track health. If the last check showed healthy
# as determined by existence of /tmp/healthy, then
# sleep at startup. This requires the timeout to be set
# higher than the sleeptime used here.
if [ -f /tmp/healthy ]; then
    printf "container was previously healthy, so sleeping ${sleeptime} seconds before continuing healthcheck...  "
    sleep ${sleeptime}
fi

phpstatus="false"
htmlaccess="false"
if curl --fail -s 127.0.0.1/phpstatus >/dev/null ; then
    phpstatus="true"
    printf "phpstatus: OK "
else
    printf "phpstatus: FAILED "
fi

if ls /var/www/html >/dev/null; then
    htmlaccess="true"
    printf "/var/www/html: OK "
else
    printf "/var/www/html: FAILED"
fi

if [ "${phpstatus}" = "true" ] && [ "${htmlaccess}" = "true" ]; then
    touch /tmp/healthy
    exit 0
fi
rm -f /tmp/healthy
exit 1



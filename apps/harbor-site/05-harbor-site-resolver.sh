#!/bin/sh
# Render the `resolver` directive nginx.conf includes, from the pod's own
# /etc/resolv.conf.
#
# WHY THIS EXISTS AT ALL: proxy_pass in harbor-site.conf carries variables, and
# nginx will not resolve a variable host without a `resolver`. The failure is at
# REQUEST time -- "no resolver defined to resolve s3.us-west-000.backblazeb2.com"
# -- not at startup, so without this the pod passes every probe and serves 502 to
# every visitor.
#
# The stock 15-local-resolvers.envsh does the same job, but only reaches
# nginx.conf through the envsubst template machinery, which needs a writable
# output directory. Doing it here keeps every other line of config static, and
# static config is what can be reviewed.
#
# nginx's docker-entrypoint.sh runs with `set -e`, so a non-zero exit here stops
# the container rather than starting an nginx that cannot reach the origin.
set -eu

mkdir -p /tmp/nginx

# IPv6 nameservers must be bracketed in the resolver directive.
resolvers="$(awk '/^nameserver[[:space:]]/ { if ($2 ~ /:/) printf "[%s] ", $2; else printf "%s ", $2 }' /etc/resolv.conf)"

if [ -z "${resolvers}" ]; then
    echo "harbor-site: no nameserver found in /etc/resolv.conf; refusing to start" >&2
    exit 1
fi

# ipv6=off: the clusters are IPv4-only for egress, and without this every origin
# lookup pays for an AAAA query that can only fail.
{
    printf 'resolver %svalid=30s ipv6=off;\n' "${resolvers}"
    printf 'resolver_timeout 5s;\n'
} > /tmp/nginx/resolver.conf

echo "harbor-site: resolver ${resolvers}"

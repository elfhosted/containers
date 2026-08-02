#!/usr/bin/env bash
# harbor-site: nginx serving Harbor's apex marketing site out of Backblaze B2.
#
# THERE IS NOTHING UPSTREAM TO RESOLVE. Every other harbor-* app here reads a
# release tag out of harborstremio/harbor-hosted; this one has no source
# repository at all. The entire image is the nginx configuration and the njs
# signing module in containers-private/apps/harbor-site/, and the site content it
# serves is not in the image -- it is 114 MB of objects in the elfhosted-harbor
# bucket under ${HARBOR_S3_PREFIX}site/, which is why a content change needs no
# build.
#
# SO THIS VERSION IS HAND-MAINTAINED, AND IT IS THE ONLY LEVER THAT MOVES THE
# IMAGE. Change anything in containers-private/apps/harbor-site/ and bump it in
# the same pull request. Skipping the bump does not fail: it produces new image
# contents under a tag that already exists, so the HelmRelease has nothing to
# change, Flux has nothing to reconcile, and imagePullPolicy IfNotPresent serves
# the old layer even across a pod restart. That is the trap recorded in
# harbor-hosted's HANDOVER.md §2, and here there is no tag to forget to cut --
# only this line.
#
# The same pattern is used by apps/dante and apps/tinyproxy, for the same reason.
#
# A NOTE ON WHAT ACTUALLY SHIPPED UNDER 1.0.0, because the comment above
# overstates its own mechanism. Several changes reached production without a bump
# -- the /updates/ channel routing and key fix, the harbor.site redirect block,
# and the default_server correction. They deployed anyway because Renovate tracks
# this image BY DIGEST, and the digest moves whether or not the tag does.
#
# That makes the bump a versioning discipline rather than the sole delivery
# mechanism, which is a weaker claim than the paragraph above makes. Bump it
# regardless: the digest tells you something changed, and only this line tells
# you what.
#
# CHANGELOG
#   1.0.0  initial: apex site at /, /api/curated/ and /api/hero/ from B2
#          (also carried, unversioned: /updates/ channel routing, the
#          harbor.site -> harbor.elfhosted.com redirect, default_server fix)
#   1.1.0  serve /robots.txt and /sitemap.xml from the image instead of the
#          bucket. The mirrored copies point at a third domain that redirects
#          back to this host, and the bucket re-syncs from the VPS, so the
#          correction only holds in the image. Also ALLOWS AI CRAWLERS, dropping
#          the nine Disallow rules and ai-train=no that Cloudflare's managed
#          robots.txt published for harbor.site -- a deliberate policy change,
#          not an omission. See harbor-site.conf.
#   1.2.0  serve /updates/ DIRECTLY on harbor.site instead of 308-ing it. Every
#          installed binary has that URL compiled in and cannot be repointed, so
#          a redirect the updater failed to follow would strand every client with
#          no way to reach them. Both hostnames now include one shared snippet,
#          so they cannot drift.
#   1.3.0  answer CORS preflight at the harbor.site edge instead of redirecting
#          it. Browsers do not follow a 3xx on an OPTIONS preflight, so the 308
#          broke every preflighted request -- writes -- while leaving simple
#          GETs working. Found in production after the cutover.
set -uo pipefail

printf '%s' "1.3.0"

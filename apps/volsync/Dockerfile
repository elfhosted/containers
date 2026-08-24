# ElfHosted volsync mover image.
#
# Identical to upstream except for one environment variable. restic is a Go
# binary, and Go sizes its thread pool from the NODE's core count rather than
# the container's CFS quota — 12 cores on surf through 88 on cc. Against the
# mover's 2-core limit that is up to 44x oversubscription: the pool burns the
# whole quota in the first milliseconds of each scheduling period and then
# stalls for the remainder, so movers were observed pinned at their ceiling
# while making poor progress.
#
# volsync exposes no mover env hook in ANY current release (checked 0.13.1
# through v0.16.0: moverAffinity/PodLabels/Resources/SecurityContext/
# ServiceAccount/Volumes only), so GOMAXPROCS cannot be set from the
# ReplicationSource spec. Baking it into the image is the only route.
#
# GOMAXPROCS MUST match `limits.cpu` on moverResources in the myprecious
# ReplicationSource templates. Change them together.
ARG VERSION
FROM quay.io/backube/volsync:${VERSION}

ENV GOMAXPROCS=2

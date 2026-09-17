# ElfHosted volsync mover image.
#
# Upstream plus two changes: GOMAXPROCS (below) and --exclude-caches on the
# restic backup (at the end of this file).
#
# GOMAXPROCS: restic is a Go binary, and Go sizes its thread pool from the
# NODE's core count rather than the container's CFS quota — 12 cores on surf
# through 88 on cc. Against the mover's 2-core limit that is up to 44x
# oversubscription: the pool burns the whole quota in the first milliseconds
# of each scheduling period and then stalls for the remainder, so movers were
# observed pinned at their ceiling while making poor progress.
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

# Skip the contents of any directory holding a CACHEDIR.TAG
# (https://bford.info/cachedir/), keeping the tag itself. myprecious tags
# regenerable app caches (tag-cache-dirs.sh in its tooling-scripts ConfigMap) so
# they stay out of the config PVC snapshots. Inert for untagged data, so it is
# safe for every ReplicationSource this mover serves.
#
# volsync 0.13.1 has no exclude hook; upstream added spec.restic.exclude.caches
# after v0.16.0. Once a release carries it, set that on the ReplicationSources
# and drop this patch. The grep fails the build if upstream reworks the line
# instead of shipping an image that silently backs caches up again.
RUN sed -i "s|--exclude='lost+found' \.|--exclude='lost+found' --exclude-caches .|" /mover-restic/entry.sh \
 && grep -q -- "--exclude='lost+found' --exclude-caches \." /mover-restic/entry.sh

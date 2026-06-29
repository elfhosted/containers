#!/usr/bin/env zx

// Builds a JSON string what images and their channels to process
// [
//   {"app":"ubuntu", "channel": "focal"},
//   {"app"...
// ]

$.verbose = false
import { Published } from './published.mjs';

let output = []
for (const path of await glob(['apps/*/metadata.json'])) {
  let {app, channels} = await fs.readJson(path);

  for (const channel of channels) {
    let publishedVersion = await Published(app, channel.name, channel.stable)

    // Tolerate a failing/empty upstream lookup: skip the app rather than
    // throwing (which would abort the whole matrix) or building an image
    // tagged with a null/empty version. A null version label can never match
    // `publishedVersion`, which otherwise forces a rebuild every run and
    // churns the :rolling digest. See apps/{decluttarr,plex-debrid}/ci/latest.sh.
    let upstreamVersion = await $`./.github/scripts/upstream.sh ${app} ${channel.name}`.nothrow()
    if (upstreamVersion.exitCode !== 0) {
      console.error(`skip ${app}/${channel.name}: upstream version lookup failed (exit ${upstreamVersion.exitCode})`)
      continue
    }
    let upstream = upstreamVersion.stdout.trim()
    if (upstream === '' || upstream === 'null') {
      console.error(`skip ${app}/${channel.name}: upstream version resolved empty/null`)
      continue
    }

    if (publishedVersion != upstream) {
      output.push({"app": app, "channel": channel.name})
    }
  }
}

console.log(`::set-output name=changes::${JSON.stringify(output)}`)

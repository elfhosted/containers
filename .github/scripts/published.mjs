export async function Published(app, channel, stable) {
  let headers = {}
  if (process.env.TOKEN) {
    headers = {
      Accept: 'application/vnd.github.v3+json',
      Authorization: `token ${process.env.TOKEN}`
    }
  }
  // Non-stable channels each get their own package (`${app}-${channel}`),
  // so the package name already disambiguates by channel. Stable channels
  // can share one package — e.g. ubuntu/{noble,jammy,focal} all push to
  // `ubuntu:` — so we have to filter tags by channel ourselves.
  let pkg = (stable ? app : `${app}-${channel}`)
  let res = await fetch(`https://api.github.com/users/elfhosted/packages/container/${pkg}/versions`, { headers })
  let data = await res.json()
  try {
    if (stable) {
      // Walk versions from most-recent to oldest, returning the first tag
      // that looks like it belongs to this channel. Tag layouts seen in the
      // wild: "${channel}-${date}" (ubuntu), "${channel}" (rolling-style),
      // and bare version strings like "3.6.14" for single-stable apps.
      for (const version of data) {
        const tags = version?.metadata?.container?.tags ?? []
        const match = tags.find(t => t === channel || t.startsWith(`${channel}-`))
        if (match) return match
      }
      // No channel-prefixed tag found — most likely a single-stable app
      // whose tag is just the bare upstream version. Fall back to the most
      // recent push, ignoring `rolling`/`testingz` floating tags so we
      // compare a real version against `upstream.sh`'s output.
      const floating = new Set(['rolling', 'testingz', 'latest'])
      for (const version of data) {
        const tags = version?.metadata?.container?.tags ?? []
        const real = tags.find(t => !floating.has(t))
        if (real) return real
      }
    }
    // Non-stable, or stable with no usable tags — original behaviour.
    return data[0].metadata.container.tags[0]
  } catch {
    console.log(`Error finding published version for ${pkg}`)
  }
}

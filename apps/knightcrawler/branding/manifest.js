import { MochOptions } from '../moch/moch.js';
import { showDebridCatalog } from '../moch/options.js';
import { Type } from './types.js';

const CatalogMochs = Object.values(MochOptions).filter(moch => moch.catalog);
const tenantName = process.env.TENANT_NAME;

export function manifest(config = {}) {
  return {
    id: `${tenantName}-knightcrawler.elfhosted.com`,
    version: '1337',
    name: getName(config),
    backgroundCredit: 'https://unsplash.com/photos/turned-on-flat-screen-television-EOQhsfFBhRk',
    description: getDescription(config),
    descriptionHTML: getDescriptionHTML(config),
    catalogs: getCatalogs(config),
    resources: getResources(config),
    types: [Type.MOVIE, Type.SERIES, Type.ANIME, Type.OTHER],
    logo: 'https://elfhosted.com/images/logo.svg',
    background: 'https://unsplash.com/photos/evlkOfkQ5rE/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8M3x8Y2luZW1hfGVufDB8fHx8MTcxMzc5NDg2OHww&force=true&w=1920',
    behaviorHints: {
      configurable: true,
      configurationRequired: false,
    }
  };
}

export function dummyManifest() {
  const manifestDefault = manifest();
  manifestDefault.catalogs = [{ id: 'dummy', type: Type.OTHER }];
  manifestDefault.resources = ['stream', 'meta'];
  return manifestDefault;
}

function getName(config) {
  const rootName = 'KnightCrawler';
  const mochSuffix = Object.values(MochOptions)
      .filter(moch => config[moch.key])
      .map(moch => moch.shortName)
      .join('/');
  return [rootName, mochSuffix, 'ElfHosted'].filter(v => v).join(' | ');
}

function getDescription(config) {
  return `KnightCrawler ${tenantName}: torrent streams provided by popular trackers and DMM hashes`;
}

function getDescriptionHTML(config) {
  return `This is an <A HREF="https://elfhosted.com">ElfHosted</A> instance of <A HREF="https://github.com/Gabisonfire/knightcrawler">KnightCrawler</A>, a fork of <A HREF="http://torrentio.strem.fm">torrentio.strem.fm</A>, which provides torrent streams from torrent providers' RSS feeds, and <A HREF="https://github.com/debridmediamanager/debrid-media-manager">DebridMediaManager</A> hashes.`
      + ` <br/><br/>The public instance (<A HREF="http://torrentio.elfhosted.com">torrentio.elfhosted.com</A>) is provided free for public use, and <A HREF="https://github.com/funkypenguin/elf-infra/blob/main/traefik-middleware/middleware-rate-limit-public-stremio-addon.yaml">rate-limited</A> appropriately for casual individual streaming use (<I>not automation</I>).`
      + ` <br/><br/><A HREF="https://elfhosted.com">ElfHosted</A> is an <A HREF="https://elfhosted.com/open/">open-source</A> PaaS built and run by <A HREF="https://geek-cookbook.funkypenguin.co.nz">geeks</A>, which self-hosts <A HREF="https://elfhosted.com/guides/media/">your favorite streaming apps</A> for you automatically and easily.`
      + ` <br/><br/>Hosted / private KnightCrawler instances with <A HREF="https://github.com/funkypenguin/elf-infra/blob/main/traefik-middleware/middleware-rate-limit-hosted-stremio-addon.yaml">rate-limits</A> appropriate for automation <A HREF="https://elfhosted.com/guides/media/stream-from-real-debrid-with-self-hosted-torrentio/">are available</A> for $0.15/day, with <A HREF="https://elfhosted.com/how-to/spend-elfbuckz/">$10 free credit</A> on <A HREF="https://store.elfhosted.com/my-account/">new accounts</A>.`
      + ` <br/><br/>An internal, un-rate-limited instance is provided free, with all <A HREF="https://elfhosted.com/apps/">ElfHosted apps</A>, for automation.`
      + ` <br/><br/>Why use <A HREF="https://elfhosted.com/stremio-addons/">ElfHosted Stremio addons</A>?
      <p>
            ✅ Highly-available, <A HREF="https://elfhosted.com/open/">open-source</A> infrastructure  / <A HREF="https://status.elfhosted.com/history/public-torrentio-indexer-addon"><IMG SRC="https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fgeek-cookbook%2Felfhosted-upptime%2Fmaster%2Fapi%2Fpublic-torrentio-indexer-addon%2Fuptime.json"></A><br/>
            ✅ Active contributors to <A HREF="https://www.reddit.com/r/StremioAddons/">r/StremioAddons</A> subreddit and <A HREF="https://discord.gg/zNRf6YF">Discord</A><br/>
            ✅ Geek out over <A HREF="https://fnky.nz/grafana-knightcrawler">public performance metrics</A><br/>
      </p>		`
}

function getCatalogs(config) {
  return CatalogMochs
      .filter(moch => showDebridCatalog(config) && config[moch.key])
      .map(moch => ({
        id: `knightcrawler-${moch.key}`,
        name: `${moch.name}`,
        type: 'other',
        extra: [{ name: 'skip' }],
      }));
}

function getResources(config) {
  const streamResource = {
    name: 'stream',
    types: [Type.MOVIE, Type.SERIES],
    idPrefixes: ['tt', 'kitsu']
  };
  const metaResource = {
    name: 'meta',
    types: [Type.OTHER],
    idPrefixes: CatalogMochs.filter(moch => config[moch.key]).map(moch => moch.key)
  };
  if (showDebridCatalog(config) && CatalogMochs.filter(moch => config[moch.key]).length) {
    return [streamResource, metaResource];
  }
  return [streamResource];
}

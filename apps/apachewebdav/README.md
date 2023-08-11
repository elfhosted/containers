## Project
[apachewebdav/apachewebdav](https://github.com/mgutt/docker-apachewebdav) is based on [bytemark/webdav](https://github.com/BytemarkHosting/docker-webdav) including different pull requests:
- [Fix non-ASCII filenames](https://github.com/BytemarkHosting/docker-webdav/pull/20)
- [Add PUID and PGID](https://github.com/BytemarkHosting/docker-webdav/pull/28)
- [Add umask](https://github.com/noodlefighter/docker-webdav/pull/1)
- [Add Windows 10 User-Agent](https://github.com/BytemarkHosting/docker-webdav/pull/11)
- [Disable DirectoryIndex to avoid DoS](https://github.com/BytemarkHosting/docker-webdav/pull/21)
- [Fix SSL Error](https://github.com/BytemarkHosting/docker-webdav/pull/23)
- [Add Apache Commons User-Agent](https://github.com/BytemarkHosting/docker-webdav/pull/25)

## Usage

### Basic WebDAV server

This example starts a WebDAV server on port 80. It can only be accessed with a single username and password.

When using unencrypted HTTP, use `Digest` authentication (instead of `Basic`) to avoid sending plaintext passwords in the clear.

```
docker run -d --restart always -e 'AUTH_TYPE'='Digest' -e 'USERNAME'='alice' -e 'PASSWORD'='mypassword' \
    -v '/mnt/webdav':'/var/lib/dav/data':'rw' -v '/mnt/appdata':'/var/lib/dav':'rw' \
    -p '80:80' 'apachewebdav/apachewebdav'
```

#### Via Docker Compose:

```
version: '3'
services:
  webdav:
    image: apachewebdav/apachewebdav
    restart: always
    ports:
      - "80:80"
    environment:
      AUTH_TYPE: Digest
      USERNAME: alice
      PASSWORD: mypassword
    volumes:
      - /mnt/appdata:/var/lib/dav
      - /mnt/webdav:/var/lib/dav/data

```
### Secure WebDAV with SSL

We recommend you use a reverse proxy (eg, Nginx Proxy Manager) to handle SSL certificates. If you're happy with a self-signed SSL certificate, specify `-e SSL_CERT=selfsigned` and the container will generate one for you.

```
docker run -d --restart always -e 'AUTH_TYPE'='Digest' -e 'USERNAME'='alice' -e 'PASSWORD'='mypassword' \
    -v '/mnt/webdav':'/var/lib/dav/data':'rw' -v '/mnt/appdata':'/var/lib/dav':'rw' \
    -e SSL_CERT=selfsigned -p '80:80' 'apachewebdav/apachewebdav'
```

If you bind mount a certificate chain to `/cert.pem` and a private key to `/privkey.pem`, the container will use that instead!

### Authenticate multiple clients

Specifying `USERNAME` and `PASSWORD` only supports a single user. If you want to have lots of different logins for various users, bind mount your own file to `/user.passwd` and the container will use that instead.

If using `Basic` authentication, run the following commands through the Containers Console:

```
touch user.passwd
htpasswd -B user.passwd alice
htpasswd -B user.passwd bob

```

If using `Digest` authentication, run the following commands. (NB: The default `REALM` is `WebDAV`. If you specify your own `REALM`, you'll need to run `htdigest` again with the new name.)

```
touch user.passwd
htdigest user.passwd WebDAV alice
htdigest user.passwd WebDAV bob

```

Once you've created your own `user.passwd`, bind mount it into your container with `-v /path/to/user.passwd:/user.passwd`.

### Environment variables

All environment variables are optional. You probably want to at least specify `USERNAME` and `PASSWORD` (or bind mount your own authentication file to `/user.passwd`) otherwise nobody will be able to access your WebDAV server!

* **`SERVER_NAMES`**: Comma-separated list of domains (eg, `example.com,www.example.com`). The first is set as the [ServerName](https://httpd.apache.org/docs/current/mod/core.html#servername), and the rest (if any) are set as [ServerAlias](https://httpd.apache.org/docs/current/mod/core.html#serveralias). The default is `localhost`.
* **`LOCATION`**: The URL path for WebDAV (eg, if set to `/webdav` then clients should connect to `example.com/webdav`). The default is `/`.
* **`AUTH_TYPE`**: Apache authentication type to use. This can be `Basic` (best choice for HTTPS) or `Digest` (best choice for HTTP). The default is `Basic`.
* **`REALM`**: Sets [AuthName](https://httpd.apache.org/docs/current/mod/mod_authn_core.html#authname), an identifier that is displayed to clients when they connect. The default is `WebDAV`.
* **`USERNAME`**: Authenticate with this username (and the password below). This is ignored if you bind mount your own authentication file to `/user.passwd`.
* **`PASSWORD`**: Authenticate with this password (and the username above). This is ignored if you bind mount your own authentication file to `/user.passwd`.
* **`ANONYMOUS_METHODS`**: Comma-separated list of HTTP request methods (eg, `GET,POST,OPTIONS,PROPFIND`). Clients can use any method you specify here without authentication. Set to `ALL` to disable authentication. The default is to disallow any anonymous access.
* **`SSL_CERT`**: Set to `selfsigned` to generate a self-signed certificate and enable Apache's SSL module. If you specify `SERVER_NAMES`, the first domain is set as the Common Name.
* **`PUID`**: file owner's UID of `/var/lib/dav/data`
* **`PGID`**: file owner's GID of `/var/lib/dav/data`
* **`PUMASK`**: umask of `/var/lib/dav/data`


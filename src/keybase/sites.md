# Keybase Sites

[Keybase Sites](https://book.keybase.io/sites) is a service built into [Keybase](https://keybase.io/) which hosts web sites from [KBFS](https://book.keybase.io/files) directories. It can be used to host sites containing **only static files** - there is no provision for running any kind of server-side scripting.

I'm using it to host the `jms1.info` site you're reading right now.

## Original write-up

[`https://jms1.pub/kbsites/`](https://jms1.pub/kbsites/) is the first set of information I wrote about Keybase Sites, and includes links to five different hostnames which illustrate how to host sites using five different kinds of sources:

* `/keybase/public/xxx/`
* `/keybase/private/user#kbpbot/` (private, with `kbpbot` having read-only access)
* `/keybase/team/xxx/` (with the `kbpbot` user as a team member with "reader" access)
* git repo `keybase://team/xxx/repo`, in `master` branch (with the `kbpbot` user as a team member with "reader" access)
* git repo `keybase://team/xxx/repo`, in some other branch (with the `kbpbot` user as a team member with "reader" access)

## `jms1.info`

Details about how I set up Keybase Sites for the `jms1.info` site. The site is hosted from a team directory with `kbpbot` as a team member with "reader" access.

### Keybase Team

Create a Keybase team with the `kbpbot` user as a member with `reader` permissions. This can be either a top-level team, or a sub-team. (I'm using a sub-team.)

```
keybase team create jms1team.sites
keybase team add-member -s -u kbpbot -r reader jms1team.sites
```

Create a KBFS directory to hold the site's files. In my case, I'm using the same team to host multiple sites, so each site has its own directory within the team.

```
mkdir /keybase/team/jms1team.sites/jms1.info
```

Create a dummy index page so you can test that the site is working.

```
cat > /keybase/team/jms1team.sites/jms1.info/index.html <<EOF
<html>
<head>
<title>jms1.info</title>
</head>
<body>
<p>test 1 2 3</p>
</body>
</html>
EOF
```

### DNS Records

I use [djbdns](https://cr.yp.to/djbdns.html) to serve my DNS data. Below are the actual [tinydns data](https://cr.yp.to/djbdns/tinydns-data.html) lines from my DNS data, along with what I *think* are the equivalent records in BIND format.

* For `jms1.info` ...

    ```
    +jms1.info:18.214.166.21:3600
    '_keybase_pages.jms1.info:kbp=/keybase/team/jms1team.sites/jms1.info:3600
    ```

    ```
    jms1.info.                 3600  IN A    18.214.166.21
    _keybase_pages.jms1.info.  3600  IN TXT  "kbp=/keybase/team/jms1team.sites/jms1.info"
    ```

    * The record for `jms1.info.` itself must be an A record, since the rules for CNAME records explicitly say that a resource record name which is a CNAME record, cannot *also* exist as any other kind of record. Since this record is the "root" of a domain, it must have an SOA record and one or more NS records, therefore it *cannot* also be a CNAME record.

        The IPv4 address, `18.214.166.21`, is the IP that `kbp.keybaseapi.com.` points to. This hasn't changed in a few years now, however if it *does* change in the future, I'll need to remember to update my own DNS records to match it.

    * The TXT record for `_keybase_pages.jms1.info.` is what tells Keybase Sites where to find the site's content. Because it points to a team folder, the `kbpbot` user needs to have at least "reader" permissions in that team.

* For `www.jms1.info` (which *does* exist as a separate site, containing a meta-redirect to `https://jms1.info/` without the `www.` in the hostname) ...

    ```
    Cwww.jms1.info:kbp.keybaseapi.com:3600
    '_keybase_pages.www.jms1.info:kbp=/keybase/team/jms1team.sites/www.jms1.info:3600
    ```

    ```
    www.jms1.info.                 3600  IN CNAME  kbp.keybaseapi.com
    _keybase_pages.www.jms1.info.  3600  IN TXT    "kbp=/keybase/team/jms1team.sites/www.jms1.info"
    ```

    * The record for `www.jms1.info.` is a CNAME record, pointing to `kbp.keybaseapi.com`. This makes the `www.jms1.info` name resolve to the same IP address(es) that `kbp.keybaseapi.com` points to, without having to worry about manually updating them if `kbp.keybaseapi.com` ever changes.

    * The TXT record for `_keybase_pages.jms1.info.` is what tells Keybase Sites where to find the site's content. Because it points to a team folder, the `kbpbot` user needs to have at least "reader" permissions in that team.

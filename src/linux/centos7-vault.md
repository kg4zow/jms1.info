# CentOS 7 - Fix yum repos

**2024-07-06**

I have a fair number of scripts which run inside of containers. I do this for several reasons, including:

* I can run things which require Linux, on my macOS workstations, using [colima](https://github.com/abiosoft/colima).

* I can run scripts or programs which have complicated dependencies, without having to mess with installing those dependencies on every machine where I want to run the program. Everything is already installed within the container.

Many of these use the `centos:7.9.2009` container (aka `centos:7`), because at the time I wrote them, I was using CentOS 7 on a day-to-day basis at work, both at work and personally. One of the reasons I do this at work is to build RPM packages *for* CentOS and RHEL systems, *on* my macOS machines.

CentOS 7 officially went end-of-life on 2024-06-30. At work they're paying for an extended-lifetime support contract with Red Hat, who provides us with access to a set of yum repos whose packages receive security and bug-fix updates for RHEL 7. These updated packages can only be used for RHEL 7 machines (not CentOS 7), and they can only be used for work-related machines for which the company pays a license. (It's not my money.)

We've spent the last few months replacing our CentOS 7 machines with RHEL 7 because of this. (And because somebody "higher up" heard a Red Hat employee say that [`convert2rhel`](https://www.redhat.com/en/blog/introduction-convert2rhel-now-officially-supported-convert-rhel-systems-rhel) leaves CentOS artifacts on the converted system, took that to mean it doesn't work, and ordered us not to use it, so we had to build all new VMs and migrate their programs and data by hand ... but that's a different discussion.)

### `vault.centos.org`

CentOS has a server called [`vault.centos.org`](https://vault.centos.org/) which contains copies of the CentOS yum repositories for retired CentOS versions, going back to CentOS 2.1.

When CentOS 7 went EOL, its packages were added to the vault as well, the `mirrorlist.centos.org` servers (which handled automatically redirecting `yum` clients to a working mirror) were powered off, and the hostname removed from DNS. And while the [`mirror.centos.org`](https://mirror.centos.org/) mirror servers are still *running*, they use different directory names *and* don't contain any RPMs.

This means that servers which are still using CentOS 7, as well as containers started from the `centos:7.9.2009` container image, need to be re-configured to use `vault.centos.org`.

> &#x26A0;&#xFE0F; **This should be a temporary measure.**
>
> The RPM packages in `vault.centos.org` will NEVER be updated, even for security fixes. This might be okay for containers which are never accessible from the outside world, however servers should be upgraded or migrated to a different OS which *does* receive security updates.

## Update repo files

The `sed` commands updates the original `/etc/yum.repos.d/Centos-*.repo` files to use the `vault.centos.org` servers instead.

```
sed -i -e '/^mirrorlist/d;/^#baseurl=/{s,^#,,;s,/mirror,/vault,;}' /etc/yum.repos.d/CentOS*.repo
```

I've started adding this command to scripts which run inside of containers built from the `centos:7.9.2009` image. And for custom container images which use `centos:7.9.2009` as the starting point for custom containers, I've updated their `Dockerfile`s like so:

```
FROM    centos:7.9.2009
RUN     sed -i -e '/^mirrorlist/d;/^#baseurl=/{s,^#,,;s,/mirror,/vault,;}' /etc/yum.repos.d/CentOS*.repo
RUN     yum -y update && yum -y install xxx yyy zzz && yum clean all
...
```

# Changelog

**2024-07-06** jms1

* wrote this page from an Obsidian note which had just the `sed` one-liner

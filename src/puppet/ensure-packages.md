# Puppet - `ensure_packages()`

**2022-02-24**

I've been using Puppet to manage systems at work for about nine years now. We use Puppet to install pretty much everything on the servers we sell to our customers, as well as managing our internal infrastructure systems.

Our servers have several scripts on them, written in Perl and Python. Most of these scripts require external libraries to run. For the most part, these libraries can be installed using OS packages. such as `.rpm` or `.deb` files, depending on the OS.

One problem I've been running into for years is, how to *manage* installing these packages along with the scripts which need them. Note that installing the packages is actually pretty simple, it's just a normal `package` declaration:

```
  package { 'perl-Digest-SHA' :
    ensure => present ,
  }
```

Puppet only allows each package to be declared *once*, across all of the classes which are used to build the machine's catalog. Each script needs its own set of libraries, and each machine may need a different collection of scripts. Ultimately I need to make sure that each machine has the right collection of libraries for the scripts which that machine uses.

# History

(Feel free to skip this section if you like.)

When I started, I just declared the library packages *with* the scripts. At the time all of the scripts were declared in the same class, so it was fairly simple - until we started needing to build a different type of server which used *some* of the scripts but not all of them (and in fact, needed to *not* contain some of the others for security reasons).

### Try #1: Libraries Class

My first "solution" was to move all of the library package declarations to a single `libraries` class, which is used on every type of machine we manage. The resulting machines *work*, however ...

* Any time a script is added, and it has a new dependency, that dependency ends up being installed on *every* machine we manage, whether that package is needed on the machine or not.

    Our production machines run in environments that I will only describe as "highly regulated". Whenever Puppet installs or updates software on a server, it shows up in that system's logs, and the facilities' IT security people ask questions. There have been a few times times when I've been given a list of every package installed on a machine and told to provide an explanation of why each package is needed. Trying to explain to a client that a package was installed on *their* servers, because *some other* client's servers needed it ... not the most pleasant conversation.

* Any time a script is added, or an existing script is updated and has a new list of required libraries, I have to look in *two* placess to update things - the class which installs the script, and the `libraries` class which installs *all* of the library packages.

* When a script is removed, I have to do one of two things:

    * Figure out which library packages the script was using, and then figure out if any *other* scripts needed that particular package, in order to tell if it's safe to delete that particular package declaration from the Puppet code.

        I tried to leave comments in the Puppet code in both classes, to help me figure this out later, but when other people are writing the scripts and don't *tell* you that an update added a dependency, because it *happened* to have been one which was already being installed by the `libraries` class, I never get to update the comments for that library package to show that the "xyz script" now also needs that particular package.

    * Leave the package declaration in the "libraries" class forever, even if nothing really needs it anymore. This is what I eventually ended up doing, however it has resulted in a lot of unnecessary packages on the servers. Luckily the packages are not huge, and the systems involved have enough storage so it isn't a problem.

As you can see, it's a lot of manual management that I've always thought, shouldn't be needed.

### Try #2: Manually check before declaring

Another thing I tried was having the Puppet code explicitly check whether the package had already been included in the catalog, before declaring it. The package declarations ended up looking like this:

```
  if ( ! defined( Package['perl-Digest-SHA'] ) ) {
    package { 'perl-Digest-SHA' :
      ensure => present ,
    }
  }
```

This works, and can be used to "declare if needed" each package, in the same class where the script itself is declared. However, converting to this scheme would involve adding these blocks for every package, for every script, across all of the classes, and then removing the `libraries` package. This is possible, but it would be tedious and time-consuming, and I'm the only person doing Puppet programming. Unless it's something that makes an improvement that our *clients* can see, I can't justify spending the time on doing it.

# The `ensure_packages()` function

Earlier today I asked about this (without so much detail) in the "Puppet Community" slack server, and some kind person pointed me to the `ensure_packages()` function in the [`puppetlabs/stdlib`](https://forge.puppet.com/modules/puppetlabs/stdlib) module. I vaguely remember being *aware of* this function several years ago, but [the description at the time](https://github.com/puppetlabs/puppetlabs-stdlib/tree/4.9.0?tab=readme-ov-file#ensure_packages) didn't really explain much, and I was looking for something else, so it didn't really "click" - and as a result, I didn't realize how useful it could be. (The [current description](https://forge.puppet.com/modules/puppetlabs/stdlib/8.1.0/reference#ensure_packages) looks to be identical to the one I saw years ago, i.e. "still not great", which is part of why I'm wrting this page.)

> &#x26A0;&#xFE0F; **Removed**
>
> It looks like the `ensure_packages()` function has been removed from the `puppetlabs/stdlib` module, some time after version 8.1.0.

The function is actually a wrapper around another function called `ensure_resources()`, which does more or less what the "Manually check before declaring" code shown above does - it checks the catalog-in-process and, if the given resource hasn't already been declared, it adds it to the catalog, just as if it had been declared in the Puppet code.

It's probably easier to see with an example, so ... let's assume that we're going to install two scripts, "`/usr/local/bin/abc`" and "`/usr/local/bin/xyz`". They're written in Perl. One contains the following "`use`" lines at the top, which "link in" the libraries when the script starts ...

```perl
# from /usr/local/bin/abc

use Digest::SHA qw ( hmac_sha256_hex ) ;
use IO::Socket::SSL ;
use JSON ;
use LWP ;
use Sys::Hostname ;
```

The other script contains *these* "`use`" lines:

```perl
# from /usr/local/bin/xyz

use IO::Socket::SSL ;
use JSON ;
use LWP ;
use Sys::Hostname ;
```

In order for these script to run, the libraries need to be installed. We don't have to worry about `Sys::Hostname` since it's a "core" library, installed as part of the `perl` package, however the other libraries *do* need to be installed.

Ideally, we'd like to be able to have something in the same Puppet class which installs the script itself, and we'd like to be able to list all of the packages each script needs, even if multiple scripts happen to need the same packages.

We *could* do something like this, i.e. "Manually check before declaring" ...

```
  ########################################
  # Install the abc script and its dependencies

  $pkg_abc = [ 'perl-Digest-SHA' , 'perl-IO-Socket-SSL' , 'perl-JSON' , 'perl-libwww-perl' ]

  $pkg_abc.each |$x| {
    if ( ! defined( Package[$x] ) ) {
      package { $x :
        ensure => present ,
      }
    }
  }

  file { '/usr/local/bin/abc' :
    ensure => file ,
    owner  => 'root' ,
    mode   => '0744' ,
    source => 'puppet:///modules/${module_name}/usr/local/bin/abc' ,
  }

  ########################################
  # Install the xyz script and its dependencies

  $pkg_xyz = [ 'perl-IO-Socket-SSL' , 'perl-JSON' , 'perl-libwww-perl' ]

  $pkg_xyz.each |$x| {
    if ( ! defined( Package[$x] ) ) {
      package { $x :
        ensure => present ,
      }
    }
  }

  file { '/usr/local/bin/xyz' :
    ensure => file ,
    owner  => 'root' ,
    mode   => '0744' ,
    source => 'puppet:///modules/${module_name}/usr/local/bin/xyz' ,
  }
```

While this *works*, having those `each` constructs above every single script gets kind of tedious, and if you're not careful it makes it *really* easy to make mistakes (ask me how I know).

Instead, we can do this ...

```
  ########################################
  # Install the abc script and its dependencies

  ensure_packages( 'perl-Digest-SHA' )
  ensure_packages( 'perl-IO-Socket-SSL' )
  ensure_packages( 'perl-JSON' )
  ensure_packages( 'perl-libwww-perl' )

  file { '/usr/local/bin/abc' :
    ensure => file ,
    owner  => 'root' ,
    mode   => '0744' ,
    source => 'puppet:///modules/${module_name}/usr/local/bin/abc' ,
  }

  ########################################
  # Install the xyz script and its dependencies

  ensure_packages( 'perl-IO-Socket-SSL' )
  ensure_packages( 'perl-JSON' )
  ensure_packages( 'perl-libwww-perl' )

  file { '/usr/local/bin/xyz' :
    ensure => file ,
    owner  => 'root' ,
    mode   => '0744' ,
    source => 'puppet:///modules/${module_name}/usr/local/bin/xyz' ,
  }
```

This is easier to see, it's easier to understand, and it's easier for a junior person (or a "programmer but not a *Puppet* programmer") to maintain without having to constantly worry about typos.

# Changelog

**2024-06-19** jms1

- moved page to new `jms1.info` site, updated header
- added note about ensure_packages() no longer existing

**2022-02-24** jms1

- Initial version

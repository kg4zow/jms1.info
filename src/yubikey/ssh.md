# Using a Yubikey for SSH keys

**2024-06-30**

This page will cover how I'm storing my SSH (and PGP) keys on a Yubikey. It will combine information from other notes that I've written over the years.

It will also contain links to other pages on this site, where parts of this process are already explained.

Finally, note that I haven't "finished" this page yet. It has enough information for me to know what's going on, but there are parts that I just haven't had time to "flesh out" yet. I don't *plan* to leave it this way forever, but I at least wanted to get this page *mostly done* and on the site, because at least two different people are waiting for it.

# Background

In order to understand how this works, you'll need to have a basic understanding of a few other things first. If you already have a basic understanding of these things, or if you're impatient and don't *want* to have to read through them, feel free to skip over them.

> &#x2139;&#xFE0F; These explanations are *deliberately* leaving out a lot of detail. I promise, I'm not trying to make this page any longer than it needs to be.

### Public-Key Encryption

Traditional encryption systems (or "cryptosystems") use the same key to encrypt and decrypt each message. If you encrypt a message using one key, the recipient needs the *same* key to decrypt it - and anybody else who manages to get a copy of that key will also be able to decrypt it. These are known as "shared-key" or "symmetric-key" systems, because the same key is used for both operations.

**In a public-key encryption system, each party has a *pair* of keys.** These keys are used with algorithms where a message *encrypted* using one of those keys, can only be *decrypted* using the other key in the same pair. Each user generates a key pair, shares one key with the world (known as a "public key"), and keeps the other key to themself (known as a "private key" or "secret key").

Public-key algorithms use a LOT more resources (CPU, RAM, and time) than symmetric-key algorithms. Because of this, most cryptosystems (including PGP and SSH) will generate and use a random key (or "ephemeral" key) with a symmetric-key algorithm to encrypt the message itself, and then use a public-key algorithm to encrypt that ephemeral key. The recipient uses their secret key to decrypt the portion containing the ephemeral key, then uses the ephemeral key to decrypt the actual message. This way the "more expensive" operations are used at the beginning, but the "less expensive" operations are used for the bulk of the message. This is especially useful for larger messages.

### PGP and GnuPG

**PGP**, or "[Pretty Good Privacy](https://en.wikipedia.org/wiki/Pretty_Good_Privacy)", is an encryption system written by [Phil Zimmermann](https://philzimmermann.com/EN/background/index.html) in the early 1990's. The source code was available online, although it didn't *quite* have what we know today as an "open source" license.

At the time he wrote it, the US had restrictions on exporting cryptographic software, and he was subjected to a three-year criminal investigation. (Those export restrictions were later removed when [Daniel J. Bernstein](https://en.wikipedia.org/wiki/Daniel_J._Bernstein) filed, *and won*, a [series of lawsuits against the United States](https://en.wikipedia.org/wiki/Bernstein_v._United_States).)

Zimmermann later started a company called PGP, Inc. to try and commercialize the `pgp` software. It had some success, and was later sold to Network Associates, who then sold it to Symantec, who still owns the name and the "intellectual property" but doesn't appear to be doing anything with it.

PGP's message format was standardized as the "OpenPGP Message Format" in [RFC 4880](https://www.rfc-editor.org/rfc/rfc4880). Several programs implement this standard.

**[GnuPG](https://www.gnupg.org/)** is the most common implementation of PGP. This is an open-source software package which is available for pretty much every operating system out there, including macOS and Linux. (There is a related project called [gpg4win](https://www.gpg4win.org/) for ms-windows.)

### PGP Keys and Subkeys

When a user generates a PGP key, they are actually generating a *set* of key pairs. Each key pair has flags describing which operations that key is meant to be used for. One of the keys is designated as the "primary" key, and most "PGP keys" have one or more "subkeys". Each individual key or subkey is flagged to be used for specific operations.

The default configuration of a "PGP key" has ...

* A primary key, flagged with `[C]` for certifying (signing other PGP keys), and usually `[S]` for signing messages. You normally see these combined as `[SC]`.

* A subkey, flagged with `[E]` for encrypting messages.

It is possible, and in some cases can be useful, to create a primary key with *only* the `[C]` flag. This can be useful if you need a key that will never be used to sign messages, and should only be used by others to encrypt message *to* you.

There is a fourth capability, `[A]` for authenticating. Most PGP users aren't even aware that it exists, but we're going to use it below.

### SSH Key-based Authentication

For SSH, each user has a key pair. These are commonly stored in files with matched filenames, such as `id_rsa` for a secret key, and `id_rsa.pub` for the corresponding public key. However, if you're able to store the secret key somewhere else (like in a Yubikey), there's no need for the secret key to exist on the computer at all - which makes it very hard for an attacker to steal the secret key. (They can't steal what isn't there in the first place.)

SSH key-based authentication works like this:

* On each server that a user might need to log into, they store copies of their SSH *public* key(s) in their `$HOME/.ssh/authorized_keys` file.

* When the user wants to log into the server, the server sends the client a challenge containing a block of random data (also known as a "nonce").

* The client answers the challenge by "signing" the nonce (encrypting it using the SSH secret key) and sending the result back to the server.

* The server tries to decrypt the client's response using the public keys in the user's `authorized_keys` file. If one of them successfully decrypts the response, authentication succeeds and the incoming connection is logged in as that user.

* Otherwise, authentication fails and the client is not allowed to log in.

Most systems use an "SSH agent" to perform the nonce-signing. This is a process which holds secret keys in memory, and offers an interface which allows clients to ask for nonces to be signed. This interface is implemented using a "unix socket", which is only accessible from processes on the same machine.

[OpenSSH](https://openssh.com/) is the standard SSH implementation for macOS and Linux. It uses a program called [`ssh-agent`](https://man.openbsd.org/ssh-agent) to perform the agent function, however *any* program which offers the same interface can do the same thing.

GnuPG comes with a program called `gpg-agent` which serves a similar function for PGP secret keys, and can be configured to "speak" the SSH agent protocol. Part of the solution we'll be building below will involve configuring your SSH clients to talk to a `pgp-agent` process.

### Yubikey

A [Yubikey](https://yubico.com/) is a small USB device that fits on your keychain. It can be used as a "second factor" for authentication, and is available with USB-A, USB-C, or "Lightning" (used on many Apple devices) connectors, as well as NFC (short-range wireless) connectivity.

Yubikey devices are miniature computers. They run their own "apps", which are loaded by Yubico during manufacturing, and which for security reasons, cannot be upgraded, deleted, or modified. Each Yubikey has a "secure element" which stores encryption keys in a way that they cannot be extracted, even by an attacker who physically disassembles the Yubikey and attaches wires directly to the right chips on the board.

The Yubikey Neo, 4, and 5 series have an OpenPGP app. This app implements the [OpenPGP Card](https://openpgpcard.cloudbook.wiki/) standard, which allows it to work with GnuPG's smart card support. The OpenPGP app can store three secret keys in the Yubikey's secure element, and can use those keys to perform OpenPGP functions which require them (signing and decrypting messages).

The app does not have a way to export the secret keys, so once a secret key is loaded into (or generated on) a Yubikey, it cannot be extracted.

### Tails

[Tails](https://tails.net/) is a Linux system designed around privacy.

* It boots from a USB memory stick and runs from a RAM disk. Any data saved to the RAM disk is deleted when Tails shuts down.

* Almost all network traffic is routed through [Tor](https://tor.eff.org/).

* The software we're going to need, including GnuPG, is already installed.

Tails can set up an encrypted [Persistent Storage](https://tails.net/doc/persistent_storage/index.en.html) partition on the USB stick, where files can be saved permanently. We will be using this functionality to hold the only copy of your secret keys.

## Recap

This is what we're actually going to do:

* Under Tails with Persistent Storage
    * Generate a new PGP key (or import an existing key).
    * Add a subkey with the authentication flag.
    * Generate the corresponding SSH public key for this new subkey.
    * Load that subkey into a Yubikey.

* On each machine you want to be able to SSH into (i.e. the servers you need to SSH into)
    * Add the generated SSH public key, to your `$HOME/.ssh/authorized_keys` file.

* On each machine where you want this to work (i.e. workstations)
    * Configure `pgp-agent` to support the SSH agent protocol.
    * Make your SSH clients talk to `pgp-agent` *as* the SSH agent.

If anything on this list doesn't make sense to you at all, please go back up and re-read the information above. If it *still* doesn't make any sense, there's a chance that I'm forgetting something. [Please let me know](../introduction.html#contact) if this is the case, so I can update this page.

# Boot into Tails with Persistent Storage

Most of the procedures below will take place in a running Tails system.

Rather than try and explain Tails here, I'm going to point you to the documentation on their web site.

* [Installing Tails](https://tails.net/install/index.en.html)
    * You will need a USB stick which is **16 GB or larger**, as well as a computer which is capable of booting from a USB stick. (The USB stick on my keychain is 128 GB, I store more than just PGP keys on it.)
* [About Persistent Storage](https://tails.net/doc/persistent_storage/index.en.html)
* [Create a Persistent Storage Partition](https://tails.net/doc/persistent_storage/create/index.en.html)
* [Configure the Persistent Storage](https://tails.net/doc/persistent_storage/configure/index.en.html) ... the following categories should be enabled:
    * Persistent Folder
    * GnuPG
    * Additional Software
    * Dotfiles

> Make sure you boot into Tails, with Persistent Storage unlocked, and the listed categories enabled, BEFORE you continue.

These directions will involve using the command line. In Tails, you can access the command line using:

* Applications &#x2192; Utilities &#x2192; Terminal

## Create or Import a PGP Key

The goal of this section is to have a PGP key pair, with an authentication subkey, in the GnuPG keyring in your Tails Persistent Storage. This will include both the public and secret keys.

The idea is that this Tails stick, with Persistent Storage unlocked, will be the *only* place you'll be able to use the PGP key without a Yubikey.

### Create a PGP Key

If you don't already have a PGP key, you'll need to create one.

* `gpg --gen-key`
* `gpg --quick-generate-key 'Name <email>' rsa4096 default 20250101T000000`

Because some older PGP software may not be able to handle `ed25519` keys, I use `rsa4096` for my primary key. You *can* do this and still have an `ed25519` authentication subkey for SSH (and actually, the PGP key I use for `$DAYJOB` has two authentication subkeys - one `rsa4096` and one `ed25519`.)

### Import a PGP Key

If you already have a PGP key, you'll need to import **both the public and secret keys** into the GnuPG keyring within Tails.

#### Export from your current PGP software

The mechanics of exporting keys will depend on your current PGP software. If you're using GnuPG, you'll want to create an encrypted USB stick (using LUKS or [VeraCrypt](https://www.veracrypt.fr/en/Home.html), so Tails will be able to mount it) and store the exported files there. DO NOT store your exported secret key where anybody else will be able to access it.

The process will look something like this:

```
cd /mnt/encrypted
gpg -a --export KEYID > KEYID.pub
gpg -a --export-secret-keys KEYID > KEYID.sec
```

#### Import into GnuPG

This process will look something like this:

```
gpg --import KEYID.pub
gpg --import KEYID.sec
```

You will probably want to set the key's "trust" to "ultimate" as well.

```
$ gpg --edit-key KEYID
...
gpg> trust
...
Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust full
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5
Do you really want to set this key to ultimate trust? (y/N) y
...
Please note that the shown key validity is not necessarily correct
until you restart the program.

gpg> q
```

> &#x26A0;&#xFE0F; Do not use the "ultimate" trust level for any keys other than your own.



## Add an Authentication Subkey

&#x21D2; [Authentication Subkeys](../pgp/auth-subkey.md)

* couldn't find a way to import existing SSH secret key *as* an authentication subkey
    * "monkeysphere" sounds like it *might* be able to do it, but it looks like it's been abandoned (web site appears to have been taken over by a domain squatter)

## Export SSH public key

Use the Key ID of the authentication subkey for this. If your PGP key only has one authentication subkey, you can also use the Key ID of the primary key for this. The software will find and use the authentication subkey automatically.

In this example, I'm using my primary Key ID.

```
$ gpg --export-ssh-key E3F7F5F76640299C5507FBAA49B9FD3BB4422EBB > id_rsa_yubikey.pub
$ cat id_rsa_yubikey.pub
ssh-rsa AAAAB3Nz...AkjIPw== openpgp:0xF8D09EB7
```

Edit the comment as needed. I normally use my name, email, the date the subkey was generated, and which Yubikey(s) will contain that key. This way when they appear in a file with other keys, it's easy to recognize which key is which.

```
$ cat id_rsa_yubikey.pub
ssh-rsa AAAAB3Nz...AkjIPw== John Simpson <jms1@jms1.net> 2019-03-21 Yubikey Blue
```

I have different [coloured stickers](https://www.yubico.com/product/yubistyle-covers-usb-a-c-nfc/) on my Yubikeys, so I can tell which Yubikeys have which PGP/SSH keys on them. My personal PGP/SSH keys are on Yubikeys with the plain blue stickers.

Send the key to an "outside" system.

## Load Keys into the Yubikey

&#x21D2; [Load Keys into a Yubikey]( load-pgp-key.html)

# Add SSH key to `authorized_keys` files

* standard process, just like adding any other key
* can be done with `ssh-copy-id`

# Set up Workstation

&#x21D2; [Make SSH use gpg-agent](../pgp/ssh-pgp-agent.html)

* manual process
* Tails?

# Changelog

**2024-07-07** jms1

* published what I have so far to `jms1.info`
* included a note explaining that I'll add more human-readable info when I have time

**2024-06-30** jms1

* started this page, pulling in info from several other pages

# Authentication Subkeys

**2019-02-01**

This document explains what authentication keys are, and how to add one to an existing GPG key pair which doesn't already have one.

# Background

### Subkeys and usage flags

A PGP key consists of a primary key, and *usually* one or more subkeys. Each key has one or more flags to tell what that key's intended uses are. The possible flags are:

* **"`E`" = Encryption.** The public key is shared with the world, so that other people can send you secret messages. The secret key is used to decrypt messages that you receive from others.

* **"`S`" = Signing.** The secret key is used to generate "digital signatures", which can be used to prove that you created a given message. The public key is shared with the world, so they can *verify* your signatures.

* **"`A`" = Authentication.** This key pair is used to prove your identity when accessing certain types of services, such as SSH. This document talks about creating and using a subkey with this flag.

* **"`C`" = Certification.** This key pair is used for two purposes:

    * Signing other peoples' PGP keys. This is how the "web of trust" works - if somebody "trusts" your key, and you've signed some other key, they would "trust" that other key as well, based on your signature.

    * Issuing new subkeys. All subkeys "under" a given primary key, are signed (certified) by that primary key.

    Only a PGP key's primary key can be flagged for Certification.

The "`gpg --list-keys`" command will show you which flags are on each of the keys.

```
$ gpg --list-keys jms1
...
pub   rsa4096/0x6B2EDC90B5C6DC30 2017-05-27 [SC]
      6353320118E1DEA2F38EAE806B2EDC90B5C6DC30
uid                   [ultimate] John M. Simpson <jms1@voalte.com>
uid                   [ultimate] John M. Simpson <jms1@jms1.net>
sub   rsa4096/0x297E5961AB566594 2017-05-27 [E]
...
```

In this case, the primary key (fingerprint ending with `DC30`) is flagged with "`SC`" (signing and certifying), and the subkey (fingerprint ending with `6594`) is flagged with "`E`" (encryption).

Having a separate encryption key like this is a good idea, because if you suspect that the encryption key has been compromised, you can issue a new encryption key without having to create an entire new key pair and get your friends "trust" the new one.

An even more secure way to handle this is to create a separate signing subkey, so that the primary key is *only* used for certification. If you need to use your "secret key" from more than one machine, you can copy the secret parts of *just* the subkeys, without copying the secret part of the primary key, and still be able to do most day-to-day PGP tasks, without worrying about your primary key being compromised, even if somebody manges to totally take over the computer.

As an example, this is the key I currently use on a regular basis. The secret halves of the three subkeys are stored in the YubiKey I keep on my keyring, while the secret half of the primary key is only stored on an encrypted USB stick that I only access using [Tails](https://tails.boum.org/) on an air-gapped laptop.

```
$ gpg --list-keys jms1
...
pub   rsa4096 2019-03-21 [SC] [expires: 2022-01-01]
      E3F7F5F76640299C5507FBAA49B9FD3BB4422EBB
uid           [ unknown] John Simpson <jms1@jms1.net>
uid           [ unknown] John Simpson <kg4zow@mac.com>
uid           [ unknown] John Simpson <kg4zow@kg4zow.us>
sub   rsa4096 2019-03-21 [E] [expires: 2022-01-01]
sub   rsa4096 2019-03-21 [S] [expires: 2022-01-01]
sub   rsa4096 2019-03-21 [A] [expires: 2022-01-01]
...
```

### Yubikey

A YubiKey's OpenPGP app has three key storage locations: one for encryption, one for signing, and one for authentication. **The only things stored on a Yubikey are the numeric secret key values.** It doesn't use, and isn't even aware of, any names, expiration dates, usage flags, or whether a key is a primary or secondary.

When I generate a PGP key that I plan to use on a YubiKey, I specifically generate it with subkeys for encryption, signing, and authentication, all separate from the primary key, and I store the three subkeys on the YubiKey. This allows me to use the YubiKey to do everything *except* certification operations, without needing the primary secret key at all.

#### TODO

* write another page explaining how to generate a new key in this manner

# Procedure

## Identify the key

In order to modify a key, you need to give the `gpg` command enough information to uniquely identify the key. If you're like me and have multiple keys with the same "User ID" (name and email), you will need to use the key's fingerprint to identify which key you want to update.

Because of this, I've more or less trained myself to always use fingerprints to identify keys.

Find the fingerprint of the primary key that you want to add the authentication subkey to.

```
$ gpg --list-keys jms1
...
pub   rsa4096/0x6B2EDC90B5C6DC30 2017-05-27 [SC]
      6353320118E1DEA2F38EAE806B2EDC90B5C6DC30
uid                   [ultimate] John M. Simpson <jms1@voalte.com>
uid                   [ultimate] John M. Simpson <jms1@jms1.net>
sub   rsa4096/0x297E5961AB566594 2017-05-27 [E]
...
```

*This command actually returned four different keys, I'm only showing the one I'm working with below.*

For this key, any of the following values can be used as a Key ID. Fingerprints can be specified either with or without "`0x`" at the beginning:

* `B5C6DC30` (low 32 bits)
* `6B2EDC90B5C6DC30` (low 64 bits)
* `6353320118E1DEA2F38EAE806B2EDC90B5C6DC30` (full 160 bits)
* "`jms1`", "`jms1@jms1.net`", "`john`", or "`simpson`", if your keyring only contains one key contains that string in the User ID.

#### Notes

* The idea is to find something which identifies *exactly one* key.

* The fingerprint values shown above are the same, the shorter values are just the "low bits" from the full fingerprint. I normally use the full 160-bit fingerprint, since there are ways for a determined attacker to create a key with the same fingerprint as an existing key that they wish to impersonate.

## Generate the authentication subkey

There are two ways to generate subkeys: the quick way, and the normal way. I'm going to show the normal way first. If you're already comfortable with `gpg`, feel free to skip ahead.

### Primary secret key

**This process MUST be done on a computer where the secret half of the primary key is available.** In my case, this means booting up Tails on the air-gapped laptop, mounting the encrypted USB stick, and importing the backed-up copies of the secret keys I need to work on.

```
$ gpg --import-secret-key /media/keystore/6B2EDC90B5C6DC30.sec.asc
$ gpg --list-secret-keys jms1
sec   rsa4096/0x6B2EDC90B5C6DC30 2017-05-27 [SC]
      6353320118E1DEA2F38EAE806B2EDC90B5C6DC30
uid                   [ultimate] John M. Simpson <jms1@voalte.com>
uid                   [ultimate] John M. Simpson <jms1@jms1.net>
ssb   rsa4096/0x297E5961AB566594 2017-05-27 [E]
```

The prefix on the primary key will be one of the following:

* **`sec`** means that the secret key is present in the keyring file(s).

* **`sec>`** means that the secret key is present on a smart card (or YubiKey).

* **`sec#`** means that the secret key is not available.

You will also see the same kinds of suffixes on the subkeys, i.e. "`ssb`", "`ssb>`", or "`ssb#`".

**Make sure the secret key is available.** You should see "`sec`" or "`sec>`".

### The normal way

This example walks through how to create a subkey with the "`A`" flag.

Note that many of the commands and their output look almost identical, so be careful when you follow along with this process.

```
$ gpg --expert --edit-key 6353320118E1DEA2F38EAE806B2EDC90B5C6DC30
gpg (GnuPG/MacGPG2) 2.2.0; Copyright (C) 2017 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

sec  rsa4096/0x6B2EDC90B5C6DC30
     created: 2017-05-27  expires: never       usage: SC
     trust: ultimate      validity: ultimate
ssb  rsa4096/0x297E5961AB566594
     created: 2017-05-27  expires: never       usage: E
[ultimate] (1). John M. Simpson <jms1@voalte.com>
[ultimate] (2)  John M. Simpson <jms1@jms1.net>

```

It starts off by showing you the current state of the key you're working on. The primary key is marked for both signing and certification, and the one subkey is flagged for encryption.

Start by adding a new RSA subkey, using the option allowing you to set your own capabilities.

```
gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
Your selection? 8
```

You will be asked which flags the new key should have. The "`Current allowed actions:`" line will show you which flags will be enabled, and entering `S`, `E`, or `A` will toggle that flag.

Turn the flags on and off as needed so that only "Authenticate" is selected, then select "Finished".

```
Possible actions for a RSA key: Sign Encrypt Authenticate
Current allowed actions: Sign Encrypt

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? s

Possible actions for a RSA key: Sign Encrypt Authenticate
Current allowed actions: Encrypt

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? e

Possible actions for a RSA key: Sign Encrypt Authenticate
Current allowed actions:

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? a

Possible actions for a RSA key: Sign Encrypt Authenticate
Current allowed actions: Authenticate

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? q
```

Next you will need to select the key length. The `gpg` software on your computer itself is able to work with keys with a range of sizes, however the YubiKey is only able to work with keys whose length is *exactly* 1024, 2048, or 4096, so I normally choose 4096.

```
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096
Requested keysize is 4096 bits
```

Next you will be asked how long the key should be valid. For this example I chose "key does not expire", however I normally set expiration dates on all of my keys, so that if I later need to revoke a key and not everybody gets the revocation certificate, it will "stop working" after a reasonable length of time. (I normally renew or re-generate new keys every year.)

```
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 0
Key does not expire at all
Is this correct? (y/N) y
```

At this point, `gpg` has the information it needs to create the new key. It will ask for confirmation one last time, and then gen

```
Really create? (y/N) y
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.

sec  rsa4096/0x6B2EDC90B5C6DC30
     created: 2017-05-27  expires: never       usage: SC
     trust: ultimate      validity: ultimate
ssb  rsa4096/0x297E5961AB566594
     created: 2017-05-27  expires: never       usage: E
ssb  rsa4096/0xBA6C2A169C6C0F60
     created: 2017-11-10  expires: never       usage: A
[ultimate] (1). John M. Simpson <jms1@voalte.com>
[ultimate] (2)  John M. Simpson <jms1@jms1.net>
```

As you can see, there is now a second subkey, with the "`A`" flag.

The last remaining step is to save the new key out to disk.

```
gpg> save
```

### The quick way

This one-line command does everything described above.

```
$ gpg --quick-add-key 6353320118E1DEA2F38EAE806B2EDC90B5C6DC30 rsa4096 auth 2021-12-31
```

This command will generate a new 4096-bit RSA key and add it to that existing key, with the "`A`" flag, and a signature expiring on 2021-12-31. You will be prompted for the passphrase of the primary key to which you are adding the subkey.

#### Notes

* Subkeys have their own expiration dates, which can be different from the expiration date of the primary key to which they are attached.

* The "normal" process only allows you to specify an expiration date as "now plus X", while the "quick" process also allows you to specify an exact date/time for the key to expire.

## Convert the new key to SSH public key format

In order to use the new key as an SSH key, you need to export the public half of this new key, convert it into the format that SSH needs, and store it in the `$HOME/.ssh/authorized_keys` file of each machine where you want to be able to SSH in using the key.

Luckily, the `gpg --export-ssh-key` option does this exact thing.

```
$ gpg --export-ssh-key 0xBA6C2A169C6C0F60 > sshkey.pub
$ cat sshkey.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1hMmBJQ+PPYkuFuWxHiv4eV1BDXW4ZxvXkCIeZeKf
LlOc7V2MOMggV4OzHIApEvO4XzSbyuFjiTkrvOHdSrb+J1JhFnpCeYawxRz5UQiZdcN/HJNlIZK6AMvO
hiUuuUKULMhIywL3UQwZknDvUwYrWwjdnjwOZqlyEFu1jUnfVvhGgI4qAcXqd2HBx6juXen6Z2kuP7T5
4N/ZGyB5dEq07iJmXpyQ6cUJdHOY156MG5nb8J2KdY/xn+oWSRyAunDMCNtL7RtjDaaI/4u+UtG5rzGZ
UO/2TeqIubWLDyCgqF1rEhIDqMFl2XkXLoa7fMNNc+njtrwtq5yHy8nzL1NJ0PzW0wTW4h9IICVFKucZ
Yw+2jnBnT+PP7SvNe2uEYxvozb1sJ5A5MwOs7r13X50SWit5n3/Hdg3GPC/GkHWu4plkH+0wRjZLMbOQ
r4opFD/aUZdjpPVodBImfgKZwoVy4DdzZRNJRkOmR/i2iER8L6XOKB3Y7xLHlnTQj48uxaS0mxuagjDu
SrYWY2zOHsjSP78jU2i9cV1yRNa3Jz0Y4sVD5NX+qnQ6yxNOkyBA8IVfig/SnHvfStptkMdsBT4cDGYC
/me2w+OIqFvM5pRhDR1ULW5Mqef0TlALv+clnxDqhdszU7/j4F8yFeaoSD4bz7s/Rfxu5o9toFRmxejr
bw== openpgp:0x9C6C0F60
```

Note that this output is one big huge long line of text, I've just added line-wrapping so it looks okay in a normal web browser.

This SSH public key should be added to `$HOME/.ssh/authorized_keys` on each server where you want to be able to log in using the key, just like you would do with any other SSH public key.

Notes:

* The "`gpg --export-ssh-key`" command needs the same kind of unique identifier that the "`gpg`" commands above needed, i.e. a unique portion of a User ID or a segment of the key's fingerprint.

* In the "`gpg --export-ssh-key`" command, you can use either the main key ID or the authentication subkey ID, they will both produce the same output. The only time you would need to explicitly list the new authentication subkey ID is if your key pair has multiple subkeys with the "`A`" flag for some reason.

* Feel free to change the comment (the "`openpgp:0x9C6C0F60`" in the example above). I normally change it to something like "`jms1@jms1.net 2017-11-10`", which tells people later on (usually myself) whose key it is, and when the key was generated.

    However, because the comments *can* be changed, if you ever find yourself in the position of investigating an unknown SSH public key, you should not *trust* any comments which may be attached to the key, and should *only* rely on the key itself (that long string starting with "`AAAA`").


# Changelog

**2024-06-19** jms1

- moved page to new `jms1.info` site, updated header

**2020-12-22** jms1

- Changed the title to "Authentication Subkeys"
- Updated much of the "Background" section at the top.

**2020-12-20** jms1

- Moved to `jms1.info`.
- Minor formatting changes.
- Added the "Quick" section with the "`gpg --quick-add-key`" command.
- Wrote/updated descriptions for each step in the "Detailed" section.

**2019-02-01** jms1

- Initial content

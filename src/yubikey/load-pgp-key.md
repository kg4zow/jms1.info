# Load PGP keys into a YubiKey

**2017-12-13**

This document covers how to load PGP keys into a YubiKey.

# Background

The YubiKey is actually a tiny computer, powered by the USB port (or via NFC). It contains several tiny "apps" which provide the functionality of the YubiKey. In this case, we're going to be talking about the OpenPGP app.

Most smartcards, including the Yubikey, require some kind of authentication before they will agree to *do* anything. When you first plug the YubiKey into a USB slot, the OpenPGP app will be in a "locked" state, and the user needs to enter a PIN number to unlock the YubiKey before the app can be used.

The YubiKey has three different codes which can be entered, which allow different types of operations to be performed.

* The **Personal Identification Number**, or "PIN", is used to allow operations which involve *using* the secrets stored within the YubiKey. This includes decrypting data, creating digital signatures, and (with the right kind of key) performing SSH authentication.

    If the wrong PIN is entered three times, the YubiKey will "lock" itself and not allow itself to be unlocked at all, even if the correct PIN is entered.

* The **Personal Unblocking Key**, or "PUK", is used to "unlock" the YubiKey after the wrong PIN has been entered three times.

    If the wrong PUK is entered too many times, the PUK function will also be locked.

* The **Admin PIN** is the "master key" for the OpenPGP app. It is used to load new secret keys, set or change PINs, and "unlock" the OpenPGP app after the wrong PIN (or PUK) has been entered too many times.

    I *think* the Admin PIN will also unlock normal key-use functions like the regular PIN does. However, you shouldn't use the Admin PIN on an everyday basis like this, for a few reasons:

    * If somebody happens to see you entering the PIN, and then "borrows" the YubiKey (with or without your knowledge), they would be able to change any/all of the PINs and/or load new keys without your knowledge.

    * If you forget the Admin PIN and lock the card, you won't *have* a way to unlock it, other than totally resetting it and loading new keys.

    **If the Admin PIN is entered incorrectly three times, the OpenPGP app will permanently lock itself.** The only way to recover from this is to totally reset the OpenPGP app, which deletes any secret keys which were prevously stored in the YubiKey.

Note that there *is* no way to download the secret keys from the YubiKey, even if you have all three PIN codes.

### PIN Requirements

PIN codes are generally a string of digits, however...

* **YubiKeys do not require that PINs can only be digits.**

    However, most *smartcards* require PINs to be digits, because they may need to be used with a card reader with an integrated PIN pad, and entering letters or other characters using a ten-key keypad can be a bit of a pain. And because of this, some computers' PGPCard implementations may *assume* that only digits are allowed, and only allow digits to be entered.

    Unless you are 100% sure that every system where you will ever use the YubiKey will support non-digits in the PIN codes, I recommend that you stick with digits.

* The YubiKey OpenPGP app has a lower limit of 6 characters. This is different from the smartcards embedded in most credit/debit cards, which only require 4 characters (and which may not allow *more* than 4 characters).

* The YubiKey OpenPGP app has an uppper limit of 127 characters. However, some computers may limit how many characters the user can enter, which means that if your PIN is ten digits but the computer only allows you to enter eight, you won't be able to use it at all.

My own PINs have more than eight characters, and I haven't had any problems using them with macOS, Linux, or one time with Windows (it was a work thing, and I have changed the PIN since this happened - I don't know if the corporate IT overlords were recording keystrokes at the time or not.)

### Default PIN codes

When a Yubikey arrives from the factory, or if its OpenPGP app has been reset, the default PIN codes are:

* PIN: **`123456`**
* PUK: (none, which means that the Admin PIN must be used to unlock the PIN)
* Admin PIN: **`12345678`**

# Set Yubikey OpenPGP PINs

If you have not already done so, you should set your own PIN and Admin PIN codes.

While you're setting the PINs, you may also want to set the cardholder name, language preference, public key URL, and login data. **These are all optional**, however I normally do this with my YubiKeys, so you will see these steps below.

```
$ gpg --card-edit

Reader ...........: Yubico Yubikey 4 OTP U2F CCID
Application ID ...: D2760001240102010006069404470000
Version ..........: 2.1
Manufacturer .....: Yubico
Serial number ....: 06940447
Name of cardholder: [not set]
Language prefs ...: [not set]
Sex ..............: unspecified
URL of public key : [not set]
Login data .......: [not set]
Signature PIN ....: not forced
Key attributes ...: rsa4096 rsa4096 rsa4096
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 0 3
Signature counter : 0
Signature key ....: [none]
Encryption key....: [none]
Authentication key: [none]
General key info..: [none]

gpg/card> admin
Admin commands are allowed

gpg/card> passwd
gpg: OpenPGP card no. D2760001240102010006069404470000 detected

1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? 3
```

At this point your workstation will ask for the following, usually as separate prompts:

* The current Admin PIN (it will probably just say "the Admin PIN"). Again, the default for a new (or newly reset) YubiKey is "`12345678`".
* The new Admin PIN
* The new Admin PIN again, to verify that you typed it correctly

```
PIN changed.
```

Next, set the PIN you'll use on a regular basis in order to generate signatures, decrypt messages, or perform SSH authentication.

```
1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? 1
```

* Enter the current PIN. (Again, the default is "`123456`".)
* Enter the new PIN.
* Enter the new PIN again.

Note that if the current PIN was wrong, this command will fail and you will receive a "`Error changing the PIN: Bad PIN`" error.

```
PIN changed.
```

Once the PIN is set, if you *want* to set a separate PUK you can use the "unblock PIN" setting. Personally I don't have one, but if I were managing YubiKeys for a company and might need to help a user who locked their YubiKey by entering the wrong PIN too many times, and they weren't able to physically bring the YubiKey to me, I would *definitely* want to be able to give them a code which unlocks the PIN without giving them full access to change *everything* on the card.

```
1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? 2
```

* Enter the Admin PIN (which you just set above)
* Enter the new PUK
* Enter the new PUK again

```
PIN changed.
```

When you're finished setting the PIN codes, use "`q`" to leave that menu and go back to the "`gpg/card>`" prompt.

```
1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? q

gpg/card>
```


Next, enter some basic info about the "owner" of the card, along with their preferred language. This information is stored on the YubiKey, and will be visible to anybody who runs "`gpg --card-info`" or "`gpg --card-edit`" while the YubiKey is plugged in.

```
gpg/card> name
Cardholder's surname: Simpson
Cardholder's given name: John

gpg/card> login
Login data (account name): jms1@jms1.net

gpg/card> lang
Language preferences: en
```

You *can* also enter a URL where the corresponding public key can be downloaded. Doing this allows you to use the "`gpg --edit-card`" command's "`fetch`" sub-command to load your *public* keys into a new computer's keyring. PGPCards only hold *secret* keys - they don't hold public keys, user IDs, signatures, or expiration dates.

This is not required. If you don't have, or don't want, a copy of your public key saved on a web site somewhere, feel free to skip this step.

```
gpg/card> url
URL to retrieve public key: https://jms1.net/6B2EDC90B5C6DC30.pub.asc
```

You can also set a flag which tells the YubiKey to require the PIN to be entered, *every time* a signature is generated. Without this, you will be asked for the PIN the first time you generate one, and the YubiKey will "stay unlocked" and generate more signatures as requested, until it is unplugged from the computer.

```
gpg/card> forcesig
```

To see the updated state of the card, just hit RETURN at the "`gpg/card>`" prompt.

```
gpg/card>

Reader ...........: Yubico Yubikey 4 OTP U2F CCID
Application ID ...: D2760001240102010006069404470000
Version ..........: 2.1
Manufacturer .....: Yubico
Serial number ....: 06940447
Name of cardholder: John Simpson
Language prefs ...: en
Sex ..............: unspecified
URL of public key : https://jms1.net/6B2EDC90B5C6DC30.pub.asc
Login data .......: jms1@jms1.net
Signature PIN ....: forced
Key attributes ...: rsa4096 rsa4096 rsa4096
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 0 3
Signature counter : 0
Signature key ....: [none]
Encryption key....: [none]
Authentication key: [none]
General key info..: [none]
```

When you're happy with the settings, use "`q`" to exit the "`gpg --card-edit`" command. Note that this isn't "saving" anything, the changes you made were saved to the YubiKey immediately.

```
gpg/card> q
```

**Remove and re-insert the Yubikey.**

From this point forward, you will need to enter the PIN in order to make use of any keys, and you will need to enter the Admin PIN in order to load keys or change settings.

### Notes

* The "URL of public key" is used by the "`fetch`" command (under "`gpg --card-edit`") to retrieve the public key when using the YubiKey on a machine which doesn't already have the public key in its keyring.

# Load keys on Yubikey

```
$ gpg --edit-key 6353320118E1DEA2F38EAE806B2EDC90B5C6DC30
gpg (GnuPG/MacGPG2) 2.2.0; Copyright (C) 2017 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

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

Select the Authentication sub-key.

* Each "`ssb`" line is a sub-key. They are numbered in the order shown here (even though the program doesn't show the numbers.)

* You will see an asterisk appear next to a sub-key when it is selected.

* It is possible to select more than one key. The same `key` command which selects a key will also de-select a key. (You will see this below.)

Make sure the Authentication sub-key is the *only* one selected.

```
gpg> key 2

sec  rsa4096/0x6B2EDC90B5C6DC30
     created: 2017-05-27  expires: never       usage: SC
     trust: ultimate      validity: ultimate
ssb  rsa4096/0x297E5961AB566594
     created: 2017-05-27  expires: never       usage: E
ssb* rsa4096/0xBA6C2A169C6C0F60
     created: 2017-11-10  expires: never       usage: A
[ultimate] (1). John M. Simpson <jms1@voalte.com>
[ultimate] (2)  John M. Simpson <jms1@jms1.net>
```

Send the selected sub-key to the Authentication slot on the Yubikey (or the "card", as `gpg` calls it.)

```
gpg> keytocard
Please select where to store the key:
   (3) Authentication key
Your selection? 3

sec  rsa4096/0x6B2EDC90B5C6DC30
     created: 2017-05-27  expires: never       usage: SC
     trust: ultimate      validity: ultimate
ssb  rsa4096/0x297E5961AB566594
     created: 2017-05-27  expires: never       usage: E
ssb* rsa4096/0xBA6C2A169C6C0F60
     created: 2017-11-10  expires: never       usage: A
[ultimate] (1). John M. Simpson <jms1@voalte.com>
[ultimate] (2)  John M. Simpson <jms1@jms1.net>
```

Now select the Encryption sub-key, and un-select the Authentication sub-key.

```
gpg> key 1

sec  rsa4096/0x6B2EDC90B5C6DC30
     created: 2017-05-27  expires: never       usage: SC
     trust: ultimate      validity: ultimate
ssb* rsa4096/0x297E5961AB566594
     created: 2017-05-27  expires: never       usage: E
ssb* rsa4096/0xBA6C2A169C6C0F60
     created: 2017-11-10  expires: never       usage: A
[ultimate] (1). John M. Simpson <jms1@voalte.com>
[ultimate] (2)  John M. Simpson <jms1@jms1.net>

gpg> key 2

sec  rsa4096/0x6B2EDC90B5C6DC30
     created: 2017-05-27  expires: never       usage: SC
     trust: ultimate      validity: ultimate
ssb* rsa4096/0x297E5961AB566594
     created: 2017-05-27  expires: never       usage: E
ssb  rsa4096/0xBA6C2A169C6C0F60
     created: 2017-11-10  expires: never       usage: A
[ultimate] (1). John M. Simpson <jms1@voalte.com>
[ultimate] (2)  John M. Simpson <jms1@jms1.net>
```

Send the selected sub-key to the Encryption slot on the Yubikey.

```
gpg> keytocard
Please select where to store the key:
   (2) Encryption key
Your selection? 2

sec  rsa4096/0x6B2EDC90B5C6DC30
     created: 2017-05-27  expires: never       usage: SC
     trust: ultimate      validity: ultimate
ssb* rsa4096/0x297E5961AB566594
     created: 2017-05-27  expires: never       usage: E
ssb  rsa4096/0xBA6C2A169C6C0F60
     created: 2017-11-10  expires: never       usage: A
[ultimate] (1). John M. Simpson <jms1@voalte.com>
[ultimate] (2)  John M. Simpson <jms1@jms1.net>
```

Now un-select all sub-keys, which results in the main key being selected.

```
gpg> key 1

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

Send the main key to the Signature slot on the Yubikey.

```
gpg> keytocard
Really move the primary key? (y/N) y
Please select where to store the key:
   (1) Signature key
   (3) Authentication key
Your selection? 1

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

We're done here, **BUT** ... we need to be careful. The next command will quit out of the "`gpg --card-edit`" command, and it will ask if you want to save changes. **IF YOU SAY YES, the secret keys you just installed on the YubiKey will be REMOVED from the secret keyring file on the computer.**

Unless you are 100% sure that's what you want to do (i.e. if you have a known-good backup of the secret keys), **BE SURE TO SAY NO**.

```
gpg> q
Save changes? (y/N) n
Quit without saving? (y/N) y
```

Now if you query the card, you will see the keys in the three slots.

```
$ gpg --card-status

Reader ...........: Yubico Yubikey 4 OTP U2F CCID
Application ID ...: D2760001240102010006069404470000
Version ..........: 2.1
Manufacturer .....: Yubico
Serial number ....: 06940447
Name of cardholder: John Simpson
Language prefs ...: en
Sex ..............: unspecified
URL of public key : https://jms1.net/6B2EDC90B5C6DC30.pub.asc
Login data .......: jms1@jms1.net
Signature PIN ....: not forced
Key attributes ...: rsa4096 rsa4096 rsa4096
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 0 3
Signature counter : 0
Signature key ....: 6353 3201 18E1 DEA2 F38E  AE80 6B2E DC90 B5C6 DC30
      created ....: 2017-05-27 22:28:31
Encryption key....: 0660 766F 2768 F41F D4B9  1DB7 297E 5961 AB56 6594
      created ....: 2017-05-27 22:28:31
Authentication key: BBA5 C6BB 23D2 B53B 0D0F  6C0B BA6C 2A16 9C6C 0F60
      created ....: 2017-11-10 23:29:14
General key info..: pub  rsa4096/0x6B2EDC90B5C6DC30 2017-05-27 John M. Simpson <jms1@voalte.com>
sec   rsa4096/0x6B2EDC90B5C6DC30  created: 2017-05-27  expires: never
ssb   rsa4096/0x297E5961AB566594  created: 2017-05-27  expires: never
ssb   rsa4096/0xBA6C2A169C6C0F60  created: 2017-11-10  expires: never
```

### Notes

* The output you see from the commands above may differ slightly based on the version of the `gpg` software and how it's configured.

* **The Yubikey does not store public keys, it only stores private keys.** Private keys are just numbers, they don't have attributes like names or expire dates. Everything after the fingerprints, such as the name and email, and the `created:` and `expires:` dates, all came from the keyring on the machine. If you query the card from a machine which doesn't have the public keys available, all you will see is the fingerprints.

As an example, this is a different version of `gpg`, looking at a different Yubikey, with different key loaded, and for this example I manually changed the `GNUPGHOME` variable to point to an empty directory so the command won't recognize the key...

```
$ gpg --card-status
Reader ...........: Yubico YubiKey OTP FIDO CCID
Application ID ...: D2760001240102010006063013830000
Version ..........: 2.1
Manufacturer .....: Yubico
Serial number ....: 06301383
Name of cardholder: John Simpson
Language prefs ...: en
Sex ..............: unspecified
URL of public key : https://jms1.net/A7EC1FBAB3B50007.pub.asc
Login data .......: jms1@jms1.net
Signature PIN ....: forced
Key attributes ...: rsa4096 rsa4096 rsa4096
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 0 3
Signature counter : 74
Signature key ....: AF6C 0A45 953A 0881 06A7  D254 CE57 35E1 E04C 1374
      created ....: 2017-11-27 00:53:45
Encryption key....: BF37 34CD 9834 B3B4 7A8E  D70E 2A9E B3A6 20A1 C087
      created ....: 2017-11-27 00:36:27
Authentication key: 5761 1969 0CC7 57A4 7300  57C3 A634 470E CECC 41E0
      created ....: 2017-11-27 01:00:17
General key info..: [none]
```

# Changelog

**2024-06-19** jms1

- moved page to new `jms1.info` site, updated header

**2021-01-22** jms1

- added more detail about setting the user data (name, email, etc.)
- added more detail about setting PINs, including PUK

**2020-12-24** jms1

- added note about not saving changes when quitting out of `gpg --card-edit`

**2020-12-20** jms1

- moved to `jms1.info`
- added the "Background" section at the top, moved "Changelog" to the end
- tweaked formatting

**2018-03-06** jms1

- tweaked the formatting
- last version on `jms1.net` site

**2017-12-13** jms1

- first version

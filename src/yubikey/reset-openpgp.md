# Reset the YubiKey OpenPGP App

**2017-12-13**

How to reset the OpenPGP app on a YubiKey Neo

## Yubico's official procedure

**Yubico now has an [officially documented procedure](https://support.yubico.com/support/solutions/articles/15000006421-resetting-the-openpgp-applet-on-the-yubikey) for resetting the OpenPGP applet on a YubiKey device.**

The procedure documented below seems to have worked for me with a YubiKey Neo in the past, however I don't know if it will also work with other YubiKey hardware, and to be honest I'm not 100% sure exactly what it's doing. I just combined information from a few different web sites until I found something that worked for me at the time.

Please use Yubico's [officially documented procedure](https://support.yubico.com/support/solutions/articles/15000006421-resetting-the-openpgp-applet-on-the-yubikey) instead of using the procedure below.

## Old content

```
$ gpg-connect-agent <<EOF
/hex
scd serialno
scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
scd apdu 00 44 00 00
scd apdu 00 e6 00 00
/bye
EOF
```

Remove and insert YubiKey.

```
$ gpg --card-status
gpg: selecting openpgp failed: Operation not supported by device
gpg: OpenPGP card not available: Operation not supported by device
```

```
$ gpg-connect-agent <<EOF
/hex
scd serialno undefined
scd apdu 00 a4 04 00 06 d2 76 00 01 24 01
scd apdu 00 44 00 00
scd apdu 00 e6 00 00
/bye
EOF
```

```
$ gpg --card-status
gpg: selecting openpgp failed: Conflicting use
gpg: OpenPGP card not available: Conflicting use
```

Remove and insert YubiKey.

```
$ gpg --card-status
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
Key attributes ...: rsa2048 rsa2048 rsa2048
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 0 3
Signature counter : 0
Signature key ....: [none]
Encryption key....: [none]
Authentication key: [none]
General key info..: [none]
```

The OpenPGP app is now "empty" - no keys, PINs reset to default values, etc.

# Changelog

**2024-06-19** jms1

- moved page to new `jms1.info` site, updated header

**2020-12-20** jms1

- moved to `jms1.info`, moved Changelog to end of file
- minor formatting updates

**2019-03-23** jms1

- added info about Yubico's supported process for resetting the OpenPGP applet
- last version on `jms1.net`

**2017-12-13** jms1

- initial version

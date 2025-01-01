# Your Keybase Account

So you just created a brand new Keybase account. Congratulations, and welcome to better security.

Before you start using Keybase, there are some things you really need to understand. Keybase is different from most "social media" programs.

## Devices

**The biggest difference is devices.**

A Keybase account has one or more devices attached to it. Each device is a computer or a mobile device (phone, tablet, etc.) which runs the Keybase client.

The encryption keys which secure everything, are specific to each device. There is no "master key" for the entire account. The account's password is only used to log into the Keybase web site, and as *one part of* the process of adding new devices to the account.

The web site has no access to any encrypted content, including "chat". It only exists as a way to perform a few administrative tasks. Operations which involve encrypted content can only be done using a Keybase client.

> &#x1F6D1; **MAKE SURE YOUR KEYBASE ACCOUNT HAS MULTIPLE DEVICES ON IT.** &#x1F6D1;
>
> This is the most important thing to remember about Keybase. If you lose all devices on your Keybase account, there will be no way to access any content encrypted using the account's device keys.

### View devices on your account

If you're not sure what devices are on your account, there are three ways to find out:

* **Command line**

    ```
    keybase device list
    ```

    This will show a list of the active devices on your account, along with each device's internal ID, the date/time when it was added to the account, and the last time the device was used.

* **Keybase GUI client**

    On a computer (Linux, macOS, or windows), in the bar along the left side of the Keybase client window, click "Devices".

    On a mobile client (iOS or android), the "bar along the left side" will be on the bottom, and will only have room for a few options. On my iPhone these options are People, Chat, File, Teams, and "More". The "More" option looks like a hamburger, and if tapped, it goes to a list of other functions, one of which will is "Devices".

    However you get there, it will show you a list of the active devices on your account, plus a section at the bottom which can be expanded to show any "revoked" devices. These are devices which *were* on your account, but no longer have access to the account.

* **Web site**

    Visit `https://keybase.io/USERNAME/devices`, substituting any Keybase username where you see `USERNAME`.

    Note that anybody can access these pages, even people who don't use Keybase. For example, if you're curious, [`https://keybase.io/jms1/devices`](https://keybase.io/jms1/devices) is the list of devices on my account.

## Adding devices to your account

**Adding a device to your Keybase account requires the use of an existing device on the account.** If you don't have an active device, you can't add more devices.

The first step in adding a device to your account is to install the Keybase client software on the new device. Keybase has clients for Linux, macOS, ms-windows, iOS, and Android. Their web site's [download page](https://keybase.io/download) has simple directions for how to download and install the software on a computer, as well as links to the iOS and Android app stores.

&#x21D2; [`https://keybase.io/download`](https://keybase.io/download)

The first time you run the software it will give you options to create a new account, or to log into an existing account. Selecting the "log into an existing account" option will walk you through the process of adding the new device to your account.

Note that if you don't physically *have* a second device that you can install Keybase on, you can create a "paper key". In fact, even if you have a dozen physical devices on your Keybase account, **you should create a paper key**.

## Paper Keys

A paper key is a sequence of 13 words which encode an encryption key. This key is attached to your Keybase account like a normal device key, without requiring an installed Keybase client.

**They are called "paper keys" because you're supposed to *physically write the words down on paper*, and lock the paper up someplace safe.**

The first two words serve as a "public key", to identify which key is which in case you have more than one paperkey on your account (which is certainly possible, and may be useful in some cases). The other 11 words are a secret key, and should never be shared with anybody

Obviously "safe" means that other people shouldn't be able to access it, but you should also consider *physical* safety. If it's locked up at home, what happens if your house catches fire, or floods, or if an earthquake destroys it?

As an example, the paper keys for my own Keybase accounts are ...

* Written down on paper and stored in a fire safe at home. The paper itself has nothing on it but a collection of random words, so if somebody manages to break into the safe, they won't immediately know what the words are for - all they'll see is a collection of random words.

* In a text file, stored on an encrypted USB stick, also stored in the fire safe at home.

* On another encrypted USB stick, physically stored with a family member in a different part of the world.

This means if something happens to my house, up to and including permanent destruction, I *can* get the backup copies of the paperkeys from this family member. It might *take* a few days to get that USB stick, but I wouldn't be *permanently* locked out of my accounts.

### Creating a Paper Key

* **Command line**

    ```
    keybase paperkey
    ```

* **Keybase GUI client**

    The "View devices on your account" section above explains how to see the list of devices on your account. Above this list should be an "Add a device or paper key" button. Click this button.

    The program will ask what kind of device you want to add - computer, phone or tablet, or paper key. Select "Create a paper key".

Either way, it will generate the paperkey, attach it to your account, and show you the sequence of words. **This is the only time the full paperkey will ever be shown**, so be sure to write them down on paper, and maybe also save them in a "password vault" such as [1Password](https://1password.com/).


## Removing devices from your account

* **Command line**

    First use `keybase device list` to find the internal ID of the device you want to remove.

    ```
    $ keybase device list
    Name                             Type         ID                                 Created                Last Used
    ==========                       ==========   ==========                         ==========             ==========
    My Phone                         mobile       13579bdf02468ace13579bdf02468ace   2023 Jun 14 13:41:05   2024 Dec 24 12:56:08
    Linux Server                     desktop      43214321432143214321432143214321   2024 Aug 12 21:41:42   2024 Dec 21 21:14:32
    Paper Key (winter absolute...)   backup       c0ffeec0ffeec0ffeec0ffeedeadbeef   2020 Dec 5 15:35:39    2024 Aug 7 17:50:13
    Old Phone                        mobile       0123456789abcdef0123456789abcdef   2019 Sep 22 23:27:58   2023 Jun 14 13:52:14
    ```

    Then use `keybase device remove` with that ID to remove the device.

    ```
    keybase device remove 0123456789abcdef0123456789abcdef
    ```

* **Keybase GUI client**

    * In the bar along the left side of the window, click "Devices" near the bottom.

    * Tap the device you want to remove. This will show you when it was created and when it was last used. There will be a red button saying "Revoke this computer", "Revoke this device", or "Revoke this paper key", depending on what kind of device it is.

    * Tap the red button.


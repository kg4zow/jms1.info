# Before You Lose Access

**Hopefully you're reading this page BEFORE disaster strikes.**

I've seen a lot of cases where people create a Keybase account and then lose access to it, because they didn't read the documentation, or they were in a hurry and skipped over steps, or in a few cases, because they created their accounts long enough ago that some of the warnings that the current client shows, didn't exist at the time.

This page will explain a few things that you should do, *while you have access to your account*, so that if something goes wrong you won't lose access to everything stored in your account.

# Background

## Multiple Devices

> &#x1F6D1; **MAKE SURE YOUR KEYBASE ACCOUNT HAS MULTIPLE DEVICES ON IT.** &#x1F6D1;
>
> This is the most important thing on this entire page.

Keybase encrypts things (chat messages, files, git commits, etc.) using encryption keys which are *specific to each device*. These keys are stored on each device, and are never sent to any Keybase server.

**If you lose the encryption keys for every device on your account, you will lose access to everything stored in the account.** This includes ...

* Chat history
* Files stored in KBFS
* Git repositories

If these things are accessible by other people or teams, those other people will still have access, but you won't.

I know I said it above, but I'll say it again.

&#x1F6D1; **MAKE SURE YOUR KEYBASE ACCOUNT HAS MULTIPLE DEVICES ON IT.** &#x1F6D1;

### Adding devices to your account

Keybase has clients for Linux, macOS, ms-windows, Android, and iOS. Their web site has directions for how to [download and install the software](https://keybase.io/download), as well as how to add the device to your existing account.

If you don't physically *have* a second device that you can install Keybase on, you can create a "paper key".

In fact, even if you have a dozen devices with Keybase installed, you should create a paper key.

If you don't know what devices are on your account, check the "Devices" tab in your Keybase app, or visit `https://keybase.io/___/devices` (substitute your username where you see `___` in the URL).

## Paper Keys

A paper key is a sequence of 13 words which encode a device encryption key. This key is attached to your Keybase account like a normal device key.

They are called "paper keys" because you're supposed to *physically write them down on paper*, and lock the paper up someplace safe.

Obviously "safe" means that other people shouldn't be able to access it, but you should also consider *physical* safety. If it's locked up at home, what happens if your house catches fire, or floods, or if an earthquake destroys it?

As an example, the paper keys for my own Keybase accounts are ...

* Written down on paper and stored in a fire safe at home. The paper itself has nothing on it but a collection of random words, so if somebody manages to break into the safe, they won't immediately know what the words are for - all they'll see is a collection of random words.
* In a text file, stored on an encrypted USB stick, also stored in the fire safe at home.
* On another encrypted USB stick, physically stored with a family member in a different part of the world.

This means if something happens to my house, up to and including permanent destruction, I *can* get the backup copies of the paperkeys from this family member. It might *take* a few days, but I wouldn't be *permanently* locked out of my accounts.

## Resetting Your Account

The Keybase web site offers a way to "reset" your account. They do warn about this being a drastic action, but I don't feel like they make it "scary" enough.

> &#x1F6D1; **Resetting your account starts a new account with the same username.**
>
> If you do this, you will *permanently* lose accesss to the content stored in the old account.
>
> Even if you later find one of the old devices, it won't be able to log into your Keybase account anymore.

I explained above that if you lose the encryption keys for *every* device on your account, you lose access to everything *stored* in the account. When you reset your account, you are deleting the account entirely, and starting a new account with the same username. Other than the username, there is no connection between the old account and the new one.

You will also lose your memberships in any groups you may be part of. This also means that if your account was the only "owner" of any teams, those teams will now have no owner at all - which means they cannot be fully managed (and if there are also no users with the "admin" role, they cannot be managed at all).

**The only time you should ever reset your account is if you are 110% sure that you will NEVER be able to regain access to the devices on the old account.** If there is even a *remote* chance of regaining access to any of your old devices, I recommend starting a new account with a different username.

## Lockdown Mode

It goes without saying that you should use a strong password for your Keybase account, and it should be a password that you aren't using for anything else.

BUT.

If somebody manages to get the password for your Keybase account, they could log into the web site as you and reset your account. Doing this wouldn't give them access to your stored information, but it would prevent YOU from being able to access it. (This is a form of "denial of service attack".)

> &#x1F6D1; **There is no notification when an account is reset.** If somebody manages to reset your account, you wouldn't know about it until you discover that you can't access your Keybase account anymore - and by then it would be too late to do anything about it.
>
> This is not something that Keybase employees would be able to help you with. If your account is reset, whether you do it or an attacker does it, everything encrypted with the old account's device keys will be gone.

In the Keybase client, under Settings &#x2192; Advanced, there is an "Enable account lockdown mode" setting. If this checkbox is turned on, Keybase will only allow the account to be reset or deleted *from a logged-in Keybase device*. If an attacker has your Keybase password and logs into the web site as you, the only things they could do would be to send invitations or change your notification settings.

Of course, if your account is in Lockdown Mode and you lose all of the devices, the account *cannot be recovered or deleted*. This means that you wouldn't be able to re-use the same username.

**This makes it even more important that you not lose all of your devices, and that you have a paperkey.**

&#x21D2; [This page](https://book.keybase.io/docs/lockdown) has more details about Lockdown Mode.

> &#x2139;&#xFE0F; **All of my Keybase accounts have "Lockdown mode" turned on.**
>
> I'm okay with this, because I have paperkeys stored securely.


# Checklist

* Make sure your account has multiple devices attached to it.

* Create a paperkey, write it down, and store it securely.

* Check your devices every so often. (I check mine every few months.)

    * Check the list of devices. You can see this in the Keybase client, or by visiting `https://keybase.io/USERNAME/devices` (substitute your own Keybase username for `USERNAME`, obviously). Make sure that the devices you *think* are on the account, are actually there. Also make sure that your account doesn't have any devices which shouldn't be there.

    * For phones, tablets, or computers that you may not use every day, make sure their software is up to date (especially the Keybase client itself), and that they are able to log into the account.

* Enable "Lockdown Mode" on your account, but **ONLY AFTER** making sure you have multiple devices and a paperkey.

# Keybase

[Keybase](https://keybase.io/) is a system which provides end-to-end encrypted services, including ...

* Text chat, between groups of specific people, and within "teams".
* Cloud file storage, with the files accessible to yourself, a specific set of people, or a team.
* Git repositories, accessible to yourself or to a team.
* Encrypting, decrypting, signing, and verifying encrypted messages which can be sent by some other method (such as email, or a "corporate approved and monitored" chat system).

Keybase also provides a way to prove your identity on some other service, and to allow others to find you based on those identities. These services include Github, Reddit, and Hackernews. You can also "prove" that you own specific DNS domains and web sites.

You can also attach PGP keys to your Keybase account. This was actually Keybase's original application, as a way to find other peoples' PGP keys when all you knew them as, was a username on a site like Reddit.

For example, if you only know somebody as "kg4zow on Github", if a Keybase user has proven that they own that Github user (hint: [I did](https://gist.github.com/kg4zow/9ad2650ff8e39bee4da4)), you can use Keybase to chat or share files with them, secure in the knowledge that the person you are communicating with on Keybase *is* the same person as "kg4zow on Github".

## KBFS: Cloud File Storage

KBFS, or Keybase Filesystem, is a cloud file storage system. Keybase provides 250 GB of encrypted cloud storage for each user, as well as 100 GB for each team. This storage can be accessed by any Keybase client which is registered as a device on a user's account.

Each user also has a public directory available, whose contents can be viewed by any other Keybase user. For example, if you're logged into Keybase you can look in `/keybase/public/jms1/` to see the files that I'm sharing with the world.

### FUSE and Redirector

For Linux, macOS, and ms-windows systems, Keybase provides a way to "mount" KBFS so it appears as part of the machine's filesystem. The details are different for each operating system, but Linux and macOS both use a FUSE (**F**ilesystem in **USE**rspace) module to translate "file accesses" to the appropriate API calls needed to upload and download encrypted blocks from Keybase's cloud servers.

It's possible for multiple people to be logged into a computer at the same time, so Keybase needs to ensure that different users on the same machine can't see each others' Keybase files. The mechanics of how this happens are different for each operating sytem.

I don't want to go into a lot of technical detail, so the short version is this:

* Each *user* on a computer has their own "view" of KBFS, mounted in a different directory.

* KBFS uses a thing called a "redirector", which redirects file accesses to the user-specific mount directory for whatever user is accessing it.

    * On Linux, the redirector is mounted as `/keybase`.

    * On macOS, the redirector is mounted as `/Volumes/Keybase`. Some systems may also have `/keybase` as a symbolic link pointing to `/Volumes/Keybase`.

The idea is, all users on the system can use paths starting with `/keybase/`, and they will see their own "version" of KBFS, containing the files that *they* have access to.

Because of this, the normal way to write the names of files stored in KBFS is using paths starting with `/keybase/`.

#### ms-windows

You will note that I didn't mention ms-windows at all. This is because I haven't used ms-windows since the days of "windows 7", and I don't remember the details of how KBFS works on windows.

I have a vague memory of there being a third-party program which needs to be installed - a quick web search tells me that what I'm thinking of is probably [Dokan](https://dokan-dev.github.io/). I don't remember if this is distributed with the Keybase installer, or if you have to download and install it yourself.

### KBFS Directories

KBFS has three high-level categories of directories: public, private, and team. Under these categories, folders "exist" whose name tell who have access to them.

#### Public

* `/keybase/public/alice/` is readable by anybody, but only writable by Alice.

* `/keybase/public/alice,bob/` is readable by anybody, but only Alice and Bob are able to write to it. (This is not something you see a whole lot, but it works if you have a need for it.)

#### Private

* `/keybase/private/alice/` is only accessible by Alice (or technically, by devices on Alice's account).

* `/keybase/private/alice,bob/` is accessible to both Alice and Bob.

* `/keybase/private/alice,bob#charlie,david/` is accessible to Alice, Bob, Charlie, and David.
    * Alice and Bob (before the `#`) are able to read and write files.
    * Charlie and David (after the `#`) are able to read the files but not write them.

    As you can see, it's possible to create private folders where different people have different access. However, once that folder exists, the list of who has what access can never change. If you need to remove somebody's access, or change them from read-only to read-write, your only option is to create an entirely new folder whose name is the *new* list of who has what access, and move the files from one to the other. The old one will still "exist", it'll just be empty.

    Keybase added "Teams" as a way to deal with this problem. Users can be added or removed from a team, or have their roles changed, without needing to change any team or directory names.

#### Team

* `/keybase/team/xyzzy/` is accessible by Keybase users who are members of the `xyzzy` team. Each user's role within the team controls what access they have to the files in the team's folder.

* `/keybase/team/xyzzy.dev/` is accessible by Keybase users who are members of the `xyzzy.dev` team. This is a "sub-team" of the `xyzzy` team. (Sub-teams are explained below.)

> &#x2139;&#xFE0F; The user and team names shown above are all examples. I don't know if there are users or teams with those names.

Teams are explained in more detail below.

### Space

I mentioned this above, but to make it more obvious ...

* Each user is given 250 GB of storage for free.
* Each team is given 100 GB of storage for free.
* There is currently no limit to the number of teams which can be created.

The one restriction is, teams cannot have the same name as a user. This means that, because I already have the username `jms1`, I could not also create a team called `jms1`.

## Teams

"Teams" are groups of Keybase users. Users can be added to or removed from teams dynamically.

This is different than a "group of users" situation. A "group chat" between Alice, Bob, and Charlie will *only* ever contain those people. If you try to add a fourth person, it creates a *new* group chat between those four people. The original three-way chat will still exist, and the fourth person will never be able to access it.

* When users are added to a team, they will have access to the team's chat history, shared files, and git repos.

* When users are removed from a team, they will *immediately* no longer have access to the team's chat history, shared files, or git repos. (If they previously saved anything they will still have access to their own *copies*, but they won't be able to access

### Roles

Users who are added to a team will be able to see the team's chat history, shared files, and git repositories, subject to their "role" within the team.

Available roles are:

* `reader` = can participate in team chat rooms, has read-only access to the team's KBFS folders and git repositories.

* `writer` = same as `reader`, but has read-write access to the team's KBFS folders and git repositories.

* `admin` = same as `writer`, but can add or remove team members and set their roles, up to `admin`. Can also create or delete sub-teams "below" this team (so if somebody is an `admin` for the team `xyzzy.dev`, they could create an `xyzzy.dev.ios` sub-team).

* `owner` = Can create or delete sub-teams anywhere below the top-level team, as well as add, remove, and set the role for any user in any sub-team.

Users who are an `admin` or `owner` of a team do not automatically have access to its sub-teams' chats or files. They do, however, have the ability to add themselves to the sub-team. This is referred to as "implied admin" permission. (Note that if they do this, the other team members will be able to see that the admin/owner is now a member of the team - there's no way they could give themselves access without it being visible.)

Team admins and owners can set a minimum role needed to write in the team's chat. This is normally set to `reader`, but can be set to `writer` or `admin` if there's a need to have people who can *read* the team chat but not be able to "speak" in it (i.e. an "announce-only" channel).

### Sub-Teams

Teams can have "sub-teams". For example, the `xyzzy` top-level team might have sub-teams called `xyzzy.dev`, `xyzzy.qa`, and `xyzzy.sales`. Each sub-team has its own list of members, with their own roles for that team.


## Keybase Sites

Keybase Sites provides simple web hosting for sites containing static files.

Keybase originally had a web site using the `keybase.pub` domain, where every user's `/keybase/public/xxx/` directory could be viewed. This service was taken down in ... I want to say 2023-02?

They also have a service which can host static pages stored in almost any Keybase directory, using a custom domain name that you own. This is how I'm hosting the `jms1.info` site (where you're presumably reading this right now).

[The documentation](https://book.keybase.io/sites) is a bit outdated. You can ignore anything that mentions the `keybase.pub` domain, but the "Custom domains" section still works exactly as described.

## My Experience

I've been using keybase since 2017. I've had very few problems with it, and the problems I *have* had were mostly related to Apple making low-level changes to macOS, and Keybase/Zoom not using the beta versions to test the client *before* the new macOS is released to the public.

One thing I did find interesting ... when Apple first released computers with the "Apple Silicon" processors, I had an M1 MacBook Air. The Keybase app hadn't been updated to support it yet, and at the time nobody at Keybase *had* an M1 machine to try it with. One of the Keybase devs sent me what he *thought* should be a working client, and I was able to test it for them and send back some log files. Keybase released the first client which supported the M1 processor about a week later.

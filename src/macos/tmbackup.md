# Backing up a Time Machine Image

2026-04-29 Wed

I recently ran into a situation where the internal spinning disk in one of my older Mac Minis was dying. This made the machine crash, or just "freeze up", at random intervals. Sometimes it would work for a few days, other times it would work for a few minutes. Over time, the "time between failures" got shorter and shorter, until it finally reached the point where it would consistently crash in less than an hour.

The machine did have a Time Machine backup on an external disk, less than a week old. Nothing had been added or changed on the machine itself that needed to be backed up, so that backup already contained all of the files I needed to save. I was able to physically plug that disk into a newer machine (an M2 Mac Studio) and see the backed-up files, and running Disk Utility's "First Aid" function on the disk didn't report any errors, so the *backup* was good.

The machine itself (an older Intel Mac Mini) seemed to be okay, the problem was the spinning disk itself. So my plan was to replace the disk with a SATA SSD. However, I didn't want to lose the files,

I wanted to make a DMG disk image, containing the system's full contents, either from the system itself, or from the most recent Time Machine backup.


## Things I Tried

* On the dying machine, use Disk Utility to make an image of the machine, to a different external disk.

    This idea didn't work very well because the machine kept crashing part-way through the process.

    Given the problems I ran into below, I'm not sure if it would have worked any better if I had done it a few months ago, when the hard drive was still capable of running for several hours before crashing.

* On the newer machine, use Disk Utility to make an image of the folder from the Time Machine backup disk.

    This didn't work. When I tried, about 45 seconds into the operation it stopped and told me "Operation cancelled", without any explanation of *why* it stopped.

    I tried running "First Aid" on the Time Machine disk, it didn't find any errors, so ... no idea.

* On the newer machine, using `hdiutil` to manually make a disk image from the folder on the Time Machine backup disk.

    In theory, this command should have worked:

    ```
    sudo hdiutil create \
        -srcfolder  /Volumes/TMDisk/2026-04-09-153426.previous \
        -type       UDZO \
        -layout     NONE \
        -fs         HFS+ \
        -volname    "Old System HD" \
        "$HOME/Desktop/Old System HD"
    ```

    This also disn't work. I tried this several times, with different options, after fixing a few oddities with the files *in* the backup image - files with `0000` permissions, directories whose `x` permission had been removed, files with strange "flags", etc. I also tried using `sudo` with the `hdiutil` command, which *did* help, but eventually I ran into an error message that didn't explain what the problem was, and about which I couldn't find any useful information on the internet.

* On the newer machine, using [Carbon Copy Cloner](https://bombich.com/) to back up the folder on the Time Machine backup disk, to a DMG file. (I figured if anybody knew how to do this, the guys who wrote CCC would.)

    As soon as I pointed CCC to the Time Machine disk as a source, it popped up a dialog saying that it couldn't (and wouldn't even try to) back up Time Machine images, because Apple didn't support it. This is explained in more detail on [this page](https://support.bombich.com/hc/en-us/articles/20686476880791-Can-I-use-CCC-to-copy-a-Time-Machine-backup) on their support site.

## What Finally Worked

I ended up having to make the backup by hand, *and* I had to use `rsync` to copy the files, rather than any Apple utility.

At a high level, the process is this:

* Create a temporary read-write disk image.
* Use `rsync` to copy the files from the Time Machine image, into the temporary disk image.
* Convert the temporary read-write image into a read-only disk image. This image can be compressed and/or encrypted if you like.

This process depends on having enough disk space for *two full copies* of the data being backed up. The free space doesn't necessarily have to be on the same disk, however if you're going to use two disks (one for the temporary image and one for the final read-only image), the disks containing those locations each need to have enough free space for a full copy of the data being backed up.

### Create the Temporary Disk Image

* Plug in the Time Machine disk, and wait for the disk's icon to appear on the desktop.
    * If the disk is encrypted, you may need to enter its password.
    * If macOS asks about using the disk *as* a Time Machine backup disk, say no.

* Find the `/Volumes/xxx` directory for the Time Machine disk, and save it to a variable.
    ```
    $ ls -l /Volumes/
    total 0
    drwxrwxr-x@  19 root  wheel   192 Apr 27 10:59 Extra Disk
    lrwxr-xr-x    1 root  wheel     1 Apr 27 10:59 NewSystem Internal HD -> /
    drwxrwxr-x@   6 root  wheel   192 Apr 29 10:32 OldSystem TM
    ```

    In this example ...
    * `NewSystem Internal HD` is the internal disk of the system we're running on.
    * `OldSystem TM` is the external Time Machine disk.
    * `Extra Disk` is an extra external disk with enough free space to hold a temporary copy of the data being backed up.

    ```
    TM_DISK="/Volumes/OldSystem TM"
    ```

    Saving this to a variable will allow you to copy-and-paste the commands below, rather than having to manually type the disk names and worry about quoting.

* Save the name of the disk image you want to create, to a variable.
    ```
    IMG="OldSystem HD"
    ```

* Calculate a few other variables.
    ```
    DST="$HOME/Desktop/$IMG"
    SRC="$( echo "$TM_DISK"/2* | tail -1 )"
    USED="$( sudo du -sk "$SRC" | awk '{print $1}' )"
    SIZE_KB="$(( USED + 65536 ))"
    ```
    These are:
    * `DST` is the filename for the *final* read-only image. This *can* include `.dmg` at the end, but if you don't include it, the command which creates the final image will add it automatically.
    * `SRC` is the Time Machine *directory* you'll be backing up. Depending on which OS/X or macOS version was used, there may be multiple "dated" directories on the disk. This command returns the name of the *most recent* directory.
    * `USED` contains how much disk space is being used by the backup image, in KiB (units of 1024 bytes). We need this so we can create the temporary image with enough space to hold the files.
    * `SIZE_KB` is the actual size of the temporary disk image we'll be creating. This is the total disk space being used, plus 64 MiB (which is needed to hold the filesystem's data structures).

* `cd` into the directory where you want to create the temporary disk image.
    ```
    cd "/Volumes/Extra Disk"
    ```

    Note that I had to use quotes because the disk name has a space in it.

* Create and mount the temporary disk image.
    ```
    hdiutil create \
        -attach     \
        -size       "${SIZE_KB}k" \
        -type       UDRW \
        -layout     NONE \
        -fs         HFS+ \
        -volname    "$IMG" \
        "$IMG work"
    ```
    This created `OldSystem HD work.dmg`, which is the temporary disk image. It also mounted that image as `/Volumes/OldSystem HD Work`.

* Save the "mount point" of the work disk to a variable.
    ```
    MPT="/Volumes/OldSystem HD Work"
    ```

At this point, the temporary disk image is ready to have files copied into it.


### Copy the Files

* Copy the files from the Time Machine backup, into the temporary disk.
    ```
    sudo rsync -av "$SRC/" "$MPT/"
    ```

* Make sure any data which is *buffered* for the temporary disk image, is *written* to the image.
    ```
    sync
    ```

* Eject the temporary disk.
    ```
    hdiutil eject "$MPT"
    ```

At this point, `OldSystem HD Work.dmg` is finished. It is a read-write image, which means if you were to double-click the DMG file to mount it, you would be able to add, change, or remove files.


### Convert the Image

This step will convert the temporary image to a read-only image.

The basic command is this:

```
hdiutil convert \
    -format UDRO \
    -o      "$DST.dmg" \
    "$IMG work.dmg"
```

Depending on your needs, you may want to modify this command.

* To make a *compressed* read-only image, change `UDRO` to `UDZO`.

    This will result in a disk image which is *somewhat* smaller - how *much* smaller will depend on the files within the image. For the backup which made me *need* this process, the original Time Machine backup was about 245G, and the compress backup was 224G.

* To make an *encrypted* read-only image, add `-encryption AES-256` to the command.

    If you do this, the command will prompt you for a passphrase for the encryption. (There is no option at this point to store the passphrase in your Keyring. If you need to do this, you'll be able to do it below. Just don't forget the passphrase between now and then.) &#x1F914;

In my case, the actual command I ended up running (for a compressed *and* encrypted image) was ...

```
hdiutil convert \
    -format     UDZO \
    -encryption AES-256 \
    -o          "$DST.dmg" \
    "$IMG work.dmg"
```

### Testing

At this point the final image should be done. You should test it:

* Double-click the DMG file to mount it.

    If the image is encrypted, you will be asked for the passphrase.

    If you wanted to save the passphrase in your Keyring, this dialog will have a checkbox to let you do that.

* Make sure the mounted image is read-only.

    If you're looking at it in a Finder window, you should see this in the status bar:

    ![finder-ro](../images/finder-ro.png)

    Obviously, you should not be able to add, remove, or change any files.

* Eject the mounted disk.

### Cleanup

Once you've tested the final disk image, you can ...

* Delete the temporary disk image.
* Re-format the external Time Machine disk.
* Re-format the machine that the Time Machine backup was taken from (or in my case, replace its hard drive with an SSD).


## If You're Curious

I replaced the now-dead 500 GB spinning disk with a 512 GB SATA SSD that I had laying around, and used Apple's [Internet Recovery](https://support.apple.com/guide/mac-help/use-macos-recovery-on-an-intel-based-mac-mchl338cf9a8/15.0/mac/15.0) mechanism to install the latest macOS.

> Short version: I powered the machine on, and while the chime was playing, I pressed &#x2325;&#x2318;R and held it down until the "spinning globe" graphic appeared. This starts the Internet Recovery process and installs the latest macOS version which is compatible with the hardware.

The machine is back to a "working" state again, in that it hasn't crashed in over a week.

My next step is going to be installing Linux on it. &#x1F60E;

# Battery Calibration

When you put a new set of batteries into the uConsole, the power controller needs to "learn" the capacity of the new batteries. This process is known as "calibration". Until you calibrate the power controller, it won't know the real capacity of your batteries, and may report 65% when they're empty, or (as mine were when I started writing this page) 34% when they've been charging overnight and are presumably full.

I've seen several web pages, mostly on the [Clockwork Pi forums](https://forum.clockworkpi.com/), which tell how to do this. Every set of directions is either a copy of the same three sentences, or a *reference* to those three sentences.

It seems to me that some details are missing, so I'm writing this page to try and provide directions which are (1) more complete, and (2) more detailed. A big part of this is because I'm currently trying to do the calibration process and seeing some really weird results.

## My Experience So Far

A year ago I bought a set of 18650 batteries with a stated capacity of 5000 mAh, to use with a different device. I didn't notice anything wrong with them at the time, but I also had never used 18650's before so I didn't really have a good idea of what to expect.

Using the batteries I had ordered a year ago ...

* I left the uConsole plugged in and running overnight, with a tester between the cable and the uConsole to show how much power was being transferred. When I started, the power cable was supplying 9W, presumably to run the system *and* charge the batteries.

* In the morning it showed the battery level at 68%, and the power cable was supplying 4W.

* I ran the command to start the calibration process, unplugged the power cable, and ran a command to "exercise" the CPU (computing SHA256 checksums of 1GB blocks of data from `/dev/urandom`).

* About 2h30m later, the system died.

* I plugged the power cable back in to charge the batteries. The tester on the power cable showed that it was supplying 9W.

* After about two hours this dropped from 7W to 3W, then over the next half hour it gradually drifted down to zero. This tells me that the power controller stopped charging the batteries, *presumably* because the batteries were full.

* When I powered the system back on, the power controller reported the batteries were only 43% full ... and with the power cable connected and supplying 4W, the reported battery level drifted DOWN to 25% over half an hour, and is now sitting at a steady 25%.

* I then unplugged the cable and let the uConsole run from just the batteries. It died in about 1h45m.

### Fake Batteries

While researching this page, I came across several pages which explained that, with the battery chemistries being used today, 18650 batteries *cannot* hold more than about 3600 mAh each. This means that the batteries I was using, did not have the capacity they claimed to have. Two of these pages also recommended buying genuine Panasonic or Samsung batteries.

Back on Amazon, I found a listing for "Authentic Samsung" batteries. I took the chance and ordered these, along with a charger with a capacity tester.

* [Authentic Samsung30Q, 3.7V Flat Top Real 3000mAh 18650 Battery Rechargeable 30Q (4 Pack)](https://www.amazon.com/dp/B0BNLPWKXR)
* [IMREN 18650 Capacity Tester,18650 Battery Charger with Discharge & Testing Function, 21700 Battery Charger with LCD Screen Display Capacity Suit for 18650 21700 20700 1.2V Ni-MH/Ni-CD LiFePO4 Battery](https://www.amazon.com/dp/B0C1JN4S76)

The capacity tester showed all four of the new batteries having 2890-2960 mAh each, and two of the older batteries I *had* been using, having 1380 and 1400 mAh (I stopped testing and threw all six of them out, not worth wasting the time to prove that junk is junk).

I've been using the new batteries for about a week, they last over four hours in the uConsole.


## Procedure

To calibrate the power controller for a new set of batteries ...

* If you have a power tester (see [below](#power-testers)), plug it in between the power cable and the uConsole so you can monitor how much power the is being consumed, rather than having to rely only on the incorrect information from the uConsole's charging circuitry. (After all, the whole *point* of calibrating the power controller is to be able to trust the information it provides.)

* If the uConsole is configured with any "auto shutdown" or "battery saver" featires, disable them. We're going to be deliberately running the batteries down to empty, which means we want the machine to *not* shut down by itself.

* Plug in the charging cable and wait until the batteries are full.

    **If you're using a power tester**, make sure it's showing how much power (watts) the uConsole is consuming. If it's showing volts and amps, you can multiply the values to get watts (i.e. 1.8A at 5V => 9W).

    **You can watch the state of the battery** using `upower`, which is normally included with the Raspberry Pi images.

    * Run `upower -e` to list all power-related devices. The devices will have names that look like `/org/freedesktop/Upower/devices/...`, the internal battery controller will have a name containing `apx20x_battery`.

    * Run `upower -i DEVICE` to see the properties of that device.

    ```
    BAT=$( upower -e | grep 'apx20x_battery' )
    watch -n5 "upower -i $BAT | egrep '(state|percentage):'"
    ```

    You can leave the `watch` command running in a terminal window while performing the steps below, this will run the command over and over every five seconds so you can watch the numbers as they change.

    **When the batteries were full**, or at least when I *thought* the batteries were full, I noticed the following:

    * In the `watch ... upower -i` output, the `state` value started changing between `charging` and `discharging`.
    * On the power meter, the usage dropped from 9W to 2W.

* Tell the power controller to start the calibration process.  In a terminal window ...
    ```
    echo 1 | sudo tee /sys/class/power_supply/axp20x-battery/calibrate
    ```

* Unplug the power cable, so the uConsole is running on batteries.

* Let the unit run until the battery dies. This can take a while.

    If you'd rather not wait so long, you can do things on the system to increase it's power consumption. On my uConsole, I ran the following command in a terminal window to keep the CPU busy:

    ```
    while true ; do dd status=none bs=1G count=1 if=/dev/urandom | sha256sum ; done | cat -n
    ```

    This command makes the kernel *generate* 1 GB of random numbers (reading from `/dev/urandom` generates random bytes), calculates the SHA256 checksum of those numbers, and prints the result, over and over until the system dies. (The `cat -n` at the end puts a count in front of each checksum, in case you're curious how many GB of random data have been processed.)


* When the uConsole dies, plug the power cable in, but do not power it on.

* Wait until the batteries are full. If you're using a power tester on the wire, you'll see the power consumption drop to zero when this happens. If not, all I can suggest is to let the unit charge overnight.

* When you power the unit on, it should have an accurate picture of the batteries' true capacity, and the percentages should be accurate.

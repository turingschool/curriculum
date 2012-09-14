---
layout: page
title: Startup & Monitoring
---

## Startup & Monitoring

### Linux `init.d`

* Why do you need it? Servers restart!
* Run Levels
  * 0 System Halt
  * 1 Single user / "Safe Mode"
  * 2 Multi-user mode (Normal)
  * 3-5 Same as 2
  * 6 System Reboot
* Automatically start a program and keep it running
* Different approaches on each distribution

### God

* Easily configured Ruby process monitor
* Advantages over `init.d`
  * As a Ruby dev, easier to manipulate
  * More active monitoring/intervention (CPU, memory, etc)

### Recommended Setup

* Linux system boots
* `init.d` starts God
* God starts database(s), web server(s), ruby server(s), worker(s)

#### Workshop Time

* Install God
* Build a `init.d` script to manipulate God
* Make the script executable with `chmod +x god`
* Add it to the startup scripts with `update-rc.d god defaults`
* Restart your server and verify God is started
* Write a God config to start your other tools
* Restart God to pickup the new config with `service god restart`
* Verify that your servers all boot
* Restart the entire VM and ensure all your servers boot
* Knowingly stroke your neckbeard

#### References

* Ubuntu Startup / `init.d`: [https://help.ubuntu.com/community/UbuntuBootupHowto](https://help.ubuntu.com/community/UbuntuBootupHowto)
* God: http://godrb.com/
* Sample god `init.d` scripts:
  * [http://openmonkey.com/blog/2008/05/27/god-init-script-for-debian-ubuntu-systems/](http://openmonkey.com/blog/2008/05/27/god-init-script-for-debian-ubuntu-systems/)
  * [https://gist.github.com/1640121](https://gist.github.com/1640121)

# rpico-dev

Development with Raspberry Pi Pico 2

## Documents

[Raspberry Pi Documentation - Microcontrollers](https://www.raspberrypi.com/documentation/microcontrollers/?version=5A09D5312E22)

### Microcontrollers

- [Pico-series Microcontrollers - Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/microcontrollers/pico-series.html#pico-2-family)

### RP2350

- [Silicon - Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/microcontrollers/silicon.html#rp2350)
- [RP2350 Datasheet](https://www.raspberrypi.com/documentation/microcontrollers/silicon.html#documentation:~:text=RP2350-,RP2350%20Datasheet,-A%20microcontroller%20by)
- [Hardware design with RP2350](https://datasheets.raspberrypi.com/rp2350/hardware-design-with-rp2350.pdf)

## Connection to the board

Apply and activate udev rules as follows:

```bash
$ sudo vi /etc/udev/rules.d/60-rpico.rules
$ cat /etc/udev/rules.d/60-rpico.rules
# Raspberry Pi Debug Probe
SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="000c", \
    MODE="0666"

# Raspberry Pi Pico 2 (RP2350)
SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="000f", \
    MODE="0666"

# Update configuration
$ sudo udevadm conrol --reload
$ sudo udevadm trigger
```

## Working with WSL2

### Windows

`usbpid-win` is required to connect USB devices from WSL2.

```terminal
> winget install usbipd-win
```

Attach USB devices to WSL2 with following commands 
(`bind` and `attach` must be executed with administrator privilege).

```terminal
# Confirm BUSID
> usbipd list

# Bind a device
> usbipd bind -b <BUSID>

# Attach the device to WSL
> usbipd attach -b <BUSID> --wsl
```

### WSL2

To use `udev`, WSL2 needs to be working with `systemd`.
Configuration is:

```terminal
$ cat /etc/wsl.conf
[boot]
systemd=true
```

### References

- [RaspberryPipicoW】WSL2から操作するラズパイピコをC++で。セットアップ編 #IoT - Qiita](https://qiita.com/oni525/items/f50381d2140e441321c3#wsl%E3%81%AB%E3%83%A9%E3%82%BA%E3%83%91%E3%82%A4%E3%83%94%E3%82%B3%E3%82%92%E8%AA%8D%E8%AD%98%E3%81%95%E3%81%9B%E3%82%8B)
- [devcontainerによるCortexデバッグ環境構築（②usbipdによる方法） #VSCode - Qiita](https://qiita.com/liveinvalley/items/ed095650de93e40cc630)

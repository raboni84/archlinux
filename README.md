# Arch Linux Bootstrap

[![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa] ![project status][status-shield]

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[cc-by-nc-sa]: LICENSE
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-informational.svg
[status-shield]: https://img.shields.io/badge/status-active%20development-green

# WARNING

Some of the scripts in this project **will** destroy all data on the selected disk. So be careful! **I will not take any responsibility for any of your lost files!**

# DISCLAIMER

As I will just ignorantly enforce my security standards upon you browsing through this repository, you have to think on your own before blindly installing any kind of software or simply trust any scripts and programs. Look into the scripts yourself. Will they fit your needs? Do they have some undesired dependencies? You have to understand yourself what they do! I for myself only fully trust software that I either have

  - written myself, or
  - understood the source code by analyzing it myself.

Everything else needs to be used by many people in the wild to gain some level of trust or has to be of a known good source, from which the latter **I am not to you**. So please be careful.

# Installation Process

After the long preamble: how to install everything? I will assume you want to try everything out first before going the steps to install everything onto your production machine. (**NO!!!**)

First you need to install packer and virtualbox. I assume you use Archlinux for that. For the other distros you need to adapt these following steps.

```bash
sudo pacman -S packer virtualbox virtualbox-host-dkms
```

After that you simply have to start the pipeline script, which will download the newest archiso image by itself.

```bash
chmod +x pipeline.sh
./pipeline.sh
```

After the bootstrap step, the installation disk will have the following layout:

```bash
${device} [gpt]
├─/boot/EFI    fat32  ╟─     4MiB ─   132MiB ─╢
├─grub                ╟─   132MiB ─   134MiB ─╢
├─/            ext4   ╟─   136MiB ─ 24712MiB ─╢
└─lvm (luks)          ╟─ 24712MiB ─    -4MiB ─╢
  ├─swap       swap      0MiB ─ ${swapsize}MiB
  └─/data      ext4      ${swapsize}MiB ─ -0MiB
    ├─home     /home
    ├─var      /var
    ├─root     /root
    └─srv      /srv
```

If you haven't altered anything the default password for `root` will be `toor` and an account named `user` with the password `resu` will be created. As the i3 window manager won't be as easy to control like for example a XFCE, the first steps you can take are `Super`+`Enter`, which will open a terminal or `Super`+`Shift`+`Enter`, which will be your startmenu replacement. Everything else can be looked up inside `Super`+`Plus`, which will bring up notepadqq with a keyboard layout. I mapped the `Menu` key to the right `Super` key missing on todays keyboards to execute the same commands for more comfortable hand gestures depending on the given keyboard. (The `Super` key is [here](https://en.wikipedia.org/wiki/Windows_key), the `Menu` key [here](https://en.wikipedia.org/wiki/Menu_key))

If you have provided a password for the data partition, everything inside the LVM container will be placed inside a LUKS one that encrypts all the user files with a industry standard hardware accelerable algorith. In the root partition mainly the `/etc` and `/usr` files will be left behind from this, as of `/etc` is needed for `/etc/fstab` and `/etc/crontab` to be accessible all the time and `/usr` will contain all the main program files. Even if `/etc/passwd` and `/etc/shadow` are not encrypted and can easily be brute forced, the potential future forensical analyst will not have your LUKS password, so keep everything inside your protected space.

That's all for now. Have fun with it. --raboni84

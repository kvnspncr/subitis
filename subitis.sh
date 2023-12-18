#!/bin/bash
 ###############
# S U B I T I S #
 ###############
#emergencry utility for GNU/Linux distribution
#providing secure data deletion and managing of encrypted block devices
#written by kevin



#declaring iso mirrors so they can be updated easily
mintiso='https://mirrors.advancedhosters.com/linuxmint/isos/stable/21.2/linuxmint-21.2-xfce-64bit.iso'
archiso='https://mirror.adectra.com/archlinux/iso/2023.07.01/archlinux-2023.07.01-x86_64.iso'
#user auth
user=$('whoami')
if [ $user == 'root' ]
then
  echo 'Starting...'
else
  echo 'You need to run as root!' && exit
fi
clear
#menu logic loop
while true; do
  cat << "EOF"
                __         _   _    _
               [  |       (_) / |_ (_)
 .--.  __   _   | |.--.   __ `| |-'__   .--.
( (`\][  | | |  | '/'`\ \[  | | | [  | ( (`\]
 `'.'. | \_/ |, |  \__/ | | | | |, | |  `'.'.
[\__) )'.__.'_/[__;.__.' [___]\__/[___][\__) )
EOF
    echo "*=======================================*"
    echo "                 SHELL"
    echo "*=======================================*"

    read -p "subitis> " subitis

    case "$subitis" in


    exit)
      echo "Quitting..." && exit
      ;;
    clear)
      clear
      ;;
      shredblock)
  echo 'Avilable block devices (do not shred sda)' && lsblk
  read -p "Choose device to shred (format /dev/block): " block
  echo 'Shredding $block in 30 seconds, this will completely destroy all data with no option to recover. CTRL+C to abort!' && sleep 30
  shred $block && echo 'Done shredding $block'
  ;;


help)
    echo "*=======================================*"
    echo "oswitch -- Download and burn ISO to USB"
    echo "*=======================================*"
    echo "mozillapurge -- Destroy .mozilla folder"
    echo "*=======================================*"
    echo "homepurge -- Destroy home folder"
    echo "*=======================================*"
    echo "managecrypt -- Open or close encrypted block"
    echo "*=======================================*"
    echo "blockcrypt -- Encrypt block device"
    echo "*=======================================*"
    echo "macmanage -- Change or revert mac address"
    echo "*=======================================*"
    exit
    ;;


oswitch)
  echo 'Choose ISO'
  echo '=========='
  echo '1.) Linux Mint (2.8GiB)'
  echo '2.) Arch Linux (813MiB)'
  read -p "Choice: " oschoice
  if [ $oschoice == '1' ]
  then
    curl $mintiso -o mint.iso && echo 'Finished downloading Linux Mint...'
    lsblk && read -p "Select the block device to burn Linux Mint to : " osblock
    echo 'Burning $(pwd)/mint.iso to $osblock (might take some time)' && mkfs.ext4 $osblock && echo 'Written changes to $osblock2' && echo 'Burning Arch Linux to $osblock2 be patient' dd if=$(pwd)/mint.iso of=$osblock bs=4M status=progress && echo 'Finished burning iso to $osblock'
    echo 'Rebooting in 12 seconds CTRL+C to cancel...' && sleep 12 && reboot
  elif [ $oschoice == '2' ]; then
    echo 'Downloading Arch Linux iso, be patient this might take some time..' && curl $archiso -o arch.iso && echo 'Finished downloading Arch Linux...'
    echo 'Select the block device to burn Arch Linux to : ' && lsblk && read osblock2
    echo 'Burning $(pwd)/arch.iso to $osblock2 (might take some time)' && mkfs.ext4 $osblock2 && dd if=$(pwd)/arch.iso of=$osblock2 bs=4M status=progress && echo 'Finished burning iso to
    '$osblock2' '
    echo "Rebooting in 12 seconds CTRL+C to abort..." && sleep 12 && reboot
  else
    echo "Error: invalid input!" && exit
   fi
   ;;
 mozillapurge)
  read -p "Choose your home folder (must be full path): " home
  if [ -e "$home" ]; then
  echo 'Deleting and shredding $home/.mozilla in 30 seconds, CTRL+C to abort!' && sleep 30
  cd $home/.mozilla && shred * && cd .. && rm -rf .mozilla && echo 'Done destroying $home/.mozilla' && exit
  else echo "Error: invalid path!" && exit
  fi
  ;;
homepurge)
  read -p "Choose your home folder (must be full path): " homedest
  if [ -e $home ]; then
  echo 'Deleting $homedest in 30 seconds, CTRL+C to abort' && sleep 30
  rm -rf $homedest && echo 'Deleted $home' && exit
  else echo "Error: invalid path!" && exit
  fi
  ;;

managecrypt)
  read -p "Open or close? : " openclose
  lsblk && read -p "Choose block device : " blockcrypt
  if [ -e "$blockcrypt" ]; then
    read -p "Label of the encrypted parition: " encryptlabel
  else echo "Error: invalid block device!" && exit
  fi
    read -p "Folder to mount /dev/mapper/'$encryptlabel' to: " homecrypt
    if [ -e "$homecrypt" ]; then
    if [ "$openclose" == "open" ]; then
    cryptsetup luksOpen $blockcrypt $encryptlabel && mount /dev/mapper/$encryptlabel $homecrypt && echo 'Device '$blockcrypt' opened and mounted to '$homecrypt' ' && exit
  elif [ "$openclose" == "close" ]; then
    umount /dev/mapper/$encryptlabel && cryptsetup luksClose $encryptlabel && echo 'Device '$blockcrypt' closed' && exit
  else echo "Error: invalid input!" && exit
fi
else echo "Error: invalid path!" && exit
    fi
  ;;
blockcrypt)
  lsblk && read -p "Select block device to encrypt: " blckencrypt
  if [ -e "$blckencrypt" ]; then
  echo 'Making LUKS parition on '$blckencrypt' ' && cryptsetup luksFormat $blckencrypt
  read -p "Select a LUKS label (e.g encryptedusb): " usblabel
  echo 'Opening '$blckencrypt'...' && cryptsetup luksOpen $blckencrypt $usblabel
  echo 'Making ext4 filesystem on '/dev/mapper/$usblabel'...' && mkfs.ext4 /dev/mapper/$usblabel -L $usblabel && echo 'Encrypted '$blckencrypt' successfully' && exit
else echo "Error: invalid block device!" && exit
  fi
  ;;
macmanage)
    read -p "Change or revert?" changerevert
    if [ "$changerevert" == "change" ]; then
        ip addr && read -p "Select network interface: " netinf
        if ! ip link show "$netinf" >/dev/null 2>&1; then
            echo "Error: invalid network interface!" && exit
        else
            echo 'Changing MAC address on '$netinf'...' && ip link set $netinf down && macchanger -r $netinf && ip link set $netinf up
            echo 'Successfully changed MAC address on '$netinf' ' && exit
        fi
    elif [ "$changerevert" == "revert" ]; then
        ip addr && read -p "Select network interface: " netinf2
        echo 'Reverting MAC address on '$netinf2'...' && ip link set $netinf2 down && macchanger -p $netinf2 && ip link set $netinf2 up
        echo 'Successfully reverted MAC address on '$netinf2' ' && exit
    else
        echo "Error: invalid input!" && exit
    fi
    ;;

  *)
    echo "Error: $subitis command not found!" && sleep 2 && clear
    ;;
    esac
done

#!/bin/bash
 ###############
# S U B I T I S #
 ###############

 #REQUIRED UTILITIES 
 #shred 
 #curl 
 #luks 
 #macchanger

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
#emergency shell code
echo '*=================*'
echo '       subitis        '
echo '*=================*'
echo '1.) Shred block device (slow)'
echo '2.) Run oswitcher (experimental)'
echo '3.) Delete .mozilla'
echo '4.) Purge home folder (might break things)'
echo '5.) Open/Close encrypted block device'
echo '6.) Encrypt a block device'
echo '7.) Change/revert MAC address'
read choice
if [ $choice == '1' ]
then
  echo 'Avilable block devices (do not shred sda)' && lsblk
  echo 'Choose device to shred (format /dev/block): ' && read block
  echo 'Shredding $block in 30 seconds, this will completely destroy all data with no option to recover. CTRL+C to abort!' && sleep 30
  shred $block && echo 'Done shredding $block'
elif [ $choice == '2' ]
then
  echo 'Choose ISO'
  echo '=========='
  echo '1.) Linux Mint (2.8GiB)'
  echo '2.) Arch Linux (813MiB)'
  read oschoice
  if [ $oschoice == '1' ]
  then
    curl $mintiso -o mint.iso && echo 'Finished downloading Linux Mint...'
    echo 'Select the block device to burn Linux Mint to : ' && lsblk && read osblock
    echo 'Burning $(pwd)/mint.iso to $osblock (might take some time)' && mkfs.ext4 $osblock && echo 'Written changes to $osblock2' && echo 'Burning Arch Linux to $osblock2 be patient' dd if=$(pwd)/mint.iso of=$osblock bs=4M status=progress && echo 'Finished burning iso to $osblock'
    echo 'Rebooting in 12 seconds CTRL+C to cancel...' && sleep 12 && reboot
  else
    echo 'Downloading Arch Linux iso, be patient this might take some time..' && curl $archiso -o arch.iso && echo 'Finished downloading Arch Linux...'
    echo 'Select the block device to burn Arch Linux to : ' && lsblk && read osblock2
    echo 'Burning $(pwd)/arch.iso to $osblock2 (might take some time)' && mkfs.ext4 $osblock2 && dd if=$(pwd)/arch.iso of=$osblock2 bs=4M status=progress && echo 'Finished burning iso to
    '$osblock2' ' && exit
   fi
elif [ $choice == '3' ]
then
  echo 'Choose your home folder (must be full path): ' && read home
  echo 'Deleting and shredding $home/.mozilla in 30 seconds, CTRL+C to abort!' && sleep 30
  cd $home/.mozilla && shred * && cd .. && rm -rf .mozilla && echo 'Done destroying $home/.mozilla' && exit
elif [ $choice == '4' ]; then
  echo 'Choose your home folder (must be full path): ' && read homedest
  echo 'Deleting $homedest in 30 seconds, CTRL+C to abort' && sleep 30
  rm -rf $homedest && echo 'Deleted $home' && exit
elif [ $choice == '5' ]; then
  echo 'Open or close? : ' && read openclose
    echo 'Choose block device : ' && lsblk && read blockcrypt
    echo 'Label of the encrypted parition: ' && read encryptlabel
    echo 'Folder to mount /dev/mapper/'$encryptlabel' to: ' && read homecrypt
    if [ "$openclose" == "open" ]; then
    cryptsetup luksOpen $blockcrypt $encryptlabel && mount /dev/mapper/$encryptlabel $homecrypt && echo 'Device '$blockcrypt' opened and mounted to '$homecrypt' ' && exit
  else
    umount /dev/mapper/$encryptlabel && cryptsetup luksClose $encryptlabel && echo 'Device '$blockcrypt' closed' && exit
  fi
elif [ $choice == '6' ]; then
  echo 'Select block device to encrypt: ' && lsblk && read blckencrypt
  echo 'Making LUKS parition on '$blckencrypt' ' && cryptsetup luksFormat $blckencrypt
  echo 'Select a LUKS label (e.g encryptedusb): ' && read usblabel
  echo 'Opening '$blckencrypt'...' && cryptsetup luksOpen $blckencrypt $usblabel
  echo 'Making ext4 filesystem on '/dev/mapper/$usblabel'...' && mkfs.ext4 /dev/mapper/$usblabel -L $usblabel && echo 'Encrypted '$blckencrypt' successfully' && exit
else
    echo 'Change or revert?' && read changerevert
    if [ "$changerevert" == "change" ]
    then
      echo 'Select network interface: ' && ip addr && read netinf
      echo 'Changing MAC address on '$netinf'...' && ip link set $netinf down && macchanger -r $netinf && ip link set $netinf up
      echo 'Successfully changed MAC address on '$netinf' '
    else
      echo 'Select network interface: ' && ip addr && read netinf2
      echo 'Reverting MAC address on '$netinf2'...' && ip link set $netinf2 down && macchanger -p $netinf2 && ip link set $netinf2 up
      echo 'Successfully reverted MAC address on '$netinf2' '
    fi
  fi

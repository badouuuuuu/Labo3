#!/bin/bash
### Initialisation

logFile="createvm.log"
configFile="machines.csv"
formatedDate=$(date +%d-%m-%Y_%H:%M)
vmFilePath="/home/tux/VirtualBox VMs"
isoFilePath="/home/tux/Desktop/Labo3-Automatisation/ISOs"

# function
function splitline
{
  IFS='|' read -ra params <<< $line
  vmName=${params[0]}
  vmGroup=${params[1]}
  vmHDD=${params[2]}
  vmRam=${params[3]}
  vmVram=${params[4]}
  vmIso=${params[5]}
  cards[1]=${params[6]}
  cards[2]=${params[7]}
  cards[3]=${params[8]}
  cards[4]=${params[9]}

  for nombre in $(seq 1 4)
  do
    numInt[$nombre]=$(echo ${cards[$nombre]} | cut -d: -f1)
    typeInt[$nombre]=$(echo ${cards[$nombre]} | cut -d: -f2)
    valInt[$nombre]=$(echo ${cards[$nombre]} | cut -d: -f3)
    macInt[$nombre]=$(echo ${cards[$nombre]} | cut -d: -f4)
    case ${typeInt[$nombre]} in
      bridged)
        netInterface[$nombre]="${typeInt[$nombre]} --bridgeadapter$nombre ${valInt[$nombre]} --macaddress$nombre ${macInt[$nombre]}";;
      intnet)if ask "Do you want to start all yours Virtual Machines now?" Y; then
    echo "Yes"
    VBoxManage startvm 'dns' --defaultfrontend headless
else
    ask "Do you want to start a specific Virtual Machines now?" Y;
    vboxmanage list vms
    ask "Type the vm name or uuid" ;
fi
        netInterface[$nombre]="${typeInt[$nombre]} --intnet$nombre ${valInt[$nombre]} --macaddress$nombre ${macInt[$nombre]}";;
      nat)
        netInterface[$nombre]="${valInt[$nombre]} --macaddress$nombre ${macInt[$nombre]}";;
      none)
        netInterface[$nombre]="${valInt[$nombre]}"
    esac
  done
}


function createVm
{

  VBoxManage createvm --name $vmName --groups "/$vmGroup" --register 
  VBoxManage createmedium --filename "$vmFilePath/$vmGroup/$vmName/$vmName.vmdk" --format VMDK --size $vmHDD
  VBoxManage storagectl $vmName --name SATA --add sata --controller IntelAhci
  VBoxManage storageattach $vmName --storagectl SATA --port 0 --device 0 --type hdd --medium "$vmFilePath/$vmGroup/$vmName/$vmName.vmdk"
  VBoxManage storagectl $vmName --name IDE --add IDE
  VBoxManage storageattach $vmName --storagectl IDE --port 0 --device 0 --type dvddrive --medium "$isoFilePath/$vmIso"
  VBoxManage modifyvm $vmName --memory $vmRam --vram $vmVram
  VBoxManage modifyvm $vmName --graphicscontroller vmsvga
  VBoxManage modifyvm $vmName --ioapic on
  VBoxManage modifyvm $vmName --boot1 dvd --boot2 disk --boot3 none --boot4 none
  VBoxManage modifyvm $vmName --cpus 1
  VBoxManage modifyvm $vmName --audio none
  VBoxManage modifyvm $vmName --usb off
  VBoxManage modifyvm $vmName --usbehci off
  VBoxManage modifyvm $vmName --usbxhci off
  VBoxManage modifyvm $vmName --nic1 ${netInterface[1]} --nic2 ${netInterface[2]}  --nic3 ${netInterface[3]} --nic4 ${netInterface[4]}
  message="$formatedDate - Vm $vmName has been created in $vmGroup group in folder $vmFilePath, it's $vmType type"
  #VBoxManage startvm $vmName --type gui
  echo "debug : VBoxManage modifyvm $vmName --nic1 ${netInterface[1]} --nic2 ${netInterface[2]}  --nic3 ${netInterface[3]} --nic4 ${netInterface[4]}"
}



# main code
clear
while read line
do
  splitline
  createVm

  echo -e "\n" && echo $message | tee -a $logFile && echo -e "\n"
  echo line
done < $configFile


## A AJOUTER startvm headless pour démarrage, demander si nous devons démarrer toutes les vms, ou si il veut démarrer une vm précise


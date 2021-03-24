# Labo3
## Ajouter les fichier ISO dans le dossier ISOs a la racine du répértoire.

Renommer les fichier isos : 
- linuxmint20.iso
- debian10.iso

```sh
git clone https://github.com/badouuuuuu/Labo3.git
cd Labo3
chmod +x createVM.sh
./createVM.sh
```
# Création Kickstart CentOs7

Récupération de l'ISO CentOs 7 : https://mirror.unix-solutions.be/centos/7.9.2009/isos/x86_64/

1. Création d'une VM manuellement sous VirtualBox avec l'iso CentOs précédement téléchargé
```sh
apt update -y
apt upgrade -y 
yum install nano genisoimage
reboot now
```

2. Télécharger Anaconda Linux 64 Bits(x86)
```sh
wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
```

3. Installation d'Anaconda :
```sh
chmod +x Anaconda3-2020.11-Linux-x86_64.sh
- ./Anaconda3-2020.11-Linux-x86_64.sh
```

4. Retourner dans VirtualBox monter le lecteur Optique avec l'image CentOs précédement téléchargé et monter le fichier :
```sh
mount -o loop /dev/sr0 /mnt/
```

5. Créer un répératoire et y copier le contenu du fichier ISO monter au point 4 :
```sh
mkdir /root/centos-autoinstall/
cp -avRf /mnt/* /root/centos-autoinstall/
umount /mnt
```

6. Copier le fichier kickstart autogénéré lors de l'installation dans votre nouveau répératoire crée a l'étape précédente :
```sh
cp /root/anaconda-ks.cfg /root/centos-autoinstall/
nano /root/centos-autoinstall/anaconda-ks.cfg
```
 - Modifier la ligne
   ```sh
   network --hostname=localhost.localdomain
   ```
 - Remplacer par
   ```sh
   network --device=lo --hostname=localhost.localdomain
   ```

 - Modifier la ligne
   ```sh
   clearpart --none --initlabel
   ```
 - Remplacer par
   ```sh
   clearpart --drives=sda --all --initlabel
   ```

7. Ajouter une nouvelle entrée de menu au fichier de démarrage :
```sh
nano /root/centos-autoinstall/isolinux/isolinux.cfg
```
- Modifier :
timeout _600_ sur *100*
- Ajouter :
```sh
label kickstart menu label ^Kickstart Installation of CentOS 7 menu default kernel vmlinuz append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 inst.ks=hd:LABEL=CentOS\x207\x20x86_64:/anaconda-ks.cfg
```
- Supprimer "menu default" dans *Label Check* plus bas dans le fichier

8. Créer le fichier /root/CentOS-autoinstall.iso à partir du répertoire de travail

```sh
mkisofs -J -T -o ./ISOs/CentOS-autoinstall.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -R -m TRANS.TBL -graft-points -V "CentOS 7 x86_64" /root/centos-autoinstall/
```

9. Récuperer l'image via scp 
```sh
scp user@ip_de_la_machine:./ISOs/CentOs-autoinstall.iso "chemin local"
```

10. Créer une VM via Virtualbox afin de tester l'iso créer CentOs-autoinstall.iso et selectionner l'entrée "Kickstarter Auto install" lors du menu de boot
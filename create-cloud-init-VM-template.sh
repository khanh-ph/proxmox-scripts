#!/bin/sh
DOWNLOAD_BASE_URL=https://cloud-images.ubuntu.com/minimal/releases/focal/release
CLOUD_IMG_FILENAME=ubuntu-20.04-minimal-cloudimg-amd64.img
TMPL_ID=9000
TMPL_NAME=ubuntu-2004-cloudinit-minimal
PROXMOX_STORAGE=local-lvm

rm -f _${CLOUD_IMG_FILENAME}

if ! [ -f "$CLOUD_IMG_FILENAME" ]; then \
 wget $DOWNLOAD_BASE_URL/$CLOUD_IMG_FILENAME;
fi

sudo qm destroy $TMPL_ID --purge || true
sudo cp $CLOUD_IMG_FILENAME _${CLOUD_IMG_FILENAME}
sudo apt update -y && sudo apt install libguestfs-tools -y

# Install qemu-guest-agent
sudo virt-customize -a _${CLOUD_IMG_FILENAME} --run-command 'sudo apt update -y && sudo apt install qemu-guest-agent -y'
sudo virt-customize -a _${CLOUD_IMG_FILENAME} --run-command 'sudo systemctl start qemu-guest-agent'

# Reset the machine ID
sudo virt-customize -x -a _${CLOUD_IMG_FILENAME} --run-command 'sudo echo -n >/etc/machine-id'

# Configure default settings
sudo qm create $TMPL_ID --name $TMPL_NAME --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
sudo qm importdisk $TMPL_ID _${CLOUD_IMG_FILENAME} $PROXMOX_STORAGE
sudo qm set $TMPL_ID --scsihw virtio-scsi-single --scsi0 $PROXMOX_STORAGE:vm-$TMPL_ID-disk-0
sudo qm set $TMPL_ID --boot c --bootdisk scsi0
sudo qm set $TMPL_ID --ide2 $PROXMOX_STORAGE:cloudinit
sudo qm set $TMPL_ID --serial0 socket --vga serial0
sudo qm set $TMPL_ID --agent enabled=1,fstrim_cloned_disks=1

# Set the VM as a template
sudo qm template $TMPL_ID

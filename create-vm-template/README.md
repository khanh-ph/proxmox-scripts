# Build an Ubuntu (cloud-init) template on Proxmox VE

## Usage

1. Run the command on the Proxmox VE shell.
    ```bash
    bash -c "$(wget -qLO - https://raw.githubusercontent.com/khanh-ph/proxmox-scripts/master/create-vm-template/script.sh)"
    ```

1. Use this command to verify that the template has been created
    ```bash
    qm list | grep ubuntu
    ```

## Examples

1. Build an Ubuntu 22.04 template:
    ```bash
    bash -c "$(wget -qLO - https://raw.githubusercontent.com/khanh-ph/proxmox-scripts/master/create-vm-template/script.sh)"
    Enter Ubuntu version (default: 22.04): 
    Enter Proxmox Template ID (default: 9000): 
    Enter Proxmox Template Name (default: ubuntu-2204): 
        Available storages:
            0: local
            1: lvm-thin-nvme
            2: lvm-thin-ssd
            3: zfs-hdd
    Enter the index number of the storage to put the VM template into (default: 0): 1
    Performing cleanup...OK
    Installing libguestfs-tools...OK
    The image file exists in Proxmox ISO storage. Copying...OK
    Enabling CPU hotplug...OK
    Installing QEMU guest agent...OK
    Resetting the machine ID...OK
    Creating VM template...OK

    ```

1. Build an Ubuntu 24.04 template:
    ```bash
    bash -c "$(wget -qLO - https://raw.githubusercontent.com/khanh-ph/proxmox-scripts/master/create-vm-template/script.sh)"
    Enter Ubuntu version (default: 22.04): 24.04
    Enter Proxmox Template ID (default: 9000): 9001
    Enter Proxmox Template Name (default: ubuntu-2204): ubuntu-2404
        Available storages:
            0: local
            1: lvm-thin-nvme
            2: lvm-thin-ssd
            3: zfs-hdd
    Enter the index number of the storage to put the VM template into (default: 0): 1
    Performing cleanup...OK
    Installing libguestfs-tools...OK
    The image file does not exist in Proxmox ISO storage. Downloading...OK
    Copying the image to Proxmox ISO storage...OK
    Enabling CPU hotplug...OK
    Installing QEMU guest agent...OK
    Resetting the machine ID...OK
    Creating VM template...OK
    ```
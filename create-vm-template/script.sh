#!/bin/bash

set -euo pipefail

# Function to handle errors
error_handler() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo -e "\e[31mThe script exited with status ${exit_code}.\e[0m" 1>&2
        cleanup
        exit ${exit_code}
    fi
}

trap error_handler EXIT

# Function to run commands and capture stderr
run_cmd() {
    local cmd="$1"
    local stderr_file=$(mktemp)

    if ! eval "$cmd" > /dev/null 2>$stderr_file; then
        echo -e "\e[31mError\n Command '$cmd' failed with output:\e[0m" 1>&2
        cat $stderr_file | awk '{print " \033[31m" $0 "\033[0m"}' 1>&2
        rm -f $stderr_file
        exit 1
    fi

    rm -f $stderr_file
}

# Function to print OK message
print_ok () {
    echo -e "\e[32mOK\e[0m"
}

# Default values
df_ubuntu_ver="24.04"
df_vm_tmpl_id="9000"
df_vm_tmpl_name="ubuntu-2404"

# Prompt for user input
read -p "Enter Ubuntu version (default: ${df_ubuntu_ver}): " ubuntu_ver
ubuntu_ver="${ubuntu_ver:-$df_ubuntu_ver}"

read -p "Enter Proxmox Template ID (default: ${df_vm_tmpl_id}): " vm_tmpl_id
vm_tmpl_id="${vm_tmpl_id:-$df_vm_tmpl_id}"

read -p "Enter Proxmox Template Name (default: ${df_vm_tmpl_name}): " vm_tmpl_name
vm_tmpl_name="${vm_tmpl_name:-$df_vm_tmpl_name}"

# Get list of storages
storages=($(pvesm status | awk 'NR>1 {print $1}'))
echo " Available storages:"
for i in "${!storages[@]}"; do
    echo "  $i: ${storages[$i]}"
done

# Prompt for user input for storage
read -p "Enter the index number of the storage to put the VM template into (default: 0): " storage_index
storage_index="${storage_index:-0}"
vm_disk_storage="${storages[$storage_index]}"

# Construct the Ubuntu image URL based on the version input
ubuntu_img_url="https://cloud-images.ubuntu.com/releases/${ubuntu_ver}/release/ubuntu-${ubuntu_ver}-server-cloudimg-amd64.img"
ubuntu_img_filename=$(basename $ubuntu_img_url)
ubuntu_img_base_url=$(dirname $ubuntu_img_url)
df_iso_path="/var/lib/vz/template/iso"
script_tmp_path=/tmp/proxmox-scripts

install_lib () {
    local name="$1"
    echo -n "Installing $name..."
    run_cmd "apt-get install -y $name"
    print_ok
}

init () {
    cleanup
    install_lib "libguestfs-tools"
    mkdir -p $script_tmp_path
    cd $script_tmp_path
}

get_image () {
    local existing_img="$df_iso_path/$ubuntu_img_filename"
    local img_sha256sum=$(curl -s $ubuntu_img_base_url/SHA256SUMS | grep $ubuntu_img_filename | awk '{print $1}')

    if [ -f "$existing_img" ] && [[ $(sha256sum $existing_img | awk '{print $1}') == $img_sha256sum ]]; then
        echo -n "The image file exists in Proxmox ISO storage. Copying..."
        run_cmd "cp $existing_img $ubuntu_img_filename"
        print_ok
    else
        echo -n "The image file does not exist in Proxmox ISO storage. Downloading..."
        run_cmd "wget $ubuntu_img_url -O $ubuntu_img_filename"
        print_ok

        echo -n "Copying the image to Proxmox ISO storage..."
        run_cmd "cp $ubuntu_img_filename $existing_img"
        print_ok
    fi
}

enable_cpu_hotplug () {
    echo -n "Enabling CPU hotplug..."
    run_cmd "virt-customize -a $ubuntu_img_filename --run-command 'echo \"SUBSYSTEM==\\\"cpu\\\", ACTION==\\\"add\\\", TEST==\\\"online\\\", ATTR{online}==\\\"0\\\", ATTR{online}=\\\"1\\\"\" > /lib/udev/rules.d/80-hotplug-cpu.rules'"
    print_ok
}

install_qemu_agent () {
    echo -n "Installing QEMU guest agent..."
    run_cmd "virt-customize -a $ubuntu_img_filename --run-command 'apt update -y && apt install qemu-guest-agent -y && systemctl start qemu-guest-agent'"
    print_ok
}

reset_machine_id () {
    echo -n "Resetting the machine ID..."
    run_cmd "virt-customize -x -a $ubuntu_img_filename --run-command 'echo -n >/etc/machine-id'"
    print_ok
}

create_vm_tmpl () {
    echo -n "Creating VM template..."
    run_cmd "qm destroy $vm_tmpl_id --purge || true"
    run_cmd "qm create $vm_tmpl_id --name $vm_tmpl_name --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0"
    run_cmd "qm set $vm_tmpl_id --scsihw virtio-scsi-single"
    run_cmd "qm set $vm_tmpl_id --virtio0 $vm_disk_storage:0,import-from=$script_tmp_path/$ubuntu_img_filename"
    run_cmd "qm set $vm_tmpl_id --boot c --bootdisk virtio0"
    run_cmd "qm set $vm_tmpl_id --ide2 $vm_disk_storage:cloudinit"
    run_cmd "qm set $vm_tmpl_id --serial0 socket --vga serial0"
    run_cmd "qm set $vm_tmpl_id --agent enabled=1,fstrim_cloned_disks=1"
    run_cmd "qm template $vm_tmpl_id"
    print_ok
}

cleanup () { 
    echo -n "Performing cleanup..."
    rm -rf $script_tmp_path 
    print_ok
}

# Main script execution
init
get_image
enable_cpu_hotplug
install_qemu_agent
reset_machine_id
create_vm_tmpl

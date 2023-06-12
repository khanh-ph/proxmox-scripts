# Build an Ubuntu 22.04 (cloud-init) template on Proxmox VE

## Usage

1. Run the command on the Proxmox VE shell.
    ```bash
    curl -s https://raw.githubusercontent.com/khanh-ph/proxmox-scripts/master/create-vm-template/script.sh | sudo bash
    ```

2. Use this command to verify that the template `ubuntu-2204` has been created
    ```bash
    qm list | grep ubuntu
    ```

## Configurations

```sh
# (Optional) ID of the VM template to be created. Default: 9000
export TMPL_ID=YOUR_PROXMOX_VM_TEMPLATE_ID

# (Optional) Name of the VM template to be created. Default: ubuntu-2204
export TMPL_NAME=YOUR_PROXMOX_VM_TEMPLATE_NAME

# (Optional) The Proxmox storage ID where the VM is stored. Default: auto detected
export PM_STORAGE=YOUR_PROXMOX_STORAGE_ID
```
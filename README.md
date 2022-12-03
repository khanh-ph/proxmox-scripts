# Proxmox Scripts

## Build an Ubuntu cloud-init template on Proxmox VE

### Usage

1. On your Proxmox server
    ```sh
    curl -s https://raw.githubusercontent.com/khanh-ph/proxmox-scripts/master/create-cloud-init-VM-template.sh | sudo bash
    ```

2. Verify that the template `ubuntu-2204` has been created
    ```sh
    qm list | grep ubuntu
    ```

### Options

If the default values do not work for you, there are options to configure before running again the script:

```sh
export TMPL_ID=PROXMOX_VM_TEMPLATE_ID
export TMPL_NAME=PROXMOX_VM_TEMPLATE_NAME
export PM_STORAGE=PROXMOX_STORAGE_ID
```
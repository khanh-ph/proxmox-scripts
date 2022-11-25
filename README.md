### Build your ubuntu cloud-init template
* On your Proxmox server
    ```
    curl -s https://raw.githubusercontent.com/khanh-ph/proxmox-scripts/master/create-cloud-init-VM-template.sh | sudo bash
    ```
* Verify that the template `ubuntu-2004-cloudinit-minimal` has been created
    ```
    sudo qm list | grep cloudinit
    ```
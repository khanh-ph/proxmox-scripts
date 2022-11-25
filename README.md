## Build your ubuntu cloud-init template
* Copy script `build_minimal.sh` over to your Proxmox server
* Jump into your Proxmox server and execute the script
    ```
    sudo ./build_minimal.sh
    ```
* Verify that the template `ubuntu-2004-cloudinit-minimal` has been created
    ```
    sudo qm list | grep cloudinit
    ```
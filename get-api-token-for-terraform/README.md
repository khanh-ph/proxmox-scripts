## Create a new Proxmox user for Terraform and get the API token

Before we get the API token, it is highly recommended to create a new user with sufficient privileges for the deployment rather than using the root account.

1. SSH to your Proxmox VE:

    ```sh
    $ ssh <proxmox_ve_server_ip>
    ```

2. Create a new role with needed privileges:

    ```sh
    $ pveum role add TerraformDeploy -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit"
    ```

3. Create a new user:

    ```sh
    $ pveum user add terraform-deploy@pve
    ```

4. Assign the new user to the role that we created above:

    ```sh
    $ pveum aclmod / -user terraform-deploy@pve -role TerraformDeploy
    ```

5. Generate a token for the new user:

    ```sh
    $ pveum user token add terraform-deploy@pve token1
    ```

This will show you a table with `full-tokenid` (your API token ID), `info` and `value` (your API token secret). Please save these pieces of data in a safe location for later use.
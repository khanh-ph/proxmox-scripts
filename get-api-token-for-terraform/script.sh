#!/bin/bash
roleid=TerraformDeploy
userid=terraform-deploy@pve
tokenid=token1

[ $(id -u) == 0 ] && apt-get update && apt-get install sudo -y || exit 1
sudo pveum role add $roleid -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit"
sudo pveum user add $userid
sudo pveum aclmod / -user $userid -role $roleid
sudo pveum user token add $userid $tokenid
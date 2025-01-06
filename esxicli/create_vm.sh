#!/bin/bash

# Parameters
VM_NAME=$1
CONFIG=$2

# Define VM configuration
case $CONFIG in
    "4C8G")
        CPU=4
        MEMORY=8192
        ;;
    "8C16G")
        CPU=8
        MEMORY=16384
        ;;
    "16C32G")
        CPU=16
        MEMORY=32768
        ;;
    *)
        echo "Invalid configuration option! Available options are: 4C8G, 8C16G, 16C32G"
        exit 1
        ;;
esac

# Create VM directory
mkdir /vmfs/volumes/datastore1/$VM_NAME

# Copy virtual disk
vmkfstools -i /vmfs/volumes/datastore1/rocky9-base/rocky9-base.vmdk /vmfs/volumes/datastore1/$VM_NAME/$VM_NAME.vmdk -d thin

# Copy configuration file
cp /vmfs/volumes/datastore1/rocky9-base/rocky9-base.vmx /vmfs/volumes/datastore1/$VM_NAME/$VM_NAME.vmx

# Modify VM configuration file
sed -i -e "s/rocky9-base/$VM_NAME/g" /vmfs/volumes/datastore1/$VM_NAME/$VM_NAME.vmx
sed -i -e "s/numvcpus = \".*\"/numvcpus = \"$CPU\"/" /vmfs/volumes/datastore1/$VM_NAME/$VM_NAME.vmx
sed -i -e "s/memSize = \".*\"/memSize = \"$MEMORY\"/" /vmfs/volumes/datastore1/$VM_NAME/$VM_NAME.vmx

# Register new VM
VM_ID=$(vim-cmd solo/registervm /vmfs/volumes/datastore1/$VM_NAME/$VM_NAME.vmx)

# Check VM power state
POWER_STATE=$(vim-cmd vmsvc/power.getstate $VM_ID | tail -n 1)
if [ "$POWER_STATE" == "Powered on" ]; then
    echo "VM is already powered on."
else
    # Power on VM
    vim-cmd vmsvc/power.on $VM_ID
fi

# Automatically answer questions
MESSAGE_INFO=$(vim-cmd vmsvc/message $VM_ID)
if [[ $MESSAGE_INFO == *"msg."* ]]; then
    MSG_ID=$(echo "$MESSAGE_INFO" | grep "Virtual machine message" | awk '{print $4}' | sed 's/://')
    echo "Pending Message ID: $MSG_ID"
    vim-cmd vmsvc/message $VM_ID $MSG_ID 2
    echo "Answered with default option 2 (I Copied It)."
else
    echo "No pending messages for VM $VM_ID."
fi



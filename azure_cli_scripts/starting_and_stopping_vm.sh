#!/bin/bash

# Variables
RESOURCE_GROUP="yourResourceGroupName"  # Replace with your resource group name
VM_NAME="yourVmName"                    # Replace with your VM name

# Function to start the VM
start_vm() {
    echo "Starting VM: $VM_NAME"
    az vm start --resource-group $RESOURCE_GROUP --name $VM_NAME
    echo "VM started."
}

# Function to stop the VM
stop_vm() {
    echo "Stopping VM: $VM_NAME"
    az vm deallocate --resource-group $RESOURCE_GROUP --name $VM_NAME
    echo "VM stopped."
}

# User input for action
echo "Do you want to start or stop the VM? (start/stop)"
read ACTION

if [ "$ACTION" == "start" ]; then
    start_vm
elif [ "$ACTION" == "stop" ]; then
    stop_vm
else
    echo "Invalid input. Please enter 'start' or 'stop'."
fi

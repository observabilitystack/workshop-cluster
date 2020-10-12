#!/bin/bash
echo "----------------------------------------------------"
df -ht ext4
echo "----------------------------------------------------"
kubectl get nodes && kubectl describe nodes | grep -A 6 --color=never -e "^Allocated resources"
echo "----------------------------------------------------"
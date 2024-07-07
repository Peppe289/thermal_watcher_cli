
# find all thermal node and consider as array.
thermal_node=$(find /sys -name temp1_input)
thermal_node=(${thermal_node// / })
k10temp_node=""
amdgpu_node=""

# find k10temp (amd cpu driver for thermal)
# find amdgpu (amd gpu driver for thermal)
for i in "${thermal_node[@]}"
do
    temp=$(echo $i | sed 's/.\{12\}$//')
    check=$(cat "$temp/name")
    if [ "$check" == "k10temp" ]; then
        k10temp_node=$i
    elif [ "$check" == "amdgpu" ]; then
        amdgpu_node=$i
    fi
done

while [[ true ]] do
    clear
    echo "CPU temperature: $(expr $(cat $k10temp_node) / 1000) °C"
    echo "GPU temperature: $(expr $(cat $amdgpu_node) / 1000) °C"

    # exit when press some keys and not print char.
    # this work also as sleep 1 ("-t 1")
    read -n 1 -t 1 -s && break
done

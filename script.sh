
# find all thermal node and consider as array.
thermal_node=$(find /sys -name temp1_input 2> /dev/null)
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

notify_sended=false
notify_allow=false

case ${1} in
    "--notify")
        notify_allow=true
    ;;
    *)
    ;;
esac

while true; do
    clear
    cpu_temp=$(expr $(cat $k10temp_node) / 1000)
    gpu_temp=$(expr $(cat $amdgpu_node) / 1000)
    echo "CPU temperature: $cpu_temp °C"
    echo "GPU temperature: $gpu_temp °C"

    if [ "$notify_allow" = true ]; then
        if [ 70 -lt "$cpu_temp" ] && [ "$notify_sended" = false ]; then
            notify-send "CPU Temp to high: $cpu_temp"
            notify_sended=true
        elif [ "$cpu_temp" -lt 60 ] && [ "$notify_sended" = true ]; then
            notify_sended=false
            notify-send "CPU back to normal temp: $cpu_temp"
        fi
    fi

    # exit when press some keys and not print char.
    # this work also as sleep 1 ("-t 1")
    read -n 1 -t 1 -s && break
done

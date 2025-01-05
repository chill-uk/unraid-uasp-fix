cd /boot/config
# if go.orig and go exists, remove the modified go file and restore go.orig to go
[ -f go.orig ] && [ -f go ] && rm go && mv go.orig go

# if get_hdd_info.sh exists, delete it
[ -f custom_scripts/get_hdd_info.sh ] && rm custom_scripts/get_hdd_info.sh
# if the custom_scripts directory exists and has no files inside, delete it
[ -d custom_scripts ] && [ ! "$(ls -A custom_scripts)" ] && rm -r custom_scripts

# if 60-persistent-storage.rules exists, delete it
[ -f rules.d/60-persistent-storage.rules ] && rm rules.d/60-persistent-storage.rules
# if the rules.d directory exists and has no files inside, delete it
[ -d rules.d ] && [ ! "$(ls -A rules.d)" ] && rm -r rules.d

# reload udev rules
udevadm control --reload-rules
# trigger udev rules
udevadm trigger

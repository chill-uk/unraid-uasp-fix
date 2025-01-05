cd /boot/config
# check if go.orig exists, if not, backup go
[ -f go.orig ] || mv go go.orig
wget -qO- "https://raw.githubusercontent.com/chill-uk/unraid-uasp-fix/refs/heads/main/boot/config/go" > go

# if the udev/rules.d directory doesn't exist, create it
[ -d custom_scripts ] || mkdir -p custom_scripts
wget -qO- "https://raw.githubusercontent.com/chill-uk/unraid-uasp-fix/refs/heads/main/boot/config/custom_scripts_get_hdd_info.sh" > /boot/config/custom_scripts/get_hdd_info.sh

# if the udev/rules.d directory doesn't exist, create it
[ -d rules.d ] || mkdir -p rules.d
wget -qO- "https://raw.githubusercontent.com/chill-uk/unraid-uasp-fix/refs/heads/main/boot/config/rules.d/60-persistent-storage.rules" > /boot/config/rules.d/60-persistent-storage.rules

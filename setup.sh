cd /boot/config
# check if go.orig exists, if not, backup go
[ -f go.orig ] || mv go go.orig
curl -s -o go "https://raw.githubusercontent.com/chill-uk/unraid-uasp-fix/refs/heads/main/boot/config/go"

# if the udev/rules.d directory doesn't exist, create it
[ -d custom_scripts ] || mkdir -p custom_scripts
curl -s -o custom_scripts/get_hdd_info.sh "https://raw.githubusercontent.com/chill-uk/unraid-uasp-fix/refs/heads/main/boot/config/custom_scripts_get_hdd_info.sh"

# if the udev/rules.d directory doesn't exist, create it
[ -d rules.d ] || mkdir -p rules.d
curl -s -o rules.d/60-persistent-storage.rules "https://raw.githubusercontent.com/chill-uk/unraid-uasp-fix/refs/heads/main/boot/config/rules.d/60-persistent-storage.rules"
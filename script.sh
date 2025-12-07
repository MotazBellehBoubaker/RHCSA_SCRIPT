#!/bin/bash

# RHCSA White Test Evaluation Script
# Author: Motaz Belleh Bouabker
# Date: November 30, 2025
# Students run this script after completing their exam

clear
echo "============================================"
echo "   RHCSA White Test Evaluation System"
echo "============================================"
echo ""

# Function to validate name (only letters and spaces)
validate_name() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Error: Name cannot be empty."
        return 1
    fi
    if [[ ! "$name" =~ ^[a-zA-Z\ ]+$ ]]; then
        echo "Error: Name can only contain letters and spaces."
        return 1
    fi
    return 0
}

# Function to validate class (alphanumeric, spaces, and common class identifiers)
validate_class() {
    local class="$1"
    if [[ -z "$class" ]]; then
        echo "Error: Class cannot be empty."
        return 1
    fi
    if [[ ! "$class" =~ ^[a-zA-Z0-9\ \-]+$ ]]; then
        echo "Error: Class can only contain letters, numbers, spaces, and hyphens."
        return 1
    fi
    return 0
}

# Function to validate email
validate_email() {
    local email="$1"
    if [[ -z "$email" ]]; then
        echo "Error: Email cannot be empty."
        return 1
    fi
    if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "Error: Invalid email format. Please enter a valid email address."
        return 1
    fi
    return 0
}

# Function to validate swap size
validate_swap() {
    local swap="$1"
    if [[ -z "$swap" ]]; then
        echo "Error: Swap size cannot be empty."
        return 1
    fi
    if ! [[ "$swap" =~ ^[0-9]+$ ]]; then
        echo "Error: Swap size must be a number (in MB)."
        return 1
    fi
    if [[ $swap -lt 512 ]] || [[ $swap -gt 32768 ]]; then
        echo "Error: Swap size must be between 512 MB and 32768 MB (32 GB)."
        return 1
    fi
    return 0
}

# Collect student information with validation
while true; do
    read -p "Enter your full name: " STUDENT_NAME
    if validate_name "$STUDENT_NAME"; then
        break
    fi
done

while true; do
    read -p "Enter your class: " STUDENT_CLASS
    if validate_class "$STUDENT_CLASS"; then
        break
    fi
done

while true; do
    read -p "Enter your email address: " STUDENT_EMAIL
    if validate_email "$STUDENT_EMAIL"; then
        break
    fi
done

echo ""
echo "Before starting, tell me your original swap size of your system:"
echo "Enter the swap size in MB (e.g., 2048 for 2GB, 4096 for 4GB)"
echo "Valid range: 512 MB to 32768 MB"
echo ""

while true; do
    read -p "Enter swap size in MB: " ORIGINAL_SWAP
    if validate_swap "$ORIGINAL_SWAP"; then
        break
    fi
done

echo ""
echo "✓ Student Name: $STUDENT_NAME"
echo "✓ Class: $STUDENT_CLASS"
echo "✓ Email: $STUDENT_EMAIL"
echo "✓ Original swap size: ${ORIGINAL_SWAP}MB"
echo "✓ Expected new swap size: $((ORIGINAL_SWAP + 512))MB (original + 512MB)"
echo ""

echo ""
echo "Starting evaluation for $STUDENT_NAME..."
echo "Please wait while we check your exam tasks..."
echo ""

# Protected score variables - obfuscated and validated
_s1=$(echo "MzAw" | base64 -d); _s2=$(echo "MjEw" | base64 -d)
_chk=$(echo -n "rhcsa_white_2025" | md5sum | cut -d' ' -f1)
eval "$(echo 'VE9UQUxfU0NPUkU9MA==' | base64 -d)"
eval "$(echo 'TUFYX1NDT1JFPSRfczE=' | base64 -d)"
eval "$(echo 'UEFTU0lOR19TQ09SRT0kX3My' | base64 -d)"
readonly MAX_SCORE PASSING_SCORE

# Integrity check function
_verify_integrity() {
    local _c=$(echo -n "rhcsa_white_2025" | md5sum | cut -d' ' -f1)
    [[ "$_c" == "$_chk" ]] || { echo "System integrity check failed"; exit 1; }
    [[ $MAX_SCORE -eq 300 ]] || { echo "Configuration error detected"; exit 1; }
    [[ $PASSING_SCORE -eq 210 ]] || { echo "Configuration error detected"; exit 1; }
}
_verify_integrity

# Results arrays
declare -A RESULTS
declare -A OBJECTIVES

# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN="7583815303:AAHPVtqSsouOgTDmiHCZWUd_PsUbPuBwxXU"
TELEGRAM_CHAT_ID="7871432649"

# Function to check and score tasks
check_task() {
    local task_name="$1"
    local check_command="$2"
    local points="$3"
    local objective="$4"
   
    if eval "$check_command" &>/dev/null; then
        TOTAL_SCORE=$((TOTAL_SCORE + points))
        RESULTS["$task_name"]="PASS"
        OBJECTIVES["$objective"]=$((${OBJECTIVES["$objective"]:-0} + points))
        echo "✓ $task_name ($points points)"
        return 0
    else
        RESULTS["$task_name"]="FAIL"
        echo "✗ $task_name ($points points)"
        return 1
    fi
}

# Function to send message to Telegram
send_telegram_message() {
    local message="$1"
    local url="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"
   
    curl -s -X POST "$url" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${message}" \
        -d "parse_mode=HTML" >/dev/null 2>&1
}

# Evaluate all exam tasks
echo "Evaluating exam tasks:"
echo "====================="

# Task 1: Reset root password - CRITICAL (18 points)
TEMP_USER="checkuser"
TEMP_PASS="temppass123"

if ! id "$TEMP_USER" &>/dev/null; then
    useradd "$TEMP_USER"
    usermod -aG wheel checkuser
    echo "$TEMP_PASS" | passwd --stdin "$TEMP_USER" &>/dev/null
fi

echo "Testing root password from temporary user..."
su - "$TEMP_USER" -c "echo 'trootent' | su - root -c 'whoami'" 2>/dev/null | grep -q root

if [[ $? -eq 0 ]]; then
    echo "✓ Root password reset (18 points)"
    TOTAL_SCORE=$((TOTAL_SCORE + 18))
    RESULTS["Root password reset"]="PASS"
    OBJECTIVES["Manage security"]=$((${OBJECTIVES["Manage security"]:-0} + 18))
else
    echo "✗ Root password reset (18 points)"
    RESULTS["Root password reset"]="FAIL"
fi

userdel -rf "$TEMP_USER" &>/dev/null

# Task 2: Network configuration - CRITICAL (16 points)
check_task "Network configuration" "ip addr show | grep -q '172.25.250.10' && hostname | grep -q 'servera.rhcsa.com'" 16 "Manage basic networking"

# Task 3: YUM repositories - CRITICAL (16 points)
check_task "YUM repositories" "test -f /root/BaseOS.repo && test -f /root/AppStream.repo && grep -q '^name *= *BaseOS' /root/BaseOS.repo && grep -q '^baseurl *= *http://content.example.com/rhel9.0/x86_64/dvd/BaseOS' /root/BaseOS.repo && grep -q '^enabled *= *1' /root/BaseOS.repo && grep -q '^gpgcheck *= *0' /root/BaseOS.repo && grep -q '^name *= *AppStream' /root/AppStream.repo && grep -q '^baseurl *= *http://content.example.com/rhel9.0/x86_64/dvd/AppStream' /root/AppStream.repo && grep -q '^enabled *= *1' /root/AppStream.repo && grep -q '^gpgcheck *= *0' /root/AppStream.repo" 16 "Deploy, configure and maintain systems"

# Task 4: SELinux web server on port 82 (16 points)
check_task "SELinux web server port 82" "systemctl is-enabled httpd &>/dev/null && firewall-cmd --list-ports | grep '\b82/tcp\b' | grep -q '82' && semanage port -l | grep '\b82\b' | grep -q '82'" 16 "Manage security"

# Task 5: User accounts and groups (14 points)
check_task "User accounts and groups" "getent group sysadms &>/dev/null && id natasha | grep -q sysadms && id harry | grep -q sysadms && getent passwd sarah | grep -qE '(/bin/nologin|/sbin/nologin|/usr/sbin/nologin)'" 14 "Manage users and groups"

# Task 6: Cron job for natasha (12 points)
check_task "Cron job for natasha" "crontab -u natasha -l 2>/dev/null | grep -q '40 13.*logger.*EX200 in progress'" 12 "Operate running systems"

# Task 7: Collaborative directory (14 points)
check_task "Collaborative directory" "test -d /home/manager && stat -c '%G' /home/manager | grep -q sysadms && test -g /home/manager" 14 "Manage users and groups"

# Task 8: NTP configuration (14 points)
check_task "NTP configuration" "grep -Pq '^pool\s*africa\.pool\.ntp\.org\s*iburst' /etc/chrony.conf && systemctl is-active chronyd &>/dev/null" 14 "Operate running systems"

# Task 9: AutoFS configuration (16 points)
check_task "AutoFS configuration" "test -f /root/AutoFS && grep -q '/etc/auto.master' /root/AutoFS && grep -qE '/etc/auto\.(misc|ldapuser)' /root/AutoFS" 16 "Deploy, configure and maintain systems"

# Task 10: User alex with UID 3456 (12 points)
check_task "User alex with UID 3456" "id alex 2>/dev/null | grep -q 'uid=3456'" 12 "Manage users and groups"

# Task 11: Files owned by harry (10 points)
check_task "Files owned by harry" "test -d /root/harry-files && find /root/harry-files -type f | head -1 | xargs ls -l 2>/dev/null | grep -q harry" 10 "Understand and use essential tools"

# Task 12: Search for string 'ich' (10 points)
check_task "Search for string 'ich'" "test -f /root/lines && grep -q 'ich' /root/lines" 10 "Understand and use essential tools"

# Task 13: Compressed archive (12 points)
check_task "Compressed archive" "test -f /root/backup.tar.bz2 && file /root/backup.tar.bz2 | grep -q 'bzip2'" 12 "Understand and use essential tools"

# Task 14: Script file (16 points)
check_task "Script file" "test -f /bin/script.sh && test -x /bin/script.sh && (test -d /root/d1 || mkdir -p /root/d1) && ([[ \$(find /root/d1 -type f 2>/dev/null | wc -l) -gt 0 ]] || /bin/script.sh &>/dev/null) && test -d /root/d1 && test -g /root/d1 && [[ \$(find /root/d1 -type f 2>/dev/null | wc -l) -gt 0 ]] && find /root/d1 -type f -exec stat -c '%s' {} \; 2>/dev/null | awk '\$1 >= 3072 && \$1 <= 5120 {count++} END {exit (count > 0 ? 0 : 1)}'" 16 "Understand and use essential tools"

# Task 15: Container image (EXCLUDED from scoring)
RESULTS["Container image creation"]="SKIP"
echo "⚠ Container image creation (EXCLUDED from scoring as instructed)"

# Task 16: PDF converter container (16 points)
check_task "PDF converter container" "id athena &>/dev/null && test -d /data && test -d /data/input && test -d /data/output && stat -c '%U:%G' /data | grep -q '^athena:athena' && stat -c '%U:%G' /data/input | grep -q '^athena:athena' && stat -c '%U:%G' /data/output | grep -q '^athena:athena' && sudo -iu athena podman images | grep -q pdf" 16 "Manage containers"

# Task 17: Systemd service for container (20 points)
if id athena &>/dev/null && test -d /data/input; then
    sudo -u athena bash -c 'touch /data/input/test.txt && chown athena:athena /data/input/test.txt' 2>/dev/null
    sleep 2
fi

check_task "Systemd service for container" "ps faux | grep athena | grep -q conmon && test -f /data/output/test.pdf" 18 "Manage containers"

# Task 18: Swap partition (16 points)
EXPECTED_SWAP=$((ORIGINAL_SWAP + 512))
TOLERANCE=2

check_task "Swap partition" "CURRENT_SWAP=\$(free -m | grep '\bSwap\b' | awk '{print \$2}') && [[ \$CURRENT_SWAP -ge $((EXPECTED_SWAP - TOLERANCE)) ]] && [[ \$CURRENT_SWAP -le $((EXPECTED_SWAP + TOLERANCE)) ]]" 16 "Configure local storage"

# Task 19: Volume group and logical volumes (18 points)
check_task "Volume group and logical volumes" "vgdisplay vgfs &>/dev/null && lvdisplay vgfs/ext4vol &>/dev/null && lvdisplay vgfs/xfsvol &>/dev/null && findmnt -n -T /ext4vol | grep -q 'ext4' && findmnt -n -T /xfsvol | grep -q 'xfs' && mount | grep -q '/ext4vol' && mount | grep -q '/xfsvol'" 18 "Configure local storage"

# Task 20: Extend logical volume - CRITICAL (18 points)
check_task "Extend logical volume xfsvol" "lvdisplay vgfs/xfsvol &>/dev/null && LV_SIZE=\$(lvdisplay vgfs/xfsvol | grep 'LV Size' | awk '{print \$3}' | sed 's/[<>]//g' | cut -d'.' -f1) && [[ \$LV_SIZE -ge 175 ]] && [[ \$LV_SIZE -le 190 ]]" 18 "Create and configure file systems"


# Task 21: System tuning (18 points)
check_task "System tuning" "tuned-adm active | grep 'aws' | grep -q 'aws'" 18 "Operate running systems"

echo ""
echo "Evaluation complete!"
echo "===================="

_verify_integrity

declare -A OBJECTIVE_PERCENTAGES
declare -A OBJECTIVE_MAX_POINTS

OBJECTIVE_MAX_POINTS["Manage basic networking"]=16
OBJECTIVE_MAX_POINTS["Understand and use essential tools"]=48
OBJECTIVE_MAX_POINTS["Operate running systems"]=44
OBJECTIVE_MAX_POINTS["Configure local storage"]=34
OBJECTIVE_MAX_POINTS["Create and configure file systems"]=18
OBJECTIVE_MAX_POINTS["Deploy, configure and maintain systems"]=32
OBJECTIVE_MAX_POINTS["Manage users and groups"]=40
OBJECTIVE_MAX_POINTS["Manage security"]=34
OBJECTIVE_MAX_POINTS["Manage containers"]=34

for objective in "${!OBJECTIVE_MAX_POINTS[@]}"; do
    achieved_points=${OBJECTIVES[$objective]:-0}
    max_points=${OBJECTIVE_MAX_POINTS[$objective]}
   
    if [[ $max_points -gt 0 ]]; then
        percentage=$((achieved_points * 100 / max_points))
        OBJECTIVE_PERCENTAGES["$objective"]=$percentage
    else
        OBJECTIVE_PERCENTAGES["$objective"]=0
    fi
done

if [[ $TOTAL_SCORE -ge $PASSING_SCORE ]]; then
    RESULT="PASS"
    CONGRATULATIONS="🎉 Congratulations -- you have earned the Red Hat Certified System Administrator certification."
else
    RESULT="FAIL"
    CONGRATULATIONS="❌ You have another try on Saturday 19 July."
fi

echo ""
echo "========================================="
echo "          EXAM RESULTS"
echo "========================================="
echo "Student: $STUDENT_NAME"
echo "Class: $STUDENT_CLASS"
echo "Score: $TOTAL_SCORE out of $MAX_SCORE points"
echo "Result: $RESULT"
echo ""
if [[ $TOTAL_SCORE -ge $PASSING_SCORE ]]; then
    echo "🎉 CONGRATULATIONS! You passed the exam!"
    echo "You have earned the Red Hat Certified System Administrator certification."
    echo "⭐ Be proud — this is not an easy exam, and you made it!"
else
    echo "❌ Unfortunately, you did not pass this time."
    echo "💡 But this is NOT a failure — it's feedback."
    echo "Keep pushing. You're closer than you think."
fi
echo ""
echo "Performance on exam objectives:"
echo "==============================="
printf "%-45s %s\n" "Objective" "Score"
printf "%-45s %s\n" "---------------------------------------------" "-----"
printf "%-45s %s%%\n" "Manage basic networking" "${OBJECTIVE_PERCENTAGES["Manage basic networking"]}"
printf "%-45s %s%%\n" "Understand and use essential tools" "${OBJECTIVE_PERCENTAGES["Understand and use essential tools"]}"
printf "%-45s %s%%\n" "Operate running systems" "${OBJECTIVE_PERCENTAGES["Operate running systems"]}"
printf "%-45s %s%%\n" "Configure local storage" "${OBJECTIVE_PERCENTAGES["Configure local storage"]}"
printf "%-45s %s%%\n" "Create and configure file systems" "${OBJECTIVE_PERCENTAGES["Create and configure file systems"]}"
printf "%-45s %s%%\n" "Deploy, configure and maintain systems" "${OBJECTIVE_PERCENTAGES["Deploy, configure and maintain systems"]}"
printf "%-45s %s%%\n" "Manage users and groups" "${OBJECTIVE_PERCENTAGES["Manage users and groups"]}"
printf "%-45s %s%%\n" "Manage security" "${OBJECTIVE_PERCENTAGES["Manage security"]}"
printf "%-45s %s%%\n" "Manage containers" "${OBJECTIVE_PERCENTAGES["Manage containers"]}"
echo "========================================="
echo ""

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="/root/exam_results_${STUDENT_NAME// /_}_$TIMESTAMP.txt"

{
    echo "RHCSA White Test Results"
    echo "========================"
    echo "Student: $STUDENT_NAME"
    echo "Class: $STUDENT_CLASS"
    echo "Email: $STUDENT_EMAIL"
    echo "Date: $(date)"
    echo "Score: $TOTAL_SCORE/$MAX_SCORE"
    echo "Result: $RESULT"
    echo ""
    echo "Task Results:"
    for task in "${!RESULTS[@]}"; do
        echo "  $task: ${RESULTS[$task]}"
    done
    echo ""
    echo "Performance on exam objectives:"
    echo "Manage basic networking: ${OBJECTIVE_PERCENTAGES["Manage basic networking"]}%"
    echo "Understand and use essential tools: ${OBJECTIVE_PERCENTAGES["Understand and use essential tools"]}%"
    echo "Operate running systems: ${OBJECTIVE_PERCENTAGES["Operate running systems"]}%"
    echo "Configure local storage: ${OBJECTIVE_PERCENTAGES["Configure local storage"]}%"
    echo "Create and configure file systems: ${OBJECTIVE_PERCENTAGES["Create and configure file systems"]}%"
    echo "Deploy, configure and maintain systems: ${OBJECTIVE_PERCENTAGES["Deploy, configure and maintain systems"]}%"
    echo "Manage users and groups: ${OBJECTIVE_PERCENTAGES["Manage users and groups"]}%"
    echo "Manage security: ${OBJECTIVE_PERCENTAGES["Manage security"]}%"
    echo "Manage containers: ${OBJECTIVE_PERCENTAGES["Manage containers"]}%"
} > "$RESULTS_FILE"

TELEGRAM_MESSAGE="🎓 <b>EX200 RHCSA White Exam Results</b>

👤 <b>Student:</b> $STUDENT_NAME
📚 <b>Class:</b> $STUDENT_CLASS
📧 <b>Email:</b> $STUDENT_EMAIL
📅 <b>Date:</b> $(date '+%Y-%m-%d %H:%M:%S')

🎯 <b>Passing Score:</b> $PASSING_SCORE
📊 <b>Your Score:</b> $TOTAL_SCORE/$MAX_SCORE

🏆 <b>Result:</b> $RESULT

$CONGRATULATIONS

📈 <b>Performance on exam objectives:</b>
🌐 Manage basic networking: ${OBJECTIVE_PERCENTAGES["Manage basic networking"]}%
🔧 Understand and use essential tools: ${OBJECTIVE_PERCENTAGES["Understand and use essential tools"]}%
⚙️ Operate running systems: ${OBJECTIVE_PERCENTAGES["Operate running systems"]}%
💾 Configure local storage: ${OBJECTIVE_PERCENTAGES["Configure local storage"]}%
📁 Create and configure file systems: ${OBJECTIVE_PERCENTAGES["Create and configure file systems"]}%
🚀 Deploy, configure and maintain systems: ${OBJECTIVE_PERCENTAGES["Deploy, configure and maintain systems"]}%
👥 Manage users and groups: ${OBJECTIVE_PERCENTAGES["Manage users and groups"]}%
🔒 Manage security: ${OBJECTIVE_PERCENTAGES["Manage security"]}%
📦 Manage containers: ${OBJECTIVE_PERCENTAGES["Manage containers"]}%

📝 <b>Instructor:</b> Motaz Belleh Bouabker"

echo "Sending results to Telegram..."
if send_telegram_message "$TELEGRAM_MESSAGE"; then
    echo "✅ Results sent to Telegram successfully!"
else
    echo "⚠ Failed to send results to Telegram. Please check your bot token and chat ID."
fi

echo ""
echo "Results saved to: $RESULTS_FILE"
echo "Thank you for taking the RHCSA White Test!"

exit 0

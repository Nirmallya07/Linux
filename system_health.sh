#!/bin/bash


system_health_check() {
	{
		echo "Disk Usage"
		df -h
		echo
		echo "CPU Info"
		lscpu
		echo
		echo "Memory Usage"
		free -h
		echo
	} > system_report.txt

	echo "First 10 lines of system_report.txt"
	head -n 10 system_report.txt
}

active_processes() {
    read -p "Enter a keyword to filter processes (press Enter for all): " keyword

    if [ -z "$keyword" ]; then
        # No keyword provided, show all processes
        ps aux
        echo
        echo "Total processes: $(ps aux | wc -l)"
    else
        # Filter processes using grep
        matches=$(ps aux | grep -i "$keyword" | grep -v grep)
        echo "$matches"
        count=$(echo "$matches" | wc -l)
        echo
        echo "Number of processes matching '$keyword': $count"
    fi
}

user_group_management() {
	read -p "Enter username to add user: " user
	read -p "Enter a default password for user: " passwd
	read -p "Enter a new group name where the user will be added: " group
	read -p "Enter the name of new test file: " testfile

	sudo useradd "$user"
	echo "User $user is created successfully"
       	echo	
       	sudo groupadd "$group"
	echo "New group $group is vcreated successfully"
	echo
	sudo usermod -aG "$group" "$user"
	echo "User $user is added to group $group"
	echo
	echo "$user:$passwd" | sudo chpasswd
	echo "password for user $user is changed successfully"

}	

file_organizer() {
	read -p "Enter a directory path :" path
	mkdir -p "$path/images"
	mkdir -p "$path/docs"
	mkdir -p "$path/scripts"
	
	echo " 3 folders created as images, docs, scripts "
	echo
	
	touch "$path/hello.jpg" "$path/hello.png" "$path/document.doc" "$path/docs.docx" "$path/script.sh"

	mv "$path"/*.jpg "$path/images" 2>/dev/null
	mv "$path"/*.png "$path/images" 2>/dev/null
	mv "$path"/*.doc "$path/docs" 2>/dev/null
	mv "$path"/*.docx "$path/docs" 2>/dev/null
	mv "$path"/*.sh "$path/scripts" 2>/dev/null

	echo "Files moved successfully"

	tree "$path"
}

network_diagnostics() {
	read -p "Enter a company name :" url
	echo
	ping -c 3 "$url.com"
	dig "$url.com"
	curl -I "https://$url.com"
} >> network_report.txt

schedule_task() {
    read -p "Enter the full path of the script to schedule: " script_path
    if [ ! -f "$script_path" ]; then
        echo "Script not found at $script_path"
        return 1
    fi

    read -p "Enter minute (0-59): " minute
    read -p "Enter hour (0-23): " hour

    cron_job="$minute $hour * * * $script_path"

    (crontab -l 2>/dev/null; echo "$cron_job") | crontab -

    echo "Cron job added successfully:"
    echo "$cron_job"
}

	


echo "Enter the name of function you want run : "
echo "system_health_check "
echo "active_processes "
echo "user_group_management"
echo "file_organizer"
echo "network_diagnostics"
echo "schedule_task"

read -p "function name :" func

case "$func" in
	system_health_check)
		system_health_check
		;;
	active_processes)
		active_processes
		;;
	user_group_management)
		user_group_management
		;;
	file_organizer)
		file_organizer
		;;
	network_diagnostics)
		network_diagnostics
		;;
	schedule_task)
		schedule_task
		;;
	*)
		ec " Invalid Option "
		;;
esac

otssh – SSH Connection Management Utility
The otssh utility helps you manage SSH connections easily with simple commands.
You can add, list, update, delete, and connect to servers using saved configurations.
Features
•	Add SSH connection
•	List all saved SSH connections (basic & detailed)
•	Update an existing SSH connection
•	Delete an SSH connection
•	Connect to a saved server
 
Add SSH Connection
Add a new SSH connection using:
$ otssh -a -n <name> -h <host> -u <user> [-p <port>] [-i <identity_file>]
Examples:
# Add 'server1' with default port (22) and no identity file
$ otssh -a -n server1 -h 192.168.21.30 -u kirti

# Add 'server2' with custom port (2022)
$ otssh -a -n server2 -h 192.168.42.34 -u kirti -p 2022

# Add 'server3' with custom port and identity file
$ otssh -a -n server3 -h 192.168.46.34 -u ubuntu -p 2022 -i ~/.ssh/server3.pem
 
List SSH Connections
Basic List:
$ otssh ls
Output:
server1
server2
server3
Detailed List:
otssh ls -d
Output:
server1: ssh kirti@192.168.21.30
server2: ssh -p 2022 kirti@192.168.42.34
server3: ssh -i ~/.ssh/server3.pem -p 2022 ubuntu@192.168.46.34
 
Update SSH Connection
Update existing SSH connection settings:
$ otssh -u -n <name> -h <host> -u <user> [-p <port>] [-i <identity_file>]
Examples:
$ otssh -u -n server1 -h server1 -u user1
$ otssh -u -n server2 -h server2 -u user2 -p 2022
Check updated list:
$ otssh ls -d
Output:
server1: ssh user1@server1
server2: ssh -p 2022 user2@server2
server3: ssh -i ~/.ssh/server3.pem -p 2022 ubuntu@192.168.46.34
 
Delete SSH Connection
Remove a saved SSH connection:
$ otssh rm <name>
Examples:
$ otssh rm server1
$ otssh rm server2
Check remaining connections:
$ otssh ls -d
Output:
server3: ssh -i ~/.ssh/server3.pem -p 2022 ubuntu@192.168.46.34
 

Connect to Server
Connect to a server using saved details:
$ otssh <name>
Examples:
$ otssh server1
[ERROR]: Server information is not available, please add server first.

$ otssh server2
[ERROR]: Server information is not available, please add server first.

$ otssh server3
Connecting to server3 on port 2022 as ubuntu via ~/.ssh/server3.pem key.

----------------------------------------
#!/bin/bash

CONFIG_FILE="$HOME/.otssh_config"

usage() {
    echo "Usage:"
    echo "  $0 -a -n <name> -h <host> -u <user> [-p <port>] [-i <identity_file>]"
    echo "  $0 -u -n <name> -h <host> -u <user> [-p <port>] [-i <identity_file>]"
    echo "  $0 ls [-d]"
    echo "  $0 rm <name>"
    echo "  $0 <name>"
    exit 1
}

add_connection() {
    grep -v "^$name:" "$CONFIG_FILE" 2>/dev/null > "$CONFIG_FILE.tmp" || true
    echo "$name:$host:$user:$port:$identity" >> "$CONFIG_FILE.tmp"
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    echo "Added/Updated $name"
}

list_connections() {
    if [[ $detailed == true ]]; then
        while IFS=: read -r NAME HOST USER PORT ID; do
            SSH_CMD="ssh"
            [[ $ID != "" ]] && SSH_CMD+=" -i $ID"
            [[ $PORT != "" ]] && SSH_CMD+=" -p $PORT"
            SSH_CMD+=" $USER@$HOST"
            echo "$NAME: $SSH_CMD"
        done < "$CONFIG_FILE"
    else
        cut -d: -f1 "$CONFIG_FILE"
    fi
}

remove_connection() {
    grep -v "^$1:" "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    echo "Removed $1"
}

connect_server() {
    entry=$(grep "^$1:" "$CONFIG_FILE")
    if [[ "$entry" == "" ]]; then
        echo "[ERROR]: Server information is not available, please add server first."
        exit 1
    fi
    NAME=$(echo "$entry" | cut -d: -f1)
    HOST=$(echo "$entry" | cut -d: -f2)
    USER=$(echo "$entry" | cut -d: -f3)
    PORT=$(echo "$entry" | cut -d: -f4)
    ID=$(echo "$entry" | cut -d: -f5)
    SSH_CMD="ssh"
    [[ $ID != "" ]] && SSH_CMD+=" -i $ID"
    [[ $PORT != "" ]] && SSH_CMD+=" -p $PORT"
    SSH_CMD+=" $USER@$HOST"
    echo "Connecting to $NAME on port ${PORT:-22} as $USER${ID:+ via $ID key}."
    exec $SSH_CMD
}

if [[ $# -lt 1 ]]; then
    usage
fi

case "$1" in
    -a)
        shift
        while [[ $# -gt 0 ]]; do
            case $1 in
                -n) name="$2"; shift 2 ;;
                -h) host="$2"; shift 2 ;;
                -u) user="$2"; shift 2 ;;
                -p) port="$2"; shift 2 ;;       # Port is saved as-is, unchecked!
                -i) identity="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        [[ -z $name || -z $host || -z $user ]] && usage
        add_connection     # Doesn't check if config file is writable!
        ;;
    -u)
        shift
        while [[ $# -gt 0 ]]; do
            case $1 in
                -n) name="$2"; shift 2 ;;
                -h) host="$2"; shift 2 ;;
                -u) user="$2"; shift 2 ;;
                -p) port="$2"; shift 2 ;;       # Port is saved as-is, unchecked!
                -i) identity="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        [[ -z $name || -z $host || -z $user ]] && usage
        add_connection     # Doesn't check if config file is writable!
        ;;
    ls)
        detailed=false
        [[ "$2" == "-d" ]] && detailed=true
        list_connections
        ;;
    rm)
        [[ -z $2 ]] && usage
        remove_connection "$2"
        ;;
    *)
        connect_server "$1"
        ;;
esac

#!/bin/bash

if [ -n "`$SHELL -c 'echo $ZSH_VERSION'`" ]; then
   # assume Zsh
   current_shell="$HOME/.zshrc"
elif [ -n "`$SHELL -c 'echo $BASH_VERSION'`" ]; then
   # assume Bash
   current_shell="$HOME/.bashrc"
else
  echo "Unable to determine the default shell profile file."
  exit 1
fi

# Function to prompt user for variable if it doesn't exist in the shell file
prompt_variable() {
    local variable_name="$1"
    local shell_profile="$2"

    # Check if the variable is already defined in the shell file
    if ! grep -q "^export $variable_name=" "$shell_profile"; then
        while true; do
            read -p "Enter $variable_name: " value
            if [ -z "$value" ]; then
                echo "Error: $variable_name cannot be empty."
            else
                echo "export $variable_name=\"$value\"" >> "$shell_profile"
                break
            fi
        done
    fi
}

# Check and set environment variables
prompt_variable "UHC_CLIENT_ID" "$current_shell"
prompt_variable "UHC_CLIENT_SECRET" "$current_shell"
prompt_variable "CAVO_API_USERNAME" "$current_shell"
prompt_variable "CAVO_API_PASSWORD" "$current_shell"

# Prompt the user for the operating system architecture
while true; do
    echo "Select your operating system architecture:"
    echo "1. Mac OS (Intel)"
    echo "2. Mac OS (Apple Silicon)"
    echo "3. Linux"
    echo "4. Windows"
    read -p "Enter your choice (1-4): " OS_ARCH

    case $OS_ARCH in
        1)
            # macOS (Intel)
            BINARY_PATH="amd/uhcutil"
            break
            ;;
        2)
            # macOS (Apple Silicon)
            BINARY_PATH="arm/uhcutil"
            break
            ;;
        3)
            # Linux
            BINARY_PATH="linux/uhcutil"
            break
            ;;
        4)
            # Windows
            BINARY_PATH="win/uhcutil"
            break
            ;;
        *)
            echo "Invalid choice. Please enter a number between 1 and 4."
            ;;
    esac
done

# Ensure BINARY_PATH is set
if [ -z "$BINARY_PATH" ]; then
    echo "Error: BINARY_PATH is not set. Exiting."
    exit 1
fi

# Set the default GitHub download path
GITHUB_DOWNLOAD_PATH="https://raw.githubusercontent.com/cpwingert/uhcutil-deploy/main/bin"

# Prompt the user for the installation path
while true; do
    read -p "Enter the installation path (e.g., /usr/local/bin): " INSTALL_PATH
    if [ -z "$INSTALL_PATH" ]; then
        echo "Error: Installation path cannot be empty."
    elif [ ! -d "$INSTALL_PATH" ]; then
        mkdir -p "$INSTALL_PATH"
        echo "Directory '$INSTALL_PATH' created."
        break
    else
        break
    fi
done
# Download the binary from GitHub
p="$GITHUB_DOWNLOAD_PATH/$BINARY_PATH"
echo $p


log_file="/Users/cwingert/Desktop/curl_log.txt"

log_curl() {
    echo "\n\n" >> $log_file
    echo "Command: curl $@" >> $log_file
    curl "$@"
}

#curl -L -H "Accept:application/octet-stream" https://raw.githubusercontent.com/cpwingert/uhcutil-deploy/main/bin/arm/uhcutil -o "$INSTALL_PATH/uhcutil"
log_curl -L -H "\"Accept:application/octet-stream\"" -o "$INSTALL_PATH/uhcutil" $p

#if ! curl -H "Accept:application/octet-stream" "$GITHUB_DOWNLOAD_PATH/$BINARY_PATH" -o "$INSTALL_PATH/uhcutil"; then
#    echo "Error: Failed to download the binary. Installation aborted."
#    exit 1
#fi

# Change the permissions of the binary to executable
chmod +x "$INSTALL_PATH/uhcutil"

# Check if the installation path is already in the PATH variable
if ! echo "$PATH" | grep -q "$INSTALL_PATH"; then

    # Update the shell profile file based on the selected architecture
    echo '' >> "$current_shell"
    echo 'export PATH="$PATH:'"$INSTALL_PATH"'"' >> "$current_shell"

    echo "Please restart your shell or run 'source $current_shell' to apply changes."
else
    echo "The installation path '$INSTALL_PATH' is already included in the PATH variable. No changes made to shell profile files."
fi

echo "Installation completed successfully!"

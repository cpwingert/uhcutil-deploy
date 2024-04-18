#!/bin/bash

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
            BINARY_PATH="amd/uhchutil"
            SHELL_PROFILE=~/.zshrc
            break
            ;;
        2)
            # macOS (Apple Silicon)
            BINARY_PATH="arm/uhchutil"
            SHELL_PROFILE=~/.zshrc
            break
            ;;
        3)
            # Linux
            BINARY_PATH="linux/uhchutil"
            if [ -n "$ZSH_VERSION" ]; then
                # Zsh is the default shell
                SHELL_PROFILE=~/.zshrc
            elif [ -n "$BASH_VERSION" ]; then
                # Bash is the default shell
                SHELL_PROFILE=~/.bashrc
            else
                echo "Unable to determine the default shell. Please manually update your shell profile file."
                exit 1
            fi
            break
            ;;
        4)
            # Windows
            BINARY_PATH="win/uhchutil"
            # No shell profile update needed for Windows
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
GITHUB_DOWNLOAD_PATH="https://github.com/cpwingert/uhcutil-deploy/raw/main/bin"

# Prompt the user for the installation path
read -p "Enter the installation path (e.g., /usr/local/bin): " INSTALL_PATH

# Check if the installation path exists, if not, create it
if [ ! -d "$INSTALL_PATH" ]; then
    mkdir -p "$INSTALL_PATH"
    echo "Directory '$INSTALL_PATH' created."
fi

# Download the binary from GitHub
curl -L -o "$INSTALL_PATH/uhcutil" "$GITHUB_DOWNLOAD_PATH/$BINARY_PATH"

# Change the permissions of the binary to executable
chmod +x "$INSTALL_PATH/uhcutil"

# Check if the installation path is already in the PATH variable
if ! echo "$PATH" | grep -q "$INSTALL_PATH"; then

    # Update the shell profile file based on the selected architecture
    echo '' >> "$SHELL_PROFILE"
    echo 'export PATH="$PATH:'"$INSTALL_PATH"'"' >> "$SHELL_PROFILE"

    echo "Please restart your shell or run 'source $SHELL_PROFILE' to apply changes."
else
    echo "The installation path '$INSTALL_PATH' is already included in the PATH variable. No changes made to shell profile files."
fi

echo "Installation completed successfully!"

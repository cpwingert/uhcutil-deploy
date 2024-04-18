#!/bin/bash

# Prompt the user for the operating system architecture
echo "Select your operating system architecture:"
echo "1. macOS (Intel)"
echo "2. macOS (Apple Silicon)"
echo "3. Linux"
echo "4. Windows"
read -p "Enter your choice (1-4): " OS_ARCH

# Set the default GitHub download path
GITHUB_DOWNLOAD_PATH="https://github.com/cpwingert/uhcutil/raw/main/bin/"

case $OS_ARCH in
    1)
        # macOS (Intel)
        BINARY_PATH="$GITHUB_DOWNLOAD_PATH/amd/uhcutil"
        ;;
    2)
        # macOS (Apple Silicon)
        BINARY_PATH="$GITHUB_DOWNLOAD_PATH/arm/uhcutil"
        ;;
    3)
        # Linux
        BINARY_PATH="$GITHUB_DOWNLOAD_PATH/linux/uhcutil"
        ;;
    4)
        # Windows
        BINARY_PATH="$GITHUB_DOWNLOAD_PATH/windows/uhcutil"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac



# Prompt the user for the installation path
read -p "Enter the installation path (e.g., /usr/local/bin): " INSTALL_PATH

# Download the binary from GitHub
curl -L -o "$INSTALL_PATH/uhcutil" "$BINARY_PATH"

# Change the permissions of the binary to executable
chmod +x "$INSTALL_PATH/uhcutil"

# Update the .zshrc file
echo '' >> ~/.zshrc
echo 'export PATH="$PATH:'"$INSTALL_PATH"'"' >> ~/.zshrc

# Update the .bash_profile file
echo '' >> ~/.bash_profile
echo 'export PATH="$PATH:'"$INSTALL_PATH"'"' >> ~/.bash_profile

echo "Installation completed successfully!"
echo "Please restart your shell or run 'source ~/.zshrc' or 'source ~/.bash_profile' to apply changes."

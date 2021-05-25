#!/bin/bash

# This script will be used to install all Linux packages that will be needed in a fresh install

# Resources: 
#
#

set -e # abort the script if anything returns a non-zero value
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
#trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT

# Step 1: Sanity Check
#checks if the OS is Ubuntu
var=$(uname -v)
echo "Checking OS compatability..."
[[ $var =~ .*Ubuntu* ]] && echo -e "OS is compatable...\n" || (echo -e "OS is not Ubuntu. \nClosing script..." &&  exit 1) # if statement to see if OS is Ubuntu

#Checks if apt is downloaded
var=$(which apt)
echo "Checking if apt is downloaded..."
[[ $var =~ .*apt* ]] && echo -e "apt is downloaded...\n" || (echo -e "apt is not installed. \nClosing script..." &&  exit 1) # if statement to see if apt is downloaded

# Step 2: Update OS with packages for downloading
echo 'Updating and upgrading Linux...'
sudo apt --yes --allow-unauthenticated update
sudo apt --yes --allow-unauthenticated upgrade
echo -e 'Finished updating and upgrading Linux...\n'

# Step 3: Install needed applications for development
echo 'Installing VS Code...'
sudo snap install --classic code
echo 'Installing Postman...'
sudo snap install postman
echo 'Installing VirtualBox...'
sudo apt --yes --allow-unauthenticated install  virtualbox virtualbox-ext-pack

# Step 4a: Python3 installs and packages
echo 'Installing Python3...'
sudo apt --yes --allow-unauthenticated install  python3
echo 'Installing pip for Python3'
sudo apt --yes --allow-unauthenticated install  python3-pip
echo 'Installing jedi with pip (for Python3)'
pip3 install jedi

# Step 4b: Node and NPM needed for vim and Typescript/Javascript compiling
echo 'Installing Node and NPM'
sudo apt --yes --allow-unauthenticated install  nodejs
sudo apt --yes --allow-unauthenticated install  npm

# Step 4c: Installing all c++ compilers needed for development and Perl
echo 'Installing C++ compilers'
sudo apt --yes --allow-unauthenticated install  clangd
sudo apt --yes --allow-unauthenticated install  build-essential # Installs gcc, g++ and make
sudo apt --yes --allow-unauthenticated install  manpages-dev  # man pages used for development

# Step 4d: Installing Java
echo 'Installing Open JDK & JRE'
sudo apt --yes --allow-unauthenticated install  openjdk-14-jre

# Step 4e: Installing pre-reqs needed for all development needs
echo 'Installing curl'
sudo apt --yes --allow-unauthenticated install  curl # PREREQ for Step 5
echo 'Installing git'
sudo apt --yes --allow-unauthenticated install  git-all
echo 'Installing wget'
sudo apt --yes --allow-unauthenticated install  software-properties-common apt-transport-https wget

# Step 4f: Installing all pre-reqs needed for installing, building and making
echo -e '\nInstalling Perl, Make, DKMS and build-essential'
sudo apt --yes --allow-unauthenticated install  perl
sudo apt --yes --allow-unauthenticated install  dkms # Dynamic Kernal Module Support

# Step 5f: Go programming language
echo 'Installing Golang'
wget -c https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
export PATH=$PATH:/usr/local/go/bin
source ~/.profile

# Step 5: Text-editors and plugins
echo 'Installing vim and vim plugged'
sudo apt --yes --allow-unauthenticated install  vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Step 6: Installing Docker and some Docker images
sudo apt --yes --allow-unauthenticated install  docker.io
sudo systemctl enable docker
sudo systemctl start docker

echo -e '\nDocker installed installing two images (Portainer and Guacamole)...'
var=$(sudo docker image ls)
[[ $var =~ .*portainer* ]] || sudo docker run -d \
        --name="portainer" \
        --restart on-failure \
        -p 9000:9000 \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce
[[ $var =~ .*guacamole* ]] || sudo docker run -d \
          -p 8080:8080 \
          -v /guacamole:/config \
          oznu/guacamole


# Step 7: Installing good to have Linux commands and applications
echo 'Installing Linux packages for ease of development'
sudo apt --yes --allow-unauthenticated install  okular # PDF reader
sudo apt --yes --allow-unauthenticated install  unoconv # document converter
sudo apt --yes --allow-unauthenticated install  net-tools # gives you a bunch of commands (https://net-tools.sourceforge.io/)
sudo apt --yes --allow-unauthenticated install  tree # will print directory trees
sudo apt --yes --allow-unauthenticated install  mlocate # much better then locate
sudo apt --yes --allow-unauthenticated install  traceroute # used to trace packets
sudo apt --yes --allow-unauthenticated install  xclip # used for the clipboard
sudo apt --yes --allow-unauthenticated install  terminator # much better then terminal
sudo apt --yes --allow-unauthenticated install  cmatrix # just for fun
sudo apt --yes --allow-unauthenticated install  atop # process reader
sudo apt --yes --allow-unauthenticated install  pdftk # pdf merger

set +e # Does not exit after failure
# Step 8: Getting .vimrc and .bashrc
touch ~/.vimrc
wget -O ~/.vimrc https://raw.githubusercontent.com/Matt-Cohen-CS/Files_to_Download/main/.vimrc
touch ~/.bashrc
wget -O ~/.bashrc https://raw.githubusercontent.com/Matt-Cohen-CS/Files_to_Download/main/.bashrc
source ~/.vimrc 
source ~/.bashrc

# Step 9: Installing SSH and VNC
echo -e '\nInstalling SSH server and Tiger VNC...'
sudo apt --yes --allow-unauthenticated install  openssh-server
sudo apt --yes --allow-unauthenticated install  tigervnc-viewer # for some reason this fails but installs it. No clue why it does this
set -e

echo "Checking if SSH files exists..."
if [ -f ~/.ssh/id*.pub ] # -f is a file checker
then
    echo "SSH files exists..."
else
    echo -e '\nAdding SSH key to user'
    echo "Please type your email address"
    read name
    ssh-keygen -t ed25519 -C "$name"
    eval "$(ssh-agent -s)"
fi


# Step 10: Setting Gnome favorites
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'code_code.desktop']"
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'virtualbox.desktop']"
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'org.gnome.Terminal.desktop']"
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'xtigervncviewer.desktop']"
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'terminator.desktop']"

# Step 11: Installing Qt
printf '\n\nDo you want to install Qt? This is for C++ development... [y, n] '
read var 
[[ $var =~ .*y|yes* ]] && var="true" || var=''
if [ $var ]; then
    echo 'Installing Qt and its essential assets...'
    #sudo apt --yes --allow-unauthenticated install qt5-qtbase qt5-qtbase-devel qt5-qtserialport qt5-qtserialport-devel qt5-qtxmlpatterns qt5-qtxmlpatterns-devel qt5-qtlocation qt5-qtlocation-devel ncurses ncurses-devel ncurses-libs openssl openssl-devel kernel-devel libmpc-devel mpfr-devel gmp-devel 
    sudo apt --yes --allow-unauthenticated install qtcreator qt5-default qt5-doc qt5-doc-html qtbase5-doc-html qtbase5-examples
fi;

# Step 12: Restarting OS
printf '\n\nRestarting is probably good idea!\nWould you like to restart? [y,n] '
read var 
[[ $var =~ .*y|yes* ]] && var="true" || var=''
if [ $var ]; then
    echo 'Restarting OS...'
    sleep 5
    shutdown -r now;
fi;


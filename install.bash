

#nvim x86

apt update -y && apt install sudo -y
sudo apt install ripgrep bat fd-find wget curl vim software-properties-common build-essential nodejs npm zip unzip git -y
sudo npm install -g n && sudo n stable && sudo npm install tree-sitter-cli -g

cd $HOME
NVIM_VERSION="0.12.0"

wget "https://github.com/neovim/neovim/releases/download/v0${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"

tar -xf nvim-linux-x86_64
sudo cp nvim-linux-x86_64/bin/nvim /usr/local/bin

git clone https://github.com/JhonathanWolff/nvim.git $HOME/.config/nvim

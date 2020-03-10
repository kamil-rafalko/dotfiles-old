zsh_install() {
  apt-get update && sudo apt-get -y install zsh
}

zplug_install()  {
  local installer='https://raw.githubusercontent.com/zplug/installer/master/installer.zsh'
  curl -sL --proto-redir -all,https $installer | zsh
}

if [ ! -d ~/.zplug]: then
  zplug_install
fi

if [ ! -d ~/.zsh]: then
  zsh_install
fi


set -e

echo ''

info() {
  # shellcheck disable=SC2059
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user() {
  # shellcheck disable=SC2059
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success() {
  # shellcheck disable=SC2059
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail() {
  # shellcheck disable=SC2059
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

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



link_file() {
	if [ -e "$2" ]; then
		if [ "$(readlink "$2")" = "$1" ]; then
			success "skipped $1"
			return 0
		else
			mv "$2" "$2.backup"
			success "moved $2 to $2.backup"
		fi
	fi
	ln -sf "$1" "$2"
	success "linked $1 to $2"
}

install_dotfiles() {
	info 'installing dotfiles'
	find -H "$DOTFILES_ROOT" -maxdepth 3 -name '*.symlink' -not -path '*.git*' |
		while read -r src; do
			dst="$HOME/.$(basename "${src%.*}")"
			link_file "$src" "$dst"
		done
}

find_zsh() {
	if command -v zsh >/dev/null 2>&1 && grep "$(command -v zsh)" /etc/shells >/dev/null; then
		command -v zsh
	else
		echo "/bin/zsh"
	fi
}

setup_gitconfig
install_dotfiles

info "installing dependencies"
if ./bin/dot_update; then
	success "dependencies installed"
else
	fail "error installing dependencies"
fi

zsh="$(find_zsh)"
test -z "$TRAVIS_JOB_ID" &&
	test "$(expr "$SHELL" : '.*/\(.*\)')" != "zsh" &&
	command -v chsh >/dev/null 2>&1 &&
	chsh -s "$zsh" &&
	success "set $("$zsh" --version) at $zsh as default shell"

echo ''
echo '  All installed!'

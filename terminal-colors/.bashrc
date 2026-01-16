# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
#if [ -d ~/.bashrc.d ]; then
#       for rc in ~/.bashrc.d/*; do
#               if [ -f "$rc" ]; then
#                       . "$rc"
#               fi
#       done
#fi

#unset rc

#remove docker color madness
export NO_COLOR=true

#set background color - change #c42e68 to change the color
#https://htmlcolorcodes.com/color-picker/
#this doesn't work on mac if you are using defulat zsh terminal app.
#should work in bash
#you can chnage to bash with this command: 
#chsh -s /bin/bash
#Mac uses zsh due to licensing issues and it has some different features
echo -e "\e]11;#c42e68\a"

#PS1
#The first item is the prompt
#The terminal emulator looks for output containing that specific code (\e]0;) and uses everything up to the \a as the terminal window title.
export PS1="(^: \e]0;2nd Sight Lab\a"

#white please
LS_COLORS="di=1;37:ex=1;37:fi=1;37:ln=1;37:pi=1;37:so=1;37:bd=1;37:cd=1;37:or=1;37:mi=1;37"                                                                                   

starship init fish | source

alias k=kubectl
alias tf=terraform
alias bat=batcat
alias vim=nvim
alias tf=terraform
alias lg=lazygit
alias zj=zellij
alias e=emacsclient
set -gx TERM xterm-256color
set -gx VCPKG_ROOT "$HOME/vcpkg"

set -gx PATH /home/hoon/.local/bin $PATH
set -gx PATH /home/hoon/.local/share/coursier/bin $PATH
ibus-daemon -drx
setxkbmap -layout us -option ctrl:nocaps

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /home/hoon/miniconda3/bin/conda "shell.fish" hook $argv | source
# <<< conda initialize <<<

function yy
    set tmp (mktemp -t "yazi-cwd.XXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

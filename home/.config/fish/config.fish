alias vi=nvim
alias vim=nvim
alias tf=tofu
alias zj=zellij
alias lg=lazygit
alias xclip="xclip -selection c"
alias cursor="cursor --no-sandbox"
alias k="kubectl"

set -gx TERM xterm-256color
set -gx SHELL /usr/bin/fish
set -gx EDITOR hx
fish_add_path /home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin $HOME/.local/bin

function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end


# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

set -l asdf_dir (set -q ASDF_DATA_DIR; and echo $ASDF_DATA_DIR; or echo $HOME/.asdf)
if test -f $asdf_dir/plugins/golang/set-env.fish
    source $asdf_dir/plugins/golang/set-env.fish
end

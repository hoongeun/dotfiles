$env.config.show_banner = false
$env.SHELL = "/home/linuxbrew/.linuxbrew/bin/nu"
$env.EDITOR = "hx"

alias e = hx
alias vi = nvim
alias vim = nvim
alias tf = terraform
alias zj = zellij
alias lg = lazygit
alias xclip = ^xclip -selection c
alias cursor = ^cursor --no-sandbox
alias k = kubectl

def --env yy [...args: string] {
    let tmp = (^mktemp -t "yazi-cwd.XXXXXX")
    ^yazi ...$args $"--cwd-file=($tmp)"
    let cwd = (open --raw $tmp)
    if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
    }
    rm -f $tmp
}

# Homebrew (linuxbrew)
$env.HOMEBREW_PREFIX = "/home/linuxbrew/.linuxbrew"
$env.HOMEBREW_CELLAR = "/home/linuxbrew/.linuxbrew/Cellar"
$env.HOMEBREW_REPOSITORY = "/home/linuxbrew/.linuxbrew/Homebrew"
$env.PATH = ($env.PATH | prepend ["/home/linuxbrew/.linuxbrew/bin" "/home/linuxbrew/.linuxbrew/sbin" $"($env.HOME)/.local/bin" $"($env.HOME)/.asdf/shims"] | uniq)
$env.MANPATH = $"/home/linuxbrew/.linuxbrew/share/man:($env.MANPATH? | default '')"
$env.INFOPATH = $"/home/linuxbrew/.linuxbrew/share/info:($env.INFOPATH? | default '')"

$env.config.table.mode = "none"
$env.config.table.index_mode = "never"
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.cargo/bin" | uniq)

#!/usr/bin/env nu

export def layout [monitor: record, windows: list] {
    let count = ($windows | length)
    if $count == 0 {
        return []
    }

    let rotated = ($monitor.transform in [1 3 5 7])
    let pixels_w = if $rotated { $monitor.height } else { $monitor.width }
    let pixels_h = if $rotated { $monitor.width } else { $monitor.height }
    let width = (($pixels_w / $monitor.scale | math floor | into int) - $monitor.reserved.0 - $monitor.reserved.2)
    let height = (($pixels_h / $monitor.scale | math floor | into int) - $monitor.reserved.1 - $monitor.reserved.3)
    let left = $monitor.x + $monitor.reserved.0
    let top = $monitor.y + $monitor.reserved.1
    let root = ($count | math sqrt | math ceil | into int)
    let columns = if $width >= $height { $root } else { $count / $root | math ceil | into int }
    let rows = ($count / $columns | math ceil | into int)
    let gap = 32
    let window_width = if $count == 1 {
        $width * 0.6 | math floor | into int
    } else {
        ($width * 0.9 - ($columns - 1) * $gap) / $columns | math floor | into int
    }
    let window_height = if $count == 1 {
        $height * 0.65 | math floor | into int
    } else {
        ($height * 0.8 - ($rows - 1) * $gap) / $rows | math floor | into int
    }
    if $window_width <= 0 or $window_height <= 0 {
        error make {msg: "Too many windows for this monitor"}
    }

    let grid_height = ($rows * $window_height + ($rows - 1) * $gap)
    let start_y = ($top + (($height - $grid_height) / 2 | math floor | into int))
    $windows | enumerate | each { |entry|
        let row = ($entry.index / $columns | math floor | into int)
        let column = ($entry.index mod $columns)
        let row_count = ([$columns ($count - $row * $columns)] | math min)
        let row_width = ($row_count * $window_width + ($row_count - 1) * $gap)
        let start_x = ($left + (($width - $row_width) / 2 | math floor | into int))
        {
            address: $entry.item.address
            at: [($start_x + $column * ($window_width + $gap)) ($start_y + $row * ($window_height + $gap))]
            size: [$window_width $window_height]
        }
    }
}

export def layout-fits [positions: list, clients: list] {
    $positions | all { |position|
        let client = ($clients | where { |c| $c.address == $position.address } | first)
        if $client == null {
            true
        } else {
            ($client.floating
                and $client.at.0 >= $position.at.0
                and $client.at.1 >= $position.at.1
                and ($client.at.0 + $client.size.0) <= ($position.at.0 + $position.size.0)
                and ($client.at.1 + $client.size.1) <= ($position.at.1 + $position.size.1))
        }
    }
}

export def restore-commands [saved: list, clients: list, workspace: int] {
    mut commands = []
    for window in $saved {
        let current = ($clients | where { |c| $c.address == $window.address and $c.workspace.id == $workspace } | first)
        if $current == null {
            continue
        }
        if $window.floating {
            if not $current.floating {
                $commands ++= [$"dispatch setfloating address:($window.address)"]
            }
            $commands ++= [
                $"dispatch resizewindowpixel exact ($window.size.0) ($window.size.1),address:($window.address)"
                $"dispatch movewindowpixel exact ($window.at.0) ($window.at.1),address:($window.address)"
            ]
        } else if $current.floating {
            $commands ++= [$"dispatch settiled address:($window.address)"]
        }
    }
    $commands
}

def batch [commands: list] {
    if ($commands | is-empty) {
        return
    }
    let result = (^hyprctl --batch ($commands | str join ";") | complete)
    let errors = ($result.stdout | lines | each { str trim } | where { |line| $line != "" and $line != "ok" })
    if $result.exit_code != 0 or ($errors | is-not-empty) {
        error make {msg: $"hyprctl failed: ($result.stderr) ($errors | str join '; ')"}
    }
}

def notify [message: string] {
    do -i { ^notify-send "Showcase" $message } | ignore
}

def main [] {
    let monitor = (^hyprctl monitors -j | from json | where focused == true | first)
    let workspace = $monitor.activeWorkspace.id
    let runtime = $env.XDG_RUNTIME_DIR
    let instance = $env.HYPRLAND_INSTANCE_SIGNATURE
    let state = ($runtime | path join $"hypr-showcase-($instance)-($workspace).json")
    let clients = (^hyprctl clients -j | from json)

    if ($state | path exists) {
        batch (restore-commands (open $state) $clients $workspace)
        rm $state
        return
    }

    let windows = ($clients
        | where { |c| $c.workspace.id == $workspace and $c.mapped and $c.hidden == false }
        | sort-by at.1 at.0)
    if ($windows | is-empty) {
        return
    }
    if ($windows | any { |window| $window.fullscreen != 0 }) {
        notify "Exit fullscreen before using Showcase."
        return
    }

    let positions = (try { layout $monitor $windows } catch { [] })
    if ($positions | is-empty) {
        notify "Too many windows for this monitor."
        return
    }
    let saved = ($windows | select address floating at size)
    $saved | to json --raw | save --force $state
    mut commands = []
    for position in $positions {
        let window = ($windows | where { |w| $w.address == $position.address } | first)
        if not $window.floating {
            $commands ++= [$"dispatch setfloating address:($position.address)"]
        }
        $commands ++= [
            $"dispatch resizewindowpixel exact ($position.size.0) ($position.size.1),address:($position.address)"
            $"dispatch movewindowpixel exact ($position.at.0) ($position.at.1),address:($position.address)"
        ]
    }
    batch $commands
    sleep 200ms

    let current = (^hyprctl clients -j | from json)
    if not (layout-fits $positions $current) {
        batch (restore-commands $saved $current $workspace)
        rm $state
        notify "The windows cannot fit without overlapping on this monitor."
    }
}

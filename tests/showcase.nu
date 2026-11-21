use ../home/.config/hypr/showcase.nu [layout layout-fits restore-commands]

def check [condition: bool, message: string] {
    if not $condition {
        error make {msg: $message}
    }
}

let monitors = [
    {width: 2560, height: 1440, scale: 1.0, x: 0, y: 0, reserved: [0 24 0 0], transform: 0}
    {width: 1920, height: 1080, scale: 1.25, x: -864, y: 50, reserved: [0 0 0 0], transform: 1}
]
let windows = [
    {address: "0x1"} {address: "0x2"} {address: "0x3"}
    {address: "0x4"} {address: "0x5"} {address: "0x6"}
]

for monitor in $monitors {
    let rotated = ($monitor.transform in [1 3 5 7])
    let pixels_w = if $rotated { $monitor.height } else { $monitor.width }
    let pixels_h = if $rotated { $monitor.width } else { $monitor.height }
    let left = $monitor.x + $monitor.reserved.0
    let top = $monitor.y + $monitor.reserved.1
    let right = $monitor.x + ($pixels_w / $monitor.scale | math floor) - $monitor.reserved.2
    let bottom = $monitor.y + ($pixels_h / $monitor.scale | math floor) - $monitor.reserved.3
    for count in [1 2 3 4 5 6] {
        let positions = (layout $monitor ($windows | first $count))
        check (($positions | length) == $count) "Every window must have a position"
        for a in $positions {
            check ($a.size.0 > 0 and $a.size.1 > 0) "Window dimensions must be positive"
            check ($a.at.0 >= $left and $a.at.1 >= $top
                and ($a.at.0 + $a.size.0) <= $right
                and ($a.at.1 + $a.size.1) <= $bottom) "Windows must fit the monitor's usable area"
            for b in $positions {
                if $a.address == $b.address {
                    continue
                }
                let overlaps = ($a.at.0 < ($b.at.0 + $b.size.0)
                    and $b.at.0 < ($a.at.0 + $a.size.0)
                    and $a.at.1 < ($b.at.1 + $b.size.1)
                    and $b.at.1 < ($a.at.1 + $a.size.1))
                check ($overlaps == false) "Showcase windows must not overlap"
            }
        }
    }
}

let two = (layout $monitors.0 ($windows | first 2))
check ($two.0.at.1 == $two.1.at.1) "Two landscape windows must sit side by side"
let three = (layout $monitors.0 ($windows | first 3))
check ($three.0.at.1 == $three.1.at.1 and $three.2.at.1 > $three.0.at.1) "Three windows must use two rows"
check (($three.2.at.0 + $three.2.size.0 / 2) == 1280) "The last row must be centered"

let actual = ($two | each { |position|
    {address: $position.address, floating: true, at: $position.at, size: $position.size}
})
check (layout-fits $two $actual) "Windows within their cells must fit"
let oversized = ($actual | enumerate | each { |entry|
    if $entry.index == 0 {
        $entry.item | update size [($entry.item.size.0 + 1) $entry.item.size.1]
    } else {
        $entry.item
    }
})
check ((layout-fits $two $oversized) == false) "Oversized windows must be rejected"

let saved = [
    {address: "0x1", floating: false, at: [10 20], size: [800 600]}
    {address: "0x2", floating: true, at: [30 40], size: [500 400]}
    {address: "0x3", floating: false, at: [50 60], size: [300 200]}
]
let current = [
    {address: "0x1", floating: true, workspace: {id: 1}}
    {address: "0x2", floating: true, workspace: {id: 1}}
    {address: "0x3", floating: true, workspace: {id: 2}}
]
let expected = [
    "dispatch settiled address:0x1"
    "dispatch resizewindowpixel exact 500 400,address:0x2"
    "dispatch movewindowpixel exact 30 40,address:0x2"
]
check ((restore-commands $saved $current 1) == $expected) "Restore tiled and floating windows without moving other workspaces"
let tiled_again = ($current | update 1.floating false)
let expected_float = ($expected | insert 1 "dispatch setfloating address:0x2")
check ((restore-commands $saved $tiled_again 1) == $expected_float) "Originally floating windows must be floated again"
print "Showcase layout checks passed"

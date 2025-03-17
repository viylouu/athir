package input

keystates: [350]bool

is_key_down :: proc(key: int) -> bool {
    return keystates[key]
}
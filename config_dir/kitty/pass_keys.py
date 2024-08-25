import re

from kittens.tui.handler import result_handler
from kitty.key_encoding import KeyEvent, parse_shortcut


def should_send_keys_to_window(window):
    cmd_regex = "n?vim|fzf"
    fp = window.child.foreground_processes
    return any(re.search(cmd_regex, p['cmdline'][0] if len(p['cmdline']) else '', re.I) for p in fp)

def encode_key_mapping(window, key_mapping):
    mods, key = parse_shortcut(key_mapping)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & 1),
        alt=bool(mods & 2),
        ctrl=bool(mods & 4),
        super=bool(mods & 8),
        hyper=bool(mods & 16),
        meta=bool(mods & 32),
    ).as_window_system_event()

    return window.encoded_key(event)

def resize_direction(direction):
    if direction == "bottom":
        return "shorter"
    if direction == "top":
        return "taller"
    if direction == "left":
        return "narrower"
    
    return "wider"

def run_kitty_command(boss, command, direction):
    if command == "move":
        boss.active_tab.neighboring_window(direction)
        return
    if command == "resize":
        boss.active_tab.resize_window(resize_direction(direction), 1)
        return

def main():
    pass


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    command = args[1]
    direction = args[2]
    key_mapping = args[3]

    window = boss.window_id_map.get(target_window_id)

    if window is None:
        return
    if should_send_keys_to_window(window):
        for keymap in key_mapping.split(">"):
            encoded = encode_key_mapping(window, keymap)
            window.write_to_child(encoded)
    else:
        run_kitty_command(boss, command, direction)

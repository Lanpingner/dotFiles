import os
import socket
from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
import psutil
import subprocess
from thingsiplay.widget import output
from qtile_extras import widget as qwidget


mod = "mod4"
terminal = guess_terminal()

myDmenuRun = "dmenu_run -g 2 -l 10"
myrofiRun  = "rofi -combi-modi window,drun,ssh -theme solarized -font \"hack 10\" -show combi -icon-theme \"Papirus\" -show-icons"

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "r", lazy.spawn("rofi -combi-modi window,drun,ssh -theme solarized -font \"hack 10\" -show combi -icon-theme \"Papirus\" -show-icons"), desc="Rofi runner"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    #[("<XF86MonBrightnessDown>", spawn "light -U 10")
    #         ,("<XF86MonBrightnessUp>", spawn "light -A 10")]
    Key([],"XF86MonBrightnessDown", lazy.spawn("light -U 10")),
    Key([],"XF86MonBrightnessUp", lazy.spawn("light -A 10")),
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),

        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "q", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "c", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod, "control"], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
]

#groups = [Group(i) for i in "123456789"]
#groups = ["web","dev","init"]
#myWorkspaces = ["1:Term","2:Web","3:im","4:Oracle","5:media","6:<fn=3>\xf17c</fn>"] ++ map show [7..9]
groups = [
    Group("1", label="Term"),
    Group("2", label="Web",
        matches=[Match(wm_class="firefoxdeveloperedition")]),
    Group("3", label="im"),
    Group("4", label="Oracle"),
    Group("5", label="Media"),
    Group("6")
]

for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + letter of group = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layouts = [
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()
prompt = "{0}@{1}: ".format(os.environ["USER"], socket.gethostname())
screens = [
    Screen(
        bottom=bar.Bar(
            [
                widget.Image(
                    filename='~/.config/qtile/icons/remmina.png',
                    mouse_callbacks = {'Button1': lambda: subprocess.run('remmina -i', shell=True)}
                ),
                widget.Image(
                    filename='~/.config/qtile/icons/winbox.svg',
                    mouse_callbacks = {'Button1': lambda: subprocess.run('wine /home/romeo/Downloads/winbox64.exe', shell=True)}
                ),
                widget.CurrentLayoutIcon(
                    custom_icon_paths = [os.path.expanduser("~/.config/qtile/icons")],
                    padding = 0,
                    scale = 0.7,
                ),
                widget.GroupBox(),
                widget.Prompt(),
                #widget.TaskList(),
                widget.Spacer(),
                #widget.Chord(
                #    chords_colors={
                #        "launch": ("#ff0000", "#ffffff"),
                #    },
                #    name_transform=lambda name: name.upper(),
                #),
                #widget.TextBox("default config", name="default"),
                #widget.TextBox("Press &lt;M-r&gt; to spawn", foreground="#d75f5f"),
                # NB Systray is incompatible with Wayland, consider using StatusNotifier instead
                #widget.StatusNotifier(),
                #<box type=Bottom width=2 mb=2 color=#b59800><fc=#b59800>%disku% %getip%</fc></box>
                #widget.Battery(),
                widget.Systray(),
                widget.Clock(format="%Y-%m-%d %a %I:%M %p"),
                #widget.MemoryGraph(type='line'),
            ],
            32,
             #border_width=[2, 0, 2, 0],  # Draw top and bottom borders
             #border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
        top=bar.Bar(
            [
                #widget.GlobalMenu(),
                widget.WindowName(),
                widget.Spacer(),
                widget.ThermalSensor(),
                widget.CPUGraph(type='line'),
                output.Output(
                    cmd='/home/romeo/scripts/getip.sh',
                    update_interval = 2,
                    #text_before = '<i>',
                    #text_after = '</i>',
                ),
                widget.MemoryGraph(),
                qwidget.ALSAWidget(),
                widget.Spacer(
                    length=10,
                ),
                widget.Battery(),
                widget.Image(
                    filename='~/.config/qtile/icons/shutdown.svg',
                    mousecallbacks = {'Button1':'shutdown now'}
                ),
            ],
            32,
        )
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/autostart.sh'])

@hook.subscribe.screen_change
def screen_change(c):
    lazy.reload_config()    

wmname = "LG3D"

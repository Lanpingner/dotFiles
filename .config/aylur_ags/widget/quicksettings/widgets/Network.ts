import { Menu, ArrowToggleButton } from "../ToggleButton"
import icons from "lib/icons.js"
import { dependencies, sh } from "lib/utils"
import options from "options"
//import { Network, Wifi } from "resource:///com/github/Aylur/ags/service/network.js"

const { wifi } = await Service.import("network")
export const NetworkToggle = () => ArrowToggleButton({
    name: "network",
    icon: wifi.bind("icon_name"),
    label: wifi.bind("ssid").as(ssid => ssid || "Not Connected"),
    connection: [wifi, () => wifi.enabled],
    deactivate: () => wifi.enabled = false,
    activate: () => {
        wifi.enabled = true
        wifi.scan()
    },
})

export const WifiSelection = () => Menu({
    name: "network",
    icon: wifi.bind("icon_name"),
    title: "Wifi Selection",
    content: [
        Widget.Box({
            vertical: true,
            setup: self => self.hook(wifi, () => self.children =
                wifi.access_points.map(ap => Widget.Button({
                    on_clicked: () => {
                        if (dependencies("nmcli"))
                            Utils.execAsync(`nmcli device wifi connect ${ap.bssid}`)
                    },
                    child: Widget.Box({
                        children: [
                            Widget.Icon(ap.iconName),
                            Widget.Label(ap.ssid || ""),
                            Widget.Icon({
                                icon: icons.ui.tick,
                                hexpand: true,
                                hpack: "end",
                                setup: self => Utils.idle(() => {
                                    if (!self.is_destroyed)
                                        self.visible = ap.active
                                }),
                            }),
                        ],
                    }),
                })),
            ),
        }),
        Widget.Label({
            label: wifi.bind("ipv4-address").as(ip4 => {
                return ip4.map(addressObj => addressObj?.get_address()).join(",")
            }),
        }),
        Widget.Separator(),
        Widget.Button({
            on_clicked: () => sh(options.quicksettings.networkSettings.value),
            child: Widget.Box({
                children: [
                    Widget.Icon(icons.ui.settings),
                    Widget.Label("Network"),
                ],
            }),
        }),
    ],
})

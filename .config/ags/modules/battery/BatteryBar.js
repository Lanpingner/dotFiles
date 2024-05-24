const battery = await Service.import("battery");

const Indicator = () => Widget.Icon({
    size: 25,
    setup: self => self.hook(battery, () => {
        self.icon = battery.charging || battery.charged
            ? "battery-caution-charging"
            : battery.icon_name;
    }),
});

const PercentLabel = () => Widget.Label({
    class_name: "batterylabel",
    label: battery.bind("percent").as(p => `${p}%`)
});

const LevelBar = () => Widget.LevelBar({
    mode: 1,
    max_value: 100,
    value: battery.bind("percent").as(p => (p / 100) * 7),
});

export default () => Widget.Box({
    class_name: "batterybar",
    expand: true,
    visible: battery.bind("available"),
    children: [
        Indicator(),
        PercentLabel(),
        LevelBar(),
    ],
});

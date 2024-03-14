import screenrecord from "../service/screenrecord.js";

export default () => Widget.EventBox({
    class_name: "screenshot",
    on_primary_click_release: () => screenrecord.screenshot(),
    child: Widget.Box({
        children: [
            Widget.Icon({ icon: "camera-web-symbolic", size: 25 }),
        ],
    }),
});

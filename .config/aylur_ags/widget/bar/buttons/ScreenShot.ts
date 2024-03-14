import PanelButton from "../PanelButton"
import screenrecord from "service/screenrecord"
import icons from "lib/icons"

export default () => PanelButton({
    class_name: "recorder",
    on_clicked: () => screenrecord.screenshot(),
    child: Widget.Box({
        children: [
            Widget.Icon("camera-web-symbolic"),
        ],
    }),
})

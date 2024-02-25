import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import PanelButton from '../PanelButton.js';
import Recorder from '../../services/screenrecord.js';
import icons from '../../icons.js';

export default () => PanelButton({
    class_name: 'screenshot',
    tooltip_text : 'Screenshot',
    has_tooltip: true,
    //binds: [['visible', Recorder, 'recording']],
    content: Widget.Icon('camera-web-symbolic'),
    on_clicked: () => Recorder.screenshot(),
});

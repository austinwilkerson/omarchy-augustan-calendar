import QtQuick
import qs.Commons as Commons
Rectangle {
    id: root
    property string label: ""
    property bool checked: false
    signal toggled()
    activeFocusOnTab: true
    implicitHeight: Commons.Style.space(30)
    color: mouse.containsMouse || activeFocus ? Commons.Style.hoverFillFor(Commons.Color.popups.text, Commons.Color.accent) : "transparent"
    radius: Commons.Style.cornerRadius
    PlainText { anchors.left: parent.left; anchors.leftMargin: Commons.Style.space(8); anchors.verticalCenter: parent.verticalCenter; text: root.label; font.pixelSize: Commons.Style.font.bodySmall }
    Rectangle {
        anchors.right: parent.right; anchors.rightMargin: Commons.Style.space(8); anchors.verticalCenter: parent.verticalCenter
        width: Commons.Style.space(14); height: width; radius: Math.min(Commons.Style.cornerRadius,Commons.Style.space(2))
        color: root.checked ? Qt.alpha(Commons.Color.accent,0.13) : "transparent"
        border.width: Commons.Style.spacing.hairline; border.color: root.checked ? Commons.Color.accent : Qt.darker(Commons.Color.popups.text,1.7)
        PlainText { anchors.centerIn: parent; text: root.checked ? "✓" : ""; color: Commons.Color.accent; font.pixelSize: Commons.Style.font.caption }
    }
    Keys.onSpacePressed: root.toggled()
    Keys.onReturnPressed: root.toggled()
    MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.forceActiveFocus(); root.toggled() } }
}

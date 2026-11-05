import QtQuick
import qs.Commons
Rectangle {
    id: root
    property string label: ""
    property bool checked: false
    signal toggled()
    activeFocusOnTab: true
    implicitHeight: Style.space(30)
    color: mouse.containsMouse || activeFocus ? Style.hoverFillFor(Color.foreground, Color.accent) : "transparent"
    radius: Style.cornerRadius
    PlainText { anchors.left: parent.left; anchors.leftMargin: Style.space(8); anchors.verticalCenter: parent.verticalCenter; text: root.label; font.pixelSize: Style.font.bodySmall }
    Rectangle {
        anchors.right: parent.right; anchors.rightMargin: Style.space(8); anchors.verticalCenter: parent.verticalCenter
        width: Style.space(14); height: width; radius: Math.min(Style.cornerRadius,Style.space(2))
        color: root.checked ? Qt.alpha(Color.accent,0.13) : "transparent"
        border.width: Style.spacing.hairline; border.color: root.checked ? Color.accent : Qt.darker(Color.foreground,1.7)
        PlainText { anchors.centerIn: parent; text: root.checked ? "✓" : ""; color: Color.accent; font.pixelSize: Style.font.caption }
    }
    Keys.onSpacePressed: root.toggled()
    Keys.onReturnPressed: root.toggled()
    MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.forceActiveFocus(); root.toggled() } }
}

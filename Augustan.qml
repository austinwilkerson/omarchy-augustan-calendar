import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model
import "Quotes.js" as Quotes

Panel {
    id: root
    moduleName: "io.github.austinwilkerson.augustan"
    ipcTarget: moduleName
    property date now: new Date()
    readonly property var today: Model.parts(now)
    property int viewYear: today.year
    property int viewMonth: today.monthIndex
    property int selectedDay: today.day
    property bool editing: false
    property string placementError: ""
    readonly property bool vertical: bar ? bar.vertical : false
    readonly property string monthSystem: String(setting("monthNames", "disciple"))
    readonly property string activeFormat: String(setting("format", "date-time"))
    readonly property bool showSpecial: setting("specialDays", true) === true
    readonly property bool showHoly: setting("holyDays", true) === true
    readonly property bool showQuotes: setting("quotes", true) === true
    readonly property string selectedTheme: Model.theme(viewMonth, selectedDay)
    readonly property var selectedHolidays: showHoly ? Model.holidays(viewMonth, selectedDay) : []
    readonly property var quote: showQuotes ? Quotes.forDay(viewYear, viewMonth, selectedDay, selectedTheme) : null
    readonly property color fg: bar ? bar.foreground : Commons.Color.foreground
    readonly property string family: bar ? bar.fontFamily : Style.font.family
    readonly property int countDays: Model.daysInMonth(viewYear, viewMonth)
    Translations { id: strings; directory: Qt.resolvedUrl("i18n") }
    readonly property string clockSide: String(setting("placement", "centerBegin"))
    readonly property real outerClockPadding: !vertical && (clockSide==="centerBegin" || clockSide==="centerEnd") ? Style.spaceReal(8.5) : 0
    implicitWidth: button.implicitWidth + outerClockPadding
    implicitHeight: button.implicitHeight

    function save(key,value) {
        var entry={id:root.moduleName};
        for(var k in root.settings) if(k!=="id") entry[k]=root.settings[k];
        entry[key]=value;
        root.settings=entry;
        if(root.bar && root.bar.shell) root.bar.shell.updateEntryInline(root.moduleName,entry);
    }
    function goToToday() { viewYear=today.year; viewMonth=today.monthIndex; selectedDay=today.day; }
    function moveMonth(delta) {
        var next=Model.stepMonth(viewYear,viewMonth,delta);
        viewYear=next.year; viewMonth=next.month;
        selectedDay=Math.min(selectedDay,Model.daysInMonth(viewYear,viewMonth));
    }
    function open() { goToToday(); editing=false; root.controller.show(); }
    function place(section) {
        root.placementError="";
        placement.command=(section==="centerBegin" || section==="centerEnd")
            ? ["omarchy","bar","move",root.moduleName,section==="centerBegin"?"--before":"--after","omarchy.clock"]
            : ["omarchy","bar","move",root.moduleName,"--section",section,"--index","0"];
        placement.running=true;
    }
    Process {
        id: placement
        stderr: StdioCollector { onStreamFinished: root.placementError=text.trim() }
        onExited: function(exitCode) { if(exitCode!==0 && !root.placementError) root.placementError=strings.t("placementError") }
    }
    Timer {
        interval: (root.activeFormat==="weekday-seconds" || root.activeFormat==="date-seconds") ? 100 : 1000; repeat: true; running: true
        onTriggered: {
            var previous=root.today;
            var following=root.viewYear===previous.year && root.viewMonth===previous.monthIndex && root.selectedDay===previous.day;
            root.now=new Date();
            if(following && (previous.day!==root.today.day || previous.monthIndex!==root.today.monthIndex || previous.year!==root.today.year)) root.goToToday();
        }
    }
    // Small IPC surface for keyboard shortcuts and integration checks.
    ShellIpc {
        target: root.moduleName + ".calendar"
        function status(): string { return JSON.stringify({opened:root.opened,editing:root.editing,year:root.viewYear,month:root.viewMonth,day:root.selectedDay,theme:root.selectedTheme,quote:root.quote,format:root.activeFormat,specialDays:root.showSpecial,holyDays:root.showHoly,quotes:root.showQuotes,placementError:root.placementError}) }
        function cycleFormat(): void { root.save("format",Model.nextFormat(root.activeFormat)) }
        function settings(): void { root.open(); root.editing=true }
        function nextMonth(): void { root.moveMonth(1) }
        function previousMonth(): void { root.moveMonth(-1) }
        function today(): void { root.goToToday() }
        function selectDay(day: int): void { if(day>=1 && day<=root.countDays) root.selectedDay=day }
    }
    WidgetButton {
        id: button
        anchors.fill: parent
        anchors.leftMargin: root.clockSide==="centerBegin" ? root.outerClockPadding : 0
        anchors.rightMargin: root.clockSide==="centerEnd" ? root.outerClockPadding : 0
        bar: root.bar
        text: root.vertical ? Model.time(root.now).slice(0,-3).replace(':','\n') : ((root.setting("placement","centerBegin")==="centerEnd" ? "| " : "") + Model.label(root.now, root.activeFormat,root.monthSystem) + (root.setting("placement","centerBegin")==="centerBegin" ? " |" : ""))
        // The regular clock already supplies padding beside the separator.
        horizontalMargin: (root.setting("placement","centerBegin")==="centerBegin" || root.setting("placement","centerBegin")==="centerEnd") ? 0 : 8.5
        labelVisible: true
        pressFeedbackButtons: Qt.NoButton
        tooltipText: Model.plain(strings.t("barHint"))
        onPressed: function(b) {
            if(b===Qt.RightButton) root.save("format",Model.nextFormat(root.activeFormat));
            else root.toggle();
        }
    }
    KeyboardPanel {
        id: panel
        anchorItem: button
        owner: root
        bar: root.bar
        open: root.opened
        centerOnBar: false
        focusTarget: panel.loadedContent
        contentWidth: panel.fittedContentWidth(Style.space(720))
        contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)
        content: FocusScope {
            implicitHeight: body.implicitHeight
            Keys.onPressed: function(event) {
                var key=Util.readingKey(event);
                if(event.key===Qt.Key_Escape) { if(root.editing) root.editing=false; else root.close(); }
                else if(!root.editing && key===Qt.Key_Left) root.moveMonth(-1);
                else if(!root.editing && key===Qt.Key_Right) root.moveMonth(1);
                else if(!root.editing && event.key===Qt.Key_Up) root.moveMonth(-10);
                else if(!root.editing && event.key===Qt.Key_Down) root.moveMonth(10);
                else if(!root.editing && (event.key===Qt.Key_Return || event.key===Qt.Key_Home)) root.goToToday();
                else return;
                event.accepted=true;
            }
            Flickable {
                anchors.fill: parent
                contentHeight: body.implicitHeight
                contentWidth: width
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                Column {
                    id: body
                    width: parent.width
                    spacing: Style.space(18)
                    Item {
                        width: parent.width; height: Style.space(32)
                        PlainText { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; text: strings.t(root.editing?"settings":"title").toUpperCase(); color: Qt.darker(root.fg,1.4); font.pixelSize: Style.font.caption; font.letterSpacing: 2 }
                        PanelActionButton {
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            iconText: root.editing ? "󰅖" : "󰒓"
                            tooltipText: Model.plain(strings.t(root.editing?"back":"settings"))
                            foreground: root.fg; fontFamily: root.family; focusable: true
                            onClicked: root.editing=!root.editing
                        }
                    }
                    Column {
                        visible: !root.editing
                        width: parent.width
                        spacing: Style.space(18)
                        Item {
                            width: parent.width; height: hero.implicitHeight+Style.space(12)
                            PlainText {
                                id: hero; anchors.horizontalCenter: parent.horizontalCenter
                                text: Model.monthName(root.today.monthIndex,root.monthSystem)+" "+I18n.formatNumber(root.today.day)
                                font.family: root.family; font.pixelSize: Math.min(Style.space(52),parent.width/9); font.bold: true
                                color: root.fg
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.goToToday() }
                        }
                        Item {
                            width: parent.width; height: Style.space(22)
                            PlainText { id: yearLabel; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; text: I18n.formatNumber(root.today.year); color: Qt.darker(root.fg,1.5); font.pixelSize: Style.font.bodySmall }
                            PlainText { id: progressLabel; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: I18n.formatNumber(Math.floor(Model.yearProgress(root.now)*100))+"%"; font.pixelSize: Style.font.bodySmall }
                            Rectangle {
                                anchors.left: yearLabel.right; anchors.right: progressLabel.left; anchors.margins: Style.space(16); anchors.verticalCenter: parent.verticalCenter
                                height: Style.space(6); color: Qt.alpha(root.fg,0.12); radius: Style.cornerRadius>0?height/2:0
                                Rectangle { width: parent.width*Model.yearProgress(root.now); height: parent.height; radius: parent.radius; color: root.fg }
                            }
                        }
                        Grid {
                            id: grid
                            width: parent.width
                            columns: root.viewMonth===9 ? root.countDays : 10
                            rowSpacing: Style.space(4)
                            readonly property real cell: width/columns
                            Repeater {
                                model: root.viewMonth===9 ? root.countDays : 10
                                PlainText {
                                    required property int index
                                    width: grid.cell; height: Style.space(28)
                                    text: root.viewMonth===9 ? (index===5 ? "+" : I18n.formatNumber(index+1)) : Model.headings[index].toUpperCase()
                                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: Math.min(Style.font.caption,grid.cell/5.1)
                                    color: Qt.darker(root.fg,1.5); font.bold: true
                                }
                            }
                            Repeater {
                                model: root.countDays
                                Rectangle {
                                    id: cell
                                    required property int index
                                    readonly property int day: index+1
                                    readonly property bool isToday: root.viewYear===root.today.year && root.viewMonth===root.today.monthIndex && day===root.today.day
                                    readonly property bool selected: root.selectedDay===day
                                    readonly property string theme: root.showSpecial ? Model.theme(root.viewMonth,day) : ""
                                    readonly property var holy: root.showHoly ? Model.holidays(root.viewMonth,day) : []
                                    width: grid.cell; height: Style.space(54)
                                    radius: Style.cornerRadius
                                    color: cellMouse.containsMouse || activeFocus ? Style.hoverFillFor(root.fg,Commons.Color.accent) : selected && !isToday ? Qt.alpha(root.fg,0.045) : "transparent"
                                    border.width: isToday ? Style.spacing.hairline : 0
                                    border.color: Style.normalBorderFor(root.fg,Commons.Color.accent)
                                    activeFocusOnTab: true
                                    Keys.onReturnPressed: root.selectedDay=day
                                    Keys.onSpacePressed: root.selectedDay=day
                                    PlainText { anchors.centerIn: parent; text: I18n.formatNumber(cell.day); color: root.fg; font.family: root.family; font.bold: cell.isToday }
                                    Row {
                                        anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: Style.space(7); spacing: Style.space(4)
                                        Rectangle { visible: cell.theme!==""; width: Style.space(12); height: Style.space(2); color: Model.themeColor(cell.theme); opacity: 0.65 }
                                        Rectangle { visible: cell.holy.length>0; width: Style.space(4); height: width; radius: width/2; color: root.fg; opacity: 0.7 }
                                    }
                                    MouseArea { id: cellMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedDay=cell.day }
                                    PanelToolTip { visible: cellMouse.containsMouse && (cell.theme!=="" || cell.holy.length>0); text: Model.plain(([cell.theme].filter(function(v){return v!==""})).concat(cell.holy).join(" · ")); fontFamily: root.family }
                                }
                            }
                        }
                        Item {
                            width: parent.width; height: Style.space(34)
                            PlainText { anchors.centerIn: parent; text: Model.monthName(root.viewMonth,root.monthSystem).toUpperCase()+" "+I18n.formatNumber(root.viewYear); color: Qt.darker(root.fg,1.4); font.letterSpacing: 1; font.pixelSize: Style.font.bodySmall }
                            PanelActionButton { anchors.left: parent.left; iconText: I18n.rightToLeft?"󰅂":"󰅁"; foreground: root.fg; tooltipText: Model.plain(strings.t("previous")); focusable: true; onClicked: root.moveMonth(-1) }
                            PanelActionButton { anchors.right: parent.right; iconText: I18n.rightToLeft?"󰅁":"󰅂"; foreground: root.fg; tooltipText: Model.plain(strings.t("next")); focusable: true; onClicked: root.moveMonth(1) }
                        }
                        PlainText {
                            visible: root.selectedHolidays.length>0
                            width: parent.width; wrapMode: Text.WordWrap
                            text: root.selectedHolidays.map(function(v){return strings.t(v)}).join(" · ")
                            color: Qt.darker(root.fg,1.25); font.pixelSize: Style.font.bodySmall; horizontalAlignment: Text.AlignHCenter
                        }
                        Column {
                            visible: root.quote!==null
                            width: parent.width; spacing: Style.space(10)
                            Rectangle { width: parent.width; height: Style.spacing.hairline; color: Qt.alpha(root.fg,0.12) }
                            PlainText { width: parent.width; text: strings.t(root.selectedTheme).toUpperCase(); font.pixelSize: Style.font.caption; font.letterSpacing: 2; color: Model.themeColor(root.selectedTheme); horizontalAlignment: Text.AlignHCenter }
                            PlainText { width: parent.width-Style.space(40); anchors.horizontalCenter: parent.horizontalCenter; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter; text: root.quote ? '“'+root.quote.text+'”' : ''; font.pixelSize: Style.font.body; lineHeight: 1.3 }
                            PlainText { width: parent.width; text: root.quote ? root.quote.author : ''; color: Qt.darker(root.fg,1.5); font.pixelSize: Style.font.bodySmall; horizontalAlignment: Text.AlignHCenter }
                        }
                    }
                    Column {
                        visible: root.editing
                        width: parent.width; spacing: Style.space(8)
                        PlainText { text: strings.t("monthNames"); font.bold: true }
                        Repeater {
                            model: ["disciple","numerical","seasonal"]
                            SettingRow {
                                required property string modelData
                                width: parent.width; label: strings.t("months."+modelData); checked: root.monthSystem===modelData
                                onToggled: root.save("monthNames",modelData)
                            }
                        }
                        PlainText { text: strings.t("calendar"); font.bold: true }
                        SettingRow { width: parent.width; label: strings.t("special"); checked: root.showSpecial; onToggled: root.save("specialDays",!root.showSpecial) }
                        SettingRow { width: parent.width; label: strings.t("holy"); checked: root.showHoly; onToggled: root.save("holyDays",!root.showHoly) }
                        SettingRow { width: parent.width; label: strings.t("quotes"); checked: root.showQuotes; onToggled: root.save("quotes",!root.showQuotes) }
                        PlainText { text: strings.t("placement"); font.bold: true }
                        Repeater {
                            model: ["centerBegin","centerEnd","left","right"]
                            SettingRow {
                                required property string modelData
                                width: parent.width; label: strings.t("place."+modelData); checked: root.setting("placement", "centerBegin")===modelData
                                enabled: !placement.running
                                onToggled: { root.save("placement",modelData); root.place(modelData) }
                            }
                        }
                        PlainText { width: parent.width; wrapMode: Text.WordWrap; visible: root.placementError!==""; text: root.placementError; font.pixelSize: Style.font.bodySmall }
                    }
                }
            }
        }
    }
}

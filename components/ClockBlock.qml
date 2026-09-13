import QtQuick

Item {
  id: root

  property date displayDate: new Date()
  property int fontSize: 128

  readonly property string hourText: Qt.formatDateTime(displayDate, "HH")
  readonly property string minuteText: Qt.formatDateTime(displayDate, "mm")

  implicitWidth: clockColumn.implicitWidth
  implicitHeight: clockColumn.implicitHeight

  Column {
    id: clockColumn
    spacing: -Math.round(root.fontSize * 0.16)
    anchors.centerIn: parent

    Text {
      textFormat: Text.PlainText
      text: root.hourText
      color: "#fffaf2"
      font.family: "monospace"
      font.pixelSize: root.fontSize
      font.weight: Font.DemiBold
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
      textFormat: Text.PlainText
      text: root.minuteText
      color: "#fffaf2"
      font.family: "monospace"
      font.pixelSize: root.fontSize
      font.weight: Font.DemiBold
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
    }
  }
}

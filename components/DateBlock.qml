import QtQuick

Item {
  id: root

  property date displayDate: new Date()
  property int weekdaySize: 22
  property int dateSize: 16

  implicitWidth: dateColumn.implicitWidth
  implicitHeight: dateColumn.implicitHeight

  Column {
    id: dateColumn
    spacing: 2
    anchors.centerIn: parent

    Text {
      textFormat: Text.PlainText
      text: Qt.formatDate(root.displayDate, "dddd")
      color: "#f5f2eb"
      font.family: "monospace"
      font.pixelSize: root.weekdaySize
      font.weight: Font.DemiBold
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
      textFormat: Text.PlainText
      text: Qt.formatDate(root.displayDate, "dd MMM")
      color: Qt.rgba(0.96, 0.95, 0.92, 0.7)
      font.family: "monospace"
      font.pixelSize: root.dateSize
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
    }
  }
}

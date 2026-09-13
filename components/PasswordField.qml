import QtQuick

Item {
  id: root

  property int fieldWidth: 230
  property int fieldHeight: 46
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property bool inputEnabled: true
  property string passwordText: ""
  property bool syncingPasswordText: false

  readonly property int fieldFontSize: Math.round(Math.max(16, Math.min(fieldHeight * 0.45, 22)))
  readonly property bool errorState: failureMessage.length > 0
  readonly property real fingerprintReserve: fingerprintConfigured ? Math.round(fieldHeight * 0.62) : 0

  implicitWidth: fieldWidth
  implicitHeight: fieldHeight + (statusText.visible ? statusText.implicitHeight + 7 : 0)

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  function forcePasswordFocus() {
    if (inputEnabled && !authenticatingPassword) passwordInput.forceActiveFocus()
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  Component.onCompleted: {
    syncPasswordText()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  Rectangle {
    id: capsule
    width: root.fieldWidth
    height: root.fieldHeight
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    radius: height / 2
    color: Qt.rgba(0.96, 0.94, 0.9, root.authenticatingPassword ? 0.13 : 0.18)
    border.color: root.errorState ? Qt.rgba(1, 0.36, 0.32, 0.58) : Qt.rgba(1, 0.98, 0.94, 0.32)
    border.width: root.errorState ? 2 : 1
  }

  TextInput {
    id: passwordInput
    anchors.fill: capsule
    anchors.leftMargin: Math.round(capsule.height * 0.55) + root.fingerprintReserve
    anchors.rightMargin: Math.round(capsule.height * 0.55) + root.fingerprintReserve
    verticalAlignment: TextInput.AlignVCenter
    horizontalAlignment: TextInput.AlignHCenter
    activeFocusOnPress: true
    clip: true
    enabled: root.inputEnabled && !root.authenticatingPassword
    readOnly: root.authenticatingPassword
    echoMode: TextInput.Password
    passwordCharacter: "\u2022"
    passwordMaskDelay: 0
    color: "#fffaf2"
    selectionColor: Qt.rgba(1, 0.98, 0.94, 0.28)
    selectedTextColor: "#fffaf2"
    font.family: "monospace"
    font.pixelSize: root.fieldFontSize
    cursorVisible: activeFocus && enabled
    selectByMouse: false

    onTextChanged: {
      if (!root.syncingPasswordText) root.passwordTextEdited(text)
      if (text.length > 0) root.wakeRequested()
      if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
    }

    onAccepted: {
      var submitted = passwordInput.text
      root.passwordTextEdited("")
      if (submitted.length > 0) root.submitPassword(submitted)
    }

    Keys.onPressed: function(event) {
      root.wakeRequested()
      if (event.key === Qt.Key_Escape || ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_U)) {
        root.passwordTextEdited("")
        event.accepted = true
      }
    }
  }

  Text {
    textFormat: Text.PlainText
    anchors.fill: capsule
    anchors.leftMargin: Math.round(capsule.height * 0.55) + root.fingerprintReserve
    anchors.rightMargin: Math.round(capsule.height * 0.55) + root.fingerprintReserve
    visible: passwordInput.text.length === 0
    text: root.authenticatingPassword ? "Checking..." : ""
    color: Qt.rgba(0.97, 0.96, 0.94, 0.72)
    font.family: "monospace"
    font.pixelSize: root.fieldFontSize
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
  }

  Text {
    textFormat: Text.PlainText
    anchors.right: capsule.right
    anchors.rightMargin: Math.round(capsule.height * 0.4)
    anchors.verticalCenter: capsule.verticalCenter
    visible: root.fingerprintConfigured
    text: "󰈷"
    color: Qt.rgba(0.97, 0.96, 0.94, 0.55)
    font.family: "monospace"
    font.pixelSize: Math.round(root.fieldFontSize * 0.75)
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }

  Text {
    id: statusText
    textFormat: Text.PlainText
    anchors.top: capsule.bottom
    anchors.topMargin: 7
    anchors.horizontalCenter: parent.horizontalCenter
    width: Math.max(root.fieldWidth, 240)
    visible: root.failureMessage.length > 0
    text: root.failureMessage
    color: Qt.rgba(1, 0.54, 0.48, 0.95)
    font.family: "monospace"
    font.pixelSize: Math.round(Math.max(11, Math.min(root.fieldHeight * 0.28, 14)))
    horizontalAlignment: Text.AlignHCenter
    elide: Text.ElideRight
  }
}

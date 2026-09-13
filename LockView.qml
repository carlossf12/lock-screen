import QtQuick
import Quickshell
import Quickshell.Io
import "./components" as Components
import "LockBackgroundConfig.js" as LockBackgroundConfig

Item {
  id: root

  property bool previewMode: false
  property string previewPasswordText: "••••"
  property string backgroundPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool loadBackground: true
  property string passwordText: ""
  property string configRaw: ""
  property var lockBackgroundConfig: LockBackgroundConfig.normalize(configRaw)
  property int configVersion: 0

  readonly property real shortSide: Math.min(width, height)
  readonly property real safeMargin: Math.max(24, shortSide * 0.045)
  readonly property real mainOffset: -Math.round(height * 0.055)
  readonly property int clockSize: Math.round(Math.max(86, Math.min(height * 0.145, 168)))
  readonly property int weekdaySize: Math.round(Math.max(16, Math.min(height * 0.027, 25)))
  readonly property int dateSize: Math.round(Math.max(13, Math.min(height * 0.022, 20)))
  readonly property int lockSize: Math.round(Math.max(14, Math.min(height * 0.024, 22)))
  readonly property int passwordWidth: Math.round(Math.max(190, Math.min(width * 0.135, 260)))
  readonly property int passwordHeight: Math.round(Math.max(38, Math.min(height * 0.045, 50)))
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")
  readonly property string configPath: configHome + "/omarchy/carlossf12.lock-screen.json"
  readonly property string backgroundMode: lockBackgroundConfig.backgroundMode
  readonly property string configuredBackgroundPath: lockBackgroundConfig.backgroundPath
  readonly property string fixedPreset: lockBackgroundConfig.fixedPreset
  readonly property url fallbackBackgroundSource: Qt.resolvedUrl(
    LockBackgroundConfig.presetAssetPath(LockBackgroundConfig.defaultFixedPreset()))
  readonly property url primaryBackgroundSource: {
    if (!loadBackground) return ""
    if (backgroundMode === "fixed")
      return Qt.resolvedUrl(LockBackgroundConfig.presetAssetPath(fixedPreset))
    if (backgroundMode === "current") return fileUrl(backgroundPath, backgroundVersion)
    return fileUrl(configuredBackgroundPath, configVersion)
  }

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  function fileUrl(path, version) {
    if (!path) return ""
    var encoded = String(path).split("/").map(encodeURIComponent).join("/")
    return "file://" + encoded + "?v=" + version
  }

  function applyConfig(raw) {
    configRaw = String(raw || "")
    configVersion += 1
  }

  function forcePasswordFocus() {
    passwordField.forcePasswordFocus()
  }

  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  onFailureMessageChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  Component.onCompleted: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  FileView {
    id: configFile
    path: root.configPath
    watchChanges: true
    printErrors: false
    onLoaded: root.applyConfig(text())
    onLoadFailed: root.applyConfig("")
    onFileChanged: reload()
  }

  Components.Background {
    anchors.fill: parent
    primarySource: root.primaryBackgroundSource
    fallbackSource: root.loadBackground ? root.fallbackBackgroundSource : ""
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: {
      root.wakeRequested()
      root.forcePasswordFocus()
    }
    onPositionChanged: root.wakeRequested()
  }

  Item {
    id: stage
    anchors.centerIn: parent
    anchors.verticalCenterOffset: root.mainOffset
    width: Math.min(parent.width - root.safeMargin * 2, 640)
    height: content.implicitHeight

    Column {
      id: content
      width: parent.width
      spacing: Math.round(Math.max(7, Math.min(root.height * 0.013, 16)))

      Components.ClockBlock {
        anchors.horizontalCenter: parent.horizontalCenter
        displayDate: clock.date
        fontSize: root.clockSize
      }

      Rectangle {
        width: Math.round(Math.max(104, Math.min(parent.width * 0.24, 156)))
        height: 1
        radius: 1
        color: Qt.rgba(1, 0.98, 0.94, 0.36)
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Components.DateBlock {
        width: parent.width
        displayDate: clock.date
        weekdaySize: root.weekdaySize
        dateSize: root.dateSize
      }

      Text {
        textFormat: Text.PlainText
        text: "\uf023"
        color: Qt.rgba(0.97, 0.96, 0.94, 0.86)
        font.family: "monospace"
        font.pixelSize: root.lockSize
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        topPadding: Math.round(Math.max(12, Math.min(root.height * 0.02, 22)))
      }

      Components.PasswordField {
        id: passwordField
        fieldWidth: root.passwordWidth
        fieldHeight: root.passwordHeight
        anchors.horizontalCenter: parent.horizontalCenter
        fingerprintConfigured: root.fingerprintConfigured
        authenticatingPassword: root.authenticatingPassword
        failureMessage: root.failureMessage
        inputEnabled: root.previewMode ? false : root.inputEnabled
        passwordText: root.previewMode ? root.previewPasswordText : root.passwordText
        onPasswordTextEdited: function(password) { root.passwordTextEdited(password) }
        onSubmitPassword: function(password) { root.submitPassword(password) }
        onClearFailureRequested: root.clearFailureRequested()
        onWakeRequested: root.wakeRequested()
      }
    }
  }
}

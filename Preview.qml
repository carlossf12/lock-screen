import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
  id: root

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: previewWindow
      required property var modelData

      screen: modelData
      visible: true
      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.namespace: "carlossf12-lock-screen-preview"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      mask: Region {}

      LockView {
        anchors.fill: parent
        previewMode: true
        previewPasswordText: "••••"
        inputEnabled: false
      }
    }
  }
}

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui as Ui
import "LockBackgroundConfig.js" as LockBackgroundConfig

Item {
  id: root

  property var shell: null
  property var service: null
  property var persistedConfig: LockBackgroundConfig.defaultConfig()
  property var draftConfig: LockBackgroundConfig.defaultConfig()
  property var pendingConfig: null
  property bool configReady: false
  property bool pendingOpen: false
  property bool savePending: false
  property bool closingFromHost: false
  property string saveError: ""

  readonly property bool opened: window.visible
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")
  readonly property string configPath: configHome + "/omarchy/carlossf12.lock-screen.json"
  readonly property var draftValidation: LockBackgroundConfig.validateDraft(draftConfig)
  readonly property var presets: LockBackgroundConfig.presetCatalog()

  function copyConfig(config) {
    return {
      backgroundMode: String(config.backgroundMode || "fixed"),
      backgroundPath: String(config.backgroundPath || ""),
      fixedPreset: String(config.fixedPreset || LockBackgroundConfig.defaultFixedPreset())
    }
  }

  function modeLabel(mode) {
    if (mode === "current") return "Current"
    if (mode === "custom") return "Custom"
    return "Fixed"
  }

  function configLabel(config) {
    if (config.backgroundMode === "fixed")
      return "Fixed - " + LockBackgroundConfig.presetLabel(config.fixedPreset)
    return modeLabel(config.backgroundMode)
  }

  function beginEditing() {
    draftConfig = copyConfig(persistedConfig)
    saveError = ""
  }

  function showPanel() {
    beginEditing()
    pendingOpen = false
    closingFromHost = false
    window.visible = true
    Qt.callLater(function() { modeGroup.forceActiveFocus() })
  }

  function open(payloadJson) {
    if (configReady) showPanel()
    else {
      pendingOpen = true
      configFile.reload()
    }
  }

  function close() {
    closingFromHost = true
    pendingOpen = false
    window.visible = false
    beginEditing()
    closingFromHost = false
  }

  function requestClose() {
    if (savePending) return
    if (shell && typeof shell.hide === "function") shell.hide("carlossf12.lock-screen")
    else window.visible = false
  }

  function applyLoadedConfig(raw) {
    persistedConfig = LockBackgroundConfig.normalize(raw)
    configReady = true
    if (!window.visible) draftConfig = copyConfig(persistedConfig)
    if (pendingOpen) showPanel()
  }

  function setDraftMode(mode) {
    draftConfig = {
      backgroundMode: mode,
      backgroundPath: mode === "custom" ? String(draftConfig.backgroundPath || "") : "",
      fixedPreset: String(draftConfig.fixedPreset || LockBackgroundConfig.defaultFixedPreset())
    }
    saveError = ""
  }

  function setDraftPath(path) {
    draftConfig = {
      backgroundMode: "custom",
      backgroundPath: String(path || ""),
      fixedPreset: String(draftConfig.fixedPreset || LockBackgroundConfig.defaultFixedPreset())
    }
    saveError = ""
  }

  function setDraftPreset(presetId) {
    draftConfig = {
      backgroundMode: "fixed",
      backgroundPath: "",
      fixedPreset: String(presetId || "")
    }
    saveError = ""
  }

  function applyDraft() {
    var validation = LockBackgroundConfig.validateDraft(draftConfig)
    if (!validation.valid) {
      saveError = validation.error
      return
    }

    if (LockBackgroundConfig.sameConfig(validation.config, persistedConfig)) {
      draftConfig = copyConfig(validation.config)
      requestClose()
      return
    }

    pendingConfig = copyConfig(validation.config)
    savePending = true
    saveError = ""
    configFile.setText(LockBackgroundConfig.serialize(pendingConfig))
  }

  FileView {
    id: configFile
    path: root.configPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.applyLoadedConfig(text())
    onLoadFailed: root.applyLoadedConfig("")
    onFileChanged: reload()
    onSaved: {
      if (!root.savePending) return
      root.persistedConfig = root.copyConfig(root.pendingConfig)
      root.draftConfig = root.copyConfig(root.persistedConfig)
      root.pendingConfig = null
      root.savePending = false
      root.requestClose()
    }
    onSaveFailed: function(error) {
      root.pendingConfig = null
      root.savePending = false
      root.saveError = "Could not save the wallpaper configuration."
    }
  }

  FloatingWindow {
    id: window
    title: "Lock Screen Background"
    visible: false
    color: Color.background
    implicitWidth: 560
    implicitHeight: 440
    minimumSize: Qt.size(560, 440)
    maximumSize: Qt.size(560, 440)

    onVisibleChanged: {
      if (!visible && !root.closingFromHost && root.shell && typeof root.shell.hide === "function")
        root.shell.hide("carlossf12.lock-screen")
    }

    FocusScope {
      anchors.fill: parent
      focus: true

      Keys.onEscapePressed: root.requestClose()

      Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Style.space(16)
        spacing: Style.space(10)

        Column {
          width: parent.width
          spacing: Style.space(5)

          Text {
            text: "Lock Screen Background"
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.iconLarge
            font.bold: true
          }

          Text {
            text: "Active: " + root.configLabel(root.persistedConfig)
            color: Qt.darker(Color.foreground, 1.35)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }
        }

        Ui.ButtonGroup {
          id: modeGroup
          options: [
            { value: "fixed", label: "Fixed" },
            { value: "current", label: "Current" },
            { value: "custom", label: "Custom" }
          ]
          value: root.draftConfig.backgroundMode
          onChanged: function(value) { root.setDraftMode(value) }
        }

        Text {
          width: parent.width
          visible: root.draftConfig.backgroundMode !== "fixed"
          text: root.draftConfig.backgroundMode === "fixed"
            ? ""
            : (root.draftConfig.backgroundMode === "current"
              ? "Follow desktop wallpaper"
              : "Use another image")
          color: Qt.darker(Color.foreground, 1.3)
          font.family: Style.font.family
          font.pixelSize: Style.font.body
          wrapMode: Text.WordWrap
        }

        Grid {
          id: presetGrid
          anchors.horizontalCenter: parent.horizontalCenter
          width: Math.min(parent.width, 400)
          columns: 2
          spacing: Style.space(8)
          visible: root.draftConfig.backgroundMode === "fixed"

          Repeater {
            model: root.presets

            delegate: Rectangle {
              id: presetCard
              required property var modelData

              readonly property bool selected: root.draftConfig.fixedPreset === modelData.id

              width: (presetGrid.width - presetGrid.spacing) / 2
              height: width * 9 / 16
              radius: 6
              color: Color.background
              border.width: selected ? 3 : 1
              border.color: selected ? Color.accent : Qt.rgba(1, 1, 1, 0.24)
              clip: true

              Image {
                anchors.fill: parent
                anchors.margins: presetCard.border.width
                source: Qt.resolvedUrl(presetCard.modelData.assetPath)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
              }

              Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: presetCard.border.width
                height: Style.space(28)
                color: Qt.rgba(0.02, 0.03, 0.05, 0.78)

                Text {
                  anchors.fill: parent
                  anchors.leftMargin: Style.space(8)
                  anchors.rightMargin: Style.space(8)
                  text: presetCard.modelData.label
                  color: presetCard.selected ? Color.accent : "white"
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  font.bold: presetCard.selected
                  verticalAlignment: Text.AlignVCenter
                  elide: Text.ElideRight
                }
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.setDraftPreset(presetCard.modelData.id)
              }
            }
          }
        }

        Column {
          width: parent.width
          spacing: Style.space(7)
          visible: root.draftConfig.backgroundMode === "custom"

          Text {
            text: "Custom path"
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }

          Ui.TextField {
            id: pathField
            width: parent.width
            text: root.draftConfig.backgroundPath
            placeholderText: "/absolute/path/to/image.jpg"
            activeFocusOnTab: true
            onTextEdited: root.setDraftPath(text)
          }
        }

        Text {
          width: parent.width
          visible: root.saveError !== ""
          text: root.saveError
          color: Color.urgent
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          wrapMode: Text.WordWrap
        }

      }

      Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Style.space(16)
        spacing: Style.space(10)

        Ui.Button {
          text: "Cancel"
          bordered: true
          focusable: true
          enabled: !root.savePending
          onClicked: root.requestClose()
        }

        Ui.Button {
          text: root.savePending ? "Applying..." : "Apply"
          bordered: true
          selected: true
          focusable: true
          enabled: root.draftValidation.valid && !root.savePending
          onClicked: root.applyDraft()
        }
      }
    }
  }
}

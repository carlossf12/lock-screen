import QtQuick
import QtQuick.Effects

Item {
  id: root

  property url primarySource: ""
  property url fallbackSource: ""
  property bool primaryFailed: false

  readonly property url effectiveSource: primarySource && !primaryFailed ? primarySource : fallbackSource

  onPrimarySourceChanged: primaryFailed = false

  Rectangle {
    anchors.fill: parent
    color: "#080b10"
  }

  Image {
    id: wallpaper
    anchors.fill: parent
    source: root.effectiveSource
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: true
    sourceSize.width: width
    sourceSize.height: height
    onStatusChanged: {
      if (status === Image.Error && root.primarySource && !root.primaryFailed && root.primarySource !== root.fallbackSource)
        root.primaryFailed = true
    }
  }

  MultiEffect {
    anchors.fill: wallpaper
    source: wallpaper
    autoPaddingEnabled: false
    blurEnabled: wallpaper.status === Image.Ready
    blur: 0.46
    blurMax: 64
    blurMultiplier: 0.58
    brightness: -0.04
    contrast: -0.04
    saturation: 0.9
  }

  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(0.02, 0.027, 0.043, 0.44)
  }

  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: parent.height * 0.34
    gradient: Gradient {
      GradientStop { position: 0.0; color: Qt.rgba(0.008, 0.012, 0.024, 0.6) }
      GradientStop { position: 1.0; color: Qt.rgba(0.008, 0.012, 0.024, 0.0) }
    }
  }

  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    height: parent.height * 0.42
    gradient: Gradient {
      GradientStop { position: 0.0; color: Qt.rgba(0.008, 0.012, 0.024, 0.0) }
      GradientStop { position: 1.0; color: Qt.rgba(0.008, 0.012, 0.024, 0.7) }
    }
  }
}

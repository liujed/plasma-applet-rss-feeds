import QtQuick 2.15
import QtQml.XmlListModel
import QtQuick.Controls

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

Item {
  id: window
  width: 300
  height: 500

  property var url: plasmoid.configuration.url
  property int refresh: 1000 * plasmoid.configuration.refresh
  property var headerColor: plasmoid.configuration.headerColor
  property var listOpacity: plasmoid.configuration.listOpacity

  function stripString (str) {
    var regex = /(<img.*?>)/gi;
    str = str.replace(regex, "");
    regex = /&#228;/gi;
    str = str.replace(regex, "ä");
    regex = /&#246;/gi;
    str = str.replace(regex, "ö");
    regex = /&#252;/gi;
    str = str.replace(regex, "ü");
    regex = /&#196;/gi;
    str = str.replace(regex, "Ä");
    regex = /&#214;/gi;
    str = str.replace(regex, "Ö");
    regex = /&#220;/gi;
    str = str.replace(regex, "Ü");
    regex = /&#223;/gi;
    str = str.replace(regex, "ß");

    return str;
  }

  XmlListModel {
    id: xmlModel
    source: url
    query: "/rss/channel/item"

    XmlListModelRole { name: "title"; elementName: "title" }
    XmlListModelRole { name: "pubDate"; elementName: "pubDate" }
    XmlListModelRole { name: "description"; elementName: "description" }
    XmlListModelRole { name: "link"; elementName: "link" }

    onStatusChanged: busyIndicator.isBusy = true
  }

  Component {
    id: feedDelegate
    Rectangle {
      height: layout.height
      width: thefeed.width
      color: PlasmaCore.Theme.viewBackgroundColor
      Component.onCompleted: busyIndicator.isBusy = false

      Item {
        height: layout.height
        width: thefeed.width

        Column {
          id: layout
          Row {
            Text {
              width: thefeed.width
              wrapMode: Text.WordWrap
              font.pixelSize: 12
              color: PlasmaCore.Theme.textColor
              font.bold: true
              text: title
            }
          }
          Row {
            Text {
              width: thefeed.width
              wrapMode: Text.WordWrap
              font.pixelSize: 9
              color: headerColor
              font.bold: false
              text: pubDate
            }
          }
          Row {
            Text {
              width: thefeed.width
              wrapMode: Text.WordWrap
              font.pixelSize: 12
              color: PlasmaCore.Theme.textColor
              font.bold: false
              text: stripString(description)
            }
          }
          Row {
            Rectangle {
              width: thefeed.width
              color: PlasmaCore.Theme.textColor
              height: 1
            }
          }
        }

        MouseArea {
          acceptedButtons: Qt.LeftButton
          anchors.fill: parent
          onClicked: {
            Qt.openUrlExternally(link)
          }
        }
      }
    }
  }

  Component {
    id: header
    Rectangle {
      width: thefeed.width
      height: 19
      color: PlasmaCore.Theme.viewBackgroundColor
      Item {
        width: thefeed.width
        height: 19
        Text {
          horizontalAlignment: Text.AlignRight
          width: thefeed.width
          height: 8
          font.pixelSize: 9
          text: url
          color: headerColor
        }

        Rectangle {
          y: 11
          width: thefeed.width
          height: 8
          color: headerColor
        }
      }
    }
  }

  Component {
    id: footer
    Rectangle {
      width: thefeed.width
      height: 8
      color: headerColor
    }
  }

  ListView {
    id: thefeed
    opacity: listOpacity / 100
    maximumFlickVelocity: 2500
    clip: true
    width: parent.width-20
    anchors.fill: parent
    spacing: 2
    model: xmlModel
    delegate: feedDelegate
    header: header
    footer: footer
    snapMode: ListView.SnapToItem
  }

  Item {
    id: busyIndicator
    property bool isBusy: true
    property var animate: plasmoid.configuration.animateBusyIndicator

    onAnimateChanged: updateIndicator()
    onIsBusyChanged: updateIndicator()

    anchors.centerIn: parent

    function updateIndicator() {
      animated.running = isBusy && animate
      icon.visible = isBusy && !animate
    }

    BusyIndicator {
      id: animated
      running: isBusy && animate
      anchors.centerIn: parent
    }

    Kirigami.Icon {
      id: icon
      source: "view-refresh"
      anchors.centerIn: parent
      width: animated.width
      height: width
    }
  }

  Timer {
    id: refreshTimer
    interval: refresh
    running: true
    repeat: true
    onTriggered: { xmlModel.reload() }
  }

  Plasmoid.contextualActions: [
    PlasmaCore.Action {
      text: i18n("Refresh")
      icon.name: "view-refresh"
      onTriggered: xmlModel.reload()
    }
  ]
}

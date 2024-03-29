import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
  property alias cfg_refresh: refresh.value
  property alias cfg_url: url.text
  property alias cfg_headerColor: headerColorDialog.selectedColor
  property alias cfg_listOpacity: listOpacity.value

  GridLayout {
    id: generalConfig
    Layout.fillWidth: true
    rowSpacing: 10
    columnSpacing: 10
    columns: 2

    Text {
      text: "Reload time (seconds)"
    }
    SpinBox {
      id: refresh
      from: 1
      to: 1800
    }
    Text {
      text: "URL"
    }
    TextField {
      id: url
      Layout.fillWidth: true
      Layout.minimumWidth: 400
      placeholderText: "http://www.faz.net/rss/aktuell/"
    }

    Text {
      text: "Header Color"
    }
    Rectangle {
      id: headerColor
      width: 50
      height: 17
      color: headerColorDialog.selectedColor
      border.color: "black"
      border.width: 1
      radius: 0
      MouseArea{
        anchors.fill: parent
        onClicked: { headerColorDialog.open() }
      }
    }

    Text {
      text: "Opacity"
    }
    SpinBox {
      id: listOpacity
      from: decimalToInt(0)
      to: decimalToInt(1)
      value: decimalToInt(0.85)
      stepSize: decimalToInt(0.05)

      property int decimals: 2
      property real realValue: value / decimalFactor
      readonly property int decimalFactor: Math.pow(10, decimals)

      function decimalToInt(decimal) {
        return decimal * decimalFactor
      }

      validator: DoubleValidator {
        bottom: listOpacity.from
        top: listOpacity.to
        decimals: listOpacity.decimals
        notation: DoubleValidator.StandardNotation
      }

      textFromValue: function(value, locale) {
        return Number(value / decimalFactor).toLocaleString(locale, 'f', decimals)
      }

      valueFromText: function(value, locale) {
        return Math.round(Number.fromLocaleString(locale, text) * decimalFactor)
      }
    }
  }

  ColorDialog {
    id: headerColorDialog
    title: "Please choose a header color"
    selectedColor: "Steel Blue"
    onAccepted: headerColor.color = selectedColor
  }
}

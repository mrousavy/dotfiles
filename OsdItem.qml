/*
 * This QML file replaces the look of the default
 * KDE/KWin On-Screen-Display (OSD) for Volume or
 * Brightness adjustments.
 * Instead of a big square, this displays as a
 * sleek bar showing only icon (volume or
 * brightness) and the actual value as a bar.
 *
 * This adjustment was written by Zren
 * Source: https://reddit.com/r/kde/comments/5zyd1a/i_hate_the_new_volume_osd/df24wg0/
 * 
 * This file should replace the file in
 * /usr/share/plasma/look-and-feel/org.kde.breeze.desktop/contents/osd/OsdItem.qml
 */

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtra
import QtQuick.Window 2.2

Row {
    property QtObject rootItem

    property int iconWidth: units.iconSizes.medium
    property int progressBarWidth: Screen.desktopAvailableWidth / 5

    height: iconWidth
    width: iconWidth + progressBarWidth

    PlasmaCore.IconItem {
        id: icon

        height: parent.height
        width: iconWidth

        source: rootItem.icon
    }

    PlasmaComponents.ProgressBar {
        id: progressBar

        width: progressBarWidth
        height: parent.height

        visible: rootItem.showingProgress
        minimumValue: 0
        maximumValue: 100

        value: Number(rootItem.osdValue)
    }

    PlasmaExtra.Heading {
        id: label

        width: progressBarWidth
        height: parent.height

        visible: !rootItem.showingProgress
        text: rootItem.showingProgress ? "" : (rootItem.osdValue ? rootItem.osdValue : "")
        horizontalAlignment: Text.AlignHCenter
        maximumLineCount: 1
        elide: Text.ElideLeft
        minimumPointSize: theme.defaultFont.pointSize
        fontSizeMode: Text.Fit
    }
}

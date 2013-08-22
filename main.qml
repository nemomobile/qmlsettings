/*
 * Copyright (C) 2013 Robin Burchell <robin+mer@viroteck.net>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 2.0
import com.nokia.meego 2.0

PageStackWindow {
    id: rootWindow

    Component.onCompleted: theme.inverted = true

    initialPage: ListPage {
        headerText: "Settings"
        header: Item {
            width: parent.width
            height: applets.height + UiConstants.DefaultMargin * 2
            Column {
                id: applets
                y: UiConstants.DefaultMargin
                x: UiConstants.DefaultMargin
                width: parent.width - UiConstants.DefaultMargin * 2
                spacing: UiConstants.DefaultMargin

                WirelessApplet { }
                BrightnessApplet { }
            }
        }

        model: ListModel {
            ListElement {
                page: "connectivity/ConnectivitySettings.qml"
                title: "Connectivity"
                subtitle: "Connect to networks and devices"
                iconSource: "image://theme/icon-m-common-wlan"
            }

            ListElement {
                page: "accounts/AccountSettings.qml"
                title: "Accounts"
                subtitle: "Use services you know and love"
                iconSource: "image://theme/icon-m-settings-account"
            }

            ListElement {
                page: "timedate/TimeAndDateSettings.qml"
                title: "Time & Date"
                subtitle: "Change system time and date"
                iconSource: "image://theme/icon-m-settings-time-date"
            }

            ListElement {
                page: "usb/USBModeSettings.qml"
                title: "USB mode"
                subtitle: "Choose what USB does"
                iconSource: "image://theme/nemo-cp-power-usb"
            }

            ListElement {
                page: "aboutdevice/AboutDeviceSettings.qml"
                title: "About my device"
                subtitle: "Information about your device"
                iconSource: "image://theme/icon-m-settings-description"
            }
        }
    }

    // These tools are shared by most sub-pages by assigning the id to a page's tools property
    ToolBarLayout {
        id: commonTools
        visible: false
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop(); } }
    }
}


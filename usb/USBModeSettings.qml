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

import QtQuick 1.1
import com.nokia.meego 1.2
import org.nemomobile.systemsettings 1.0
import ".."

Page {
    tools: commonTools

    ContextMenu {
        id: contextMenu
        MenuLayout {
            MenuItem {
                text: "Default mode: ask"
                onClicked: usbSettings.defaultMode = USBSettings.AskMode
            }
            MenuItem {
                text: "Default mode: mass storage"
                onClicked: usbSettings.defaultMode = USBSettings.MassStorageMode
            }
            MenuItem {
                text: "Default mode: developer mode"
                onClicked: usbSettings.defaultMode = USBSettings.DeveloperMode
            }
            MenuItem {
                text: "Default mode: MTP"
                onClicked: usbSettings.defaultMode = USBSettings.MTPMode
            }
            MenuItem {
                text: "Default mode: charging only"
                onClicked: usbSettings.defaultMode = USBSettings.ChargingMode
            }
        }
    }

    USBSettings {
        id: usbSettings
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: childrenRect.height
        anchors.margins: UiConstants.DefaultMargin

        Column {
            anchors.fill: parent
            spacing: UiConstants.DefaultMargin

            Label {
                text: {
                    switch (usbSettings.currentMode) {
                        case USBSettings.MassStorageMode:
                            return "Mass storage in use"
                        case USBSettings.DeveloperMode:
                            return "Developer mode in use"
                        case USBSettings.MTPMode:
                            return "Media Transfer Protocol mode in use"
                        case USBSettings.ChargingMode:
                            return "Charging only"
                    }
                }
            }

            Button {
                width: parent.width
                text: {
                    switch (usbSettings.defaultMode) {
                    case USBSettings.AskMode:
                        return "Default mode: ask"
                    case USBSettings.MassStorageMode:
                        return "Default mode: mass storage"
                    case USBSettings.DeveloperMode:
                        return "Default mode: developer mode"
                    case USBSettings.MTPMode:
                        return "Default mode: MTP"
                    case USBSettings.ChargingMode:
                        return "Default mode: charging only"
                    }
                }

                onClicked: {
                    contextMenu.open()
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: flickable
    }
}


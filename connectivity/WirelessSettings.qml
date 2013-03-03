/*
 * Copyright (C) 2013 Robin Burchell <robin+mer@viroteck.net>
 * Copyright (C) 2012 Jolla Ltd. <dmitry.rozhkov@jollamobile.com>
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
import com.meego.extras 1.0
import MeeGo.Connman 0.2
import ".."

Page {
    id: mainWindow
    tools: commonTools

    property variant netfields: {}

    function handleInput(key, value) {
        var dict = mainWindow.netfields;
        var isDoneEnabled = false;
        console.log("Received from TextField " + key + " " + value);
        dict[key] = value;
        mainWindow.netfields = dict;
        for (var id in mainWindow.netfields) {
            console.log(id + "-> " + mainWindow.netfields[id]);
            isDoneEnabled = isDoneEnabled || mainWindow.netfields[id].length;
        }
        doneButton.enabled = isDoneEnabled;
    }

    Timer {
        id: scanTimer
        interval: 25000
        running: networkingModel.powered
        repeat: true
        triggeredOnStart: true
        onTriggered: networkingModel.requestScan();
    }

    TechnologyModel {
        id: networkingModel
        name: "wifi"
        property bool sheetOpened
        property string networkName

        onTechnologiesChanged: {
            scanTimer.running = networkingModel.powered;
        }

        onPoweredChanged: {
            scanTimer.running = networkingModel.powered;
        }
    }

    UserAgent {
        id: userAgent
        onUserInputRequested: {
            scanTimer.running = false;
            scanTimer.triggeredOnStart = false;
            console.log("USER INPUT REQUESTED");
            var view = {
                "fields": []
            };
            for (var key in fields) {
                view.fields.push({
                    "name": key,
                    "id": key.toLowerCase(),
                    "type": fields[key]["Type"],
                    "requirement": fields[key]["Requirement"]
                });
                console.log(key + ":");
                for (var inkey in fields[key]) {
                    console.log("    " + inkey + ": " + fields[key][inkey]);
                }
            }
            if (!sheetOpened) {
                sheetOpened = true
                var sheet = pageStack.openSheet(Qt.resolvedUrl("NetworkSettings.qml"), { mustacheView: view, networkName: networkName })
                sheet.accepted.connect(function() { sheetOpened = false })
                sheet.rejected.connect(function() { sheetOpened = false })
                // TODO: there was code that checked for pageStack.busy and
                // didn't open if it was true. What was that about?
            }
        }

        onUserInputCanceled: {
            // TODO
            console.log("UserAgent::onUserInputCanceled: not handled");
        }

        onErrorReported: {
            console.log("Got error from model: " + error);
            if (error == "invalid-key") {
                mainpageNotificationBanner.text = "Incorrect value entered. Try again."
            } else {
                mainpageNotificationBanner.text = "Connect failed"
            }
            mainpageNotificationBanner.show()
        }
    }

    ViewPlaceholder {
        enabled: !networkingModel.available || networkList.count == 0
        text: !networkingModel.available ? "Wireless networking unavailable" : "No wireless networks in range"
    }

    ListView {
        id: networkList
        header: WirelessApplet { }
        anchors.margins: UiConstants.DefaultMargin
        anchors.fill: parent
        model: networkingModel
        delegate: ListDelegate {
            iconSource: {
                var strength = modelData.strength;
                var str_id = 0;

                if (strength >= 59) {
                    str_id = 5;
                } else if (strength >= 55) {
                    str_id = 4;
                } else if (strength >= 50) {
                    str_id = 3;
                } else if (strength >= 45) {
                    str_id = 2;
                } else if (strength >= 30) {
                    str_id = 1;
                }
                return "image://theme/icon-m-common-wlan-strength" + str_id;
            }

            titleText: modelData.name ? modelData.name : "(hidden network)"
            subtitleText: {
                var state = modelData.state;
                var security = modelData.security[0];

                if ((state == "online") || (state == "ready")) {
                    return "connected";
                } else if (state == "association" || state == "configuration") {
                    return "connecting...";
                } else {
                    if (security == "none") {
                        return "open";
                    } else {
                        return "secure";
                    }
                }
            }

            // TODO: subtitleColor / subtitleColorPressed bindings
            // depending on state like in old delegate?
            onClicked: {
                console.log("clicked " + modelData.name);
                if (modelData.state == "idle" || modelData.state == "failure") {
                    modelData.requestConnect();
                    networkingModel.networkName.text = modelData.name;
                } else {
                    console.log("Show network status page");
                    for (var key in modelData.ipv4) {
                        console.log(key + " -> " + modelData.ipv4[key]);
                    }

                    pageStack.openDialog(Qt.resolvedUrl("SettingsSheet.qml"), { network: modelData })
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: networkList
    }

    InfoBanner {
        id: mainpageNotificationBanner
    }
}



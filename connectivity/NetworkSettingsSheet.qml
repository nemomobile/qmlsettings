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

Sheet {
    id: networkPage
    property string mustacheView

    onRejected: {
        networkingModel.sendUserReply({});
        pageStack.pop()
        scanTimer.running = true;
    }

    onAccepted: {
        console.log('clicked Done ' + 'x:' + x + ' y:' + y);
        var fields = mainWindow.netfields;
        for (var key in fields) {
            console.log(key + " --> " + fields[key]);
        }
        pageStack.pop()
        scanTimer.running = true;
        networkingModel.sendUserReply(fields);
    }

    content: Column {
        spacing: 10
        anchors.fill: parent
        Label {
            anchors { left: parent.left; leftMargin: 10 }
            text: "Sign in to secure Wi-Fi network"
        }
        Label {
            id: networkName
            anchors { left: parent.left; leftMargin: 10 }
        }
        Item {
            height: 30
        }
        Item {
            id: dynFields
            width: parent.width
            height: 200
            property string form_tpl: "
                import QtQuick 1.1
                import com.nokia.meego 1.0
                Item {
                    id: form
                    anchors { fill: parent; margins: 10 }
                    Column {
                        spacing: 5
                        anchors { fill: parent }
                        {{#fields}}
                        Text {
                            text: '{{name}}'
                            color: 'white'
                            font.pointSize: 14
                        }
                        TextField {
                            id: {{id}}
                            signal send (string key, string value)
                            anchors { left: parent.left; right: parent.right }
                            placeholderText: 'enter {{name}}'
                            Component.onCompleted: {
                                {{id}}.send.connect(handleInput);
                            }
                            onTextChanged: {
                                console.log('Sending from TextField {{id}}' + {{id}}.text);
                                {{id}}.send('{{name}}', {{id}}.text);
                            }
                        }
                        {{/fields}}
                    }
                }
            "
            Component.onCompleted: {
                // TODO: can we replace mustache with just regular old bindings?
                var output = M.Mustache.render(form_tpl, mustacheView);
                var form = Qt.createQmlObject(output, dynFields, "dynamicForm1");
            }
        }
    }
}



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
import com.nokia.extras 1.0
import org.nemomobile.accounts 1.0
import ".."

Sheet {
    id: sheet
    acceptButtonText: "Create"
    rejectButtonText: "Cancel"
    state: "stageOne"

    property AccountModel accountModel
    property variant provider: accountModel.provider(selectedProvider)
    property string selectedProvider

    // Stage one: pick a provider
    ListView {
        opacity: sheet.state == "stageOne" ? 1.0 : 0.0
        anchors.fill: parent
        anchors.margins: UiConstants.DefaultMargin
        model: AccountProviderModel { }
        delegate: ListDelegate {
            iconSource: model.providerIcon
            titleText: model.providerDisplayName
            onClicked: {
                sheet.selectedProvider = model.providerName
                sheet.state = "stageTwo"
            }
        }
    }

    Connections {
        target: sheet
        onStateChanged: {
            if (sheet.state == "stageTwo") {
                var componentFileName = "file:///usr/share/accounts/ui/" + provider.name + ".qml"
                var comp = Qt.createComponent(componentFileName)
                // TODO: cleanup
                if (comp.status === Component.Ready) {
                    var newsheet = comp.createObject(root, {
                            "provider": provider
                    })
                    if (newsheet === null) {
                        throw new Error("Error: cannot load instance of " + componentFileName + ":" + comp.errorString())
                    }
                    newsheet.open()
                } else {
                    throw new Error("Error: cannot load component file " + componentFileName + ":" + comp.errorString())
                }
            }
        }
    }
}

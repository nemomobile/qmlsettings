/*
 * Copyright (C) 2013 Jolla Ltd. <robin.burchell@jollamobile.com>
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
import org.nemomobile.accounts 1.0
import org.nemomobile.signon 1.0

Sheet {
    id: root

    acceptButtonText: "Save"
    rejectButtonText: "Reject"

    property int accountId: 0
    property Provider provider

    property string name: provider.displayName
    property string iconSource: provider.iconName

    property string __defaultServiceName: provider.serviceNames[0]
    property bool __isNewAccount: accountId == 0

    property Account account: Account {
        identifier: root.accountId
        providerName: root.accountId != 0 ? "" : provider.name

        onStatusChanged: {
            if (status === Account.Initialized && !root.__isNewAccount) {
                incomingUsernameField.text = account.displayName // we save the username in the display name.
                identity.identifier = account.identityIdentifier(root.__defaultServiceName) // if zero, will create new identity.
            } else if (status === Account.Synced) {
                // success
                root.accountId = account.identifier
            } else if (status === Account.Error) {
                // XXX display "error" dialog?
                console.log("Jabber provider account error:", errorMessage)
                root.reject()
            }
        }
    }

    property Identity identity: Identity {
        identifier: root.accountId ? account.identityIdentifier(root.__defaultServiceName) : 0
        identifierPending: root.accountId != 0

        onStatusChanged: {
            if (status === Identity.Initialized) {
                incomingUsernameField.text = userName
                incomingPasswordField.text = secret
            } else if (status === Identity.Synced) {
                account.displayName = incomingUsernameField.text
                for (var i in provider.serviceNames) {
                    account.enableWithService(provider.serviceNames[i])
                    account.setIdentityIdentifier(identity.identifier, provider.serviceNames[i])
                }
                account.sync()
            } else if (status === Identity.Error) {
                // XXX display "error" dialog?
                console.log("Jabber provider identity error:", errorMessage)
                root.reject()
            }
        }
    }

    Flickable {
        id: flickable

        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn

            spacing: UiConstants.DefaultMargin
            width: parent.width

            Item {
                width: parent.width
                height: theme.itemSizeSmall
                x: UiConstants.DefaultMargin

                Image {
                    id: icon
                    width: 64
                    height: 64
                    anchors.verticalCenter: parent.verticalCenter
                    source: root.iconSource
                }
                Label {
                    anchors.left: icon.right
                    anchors.leftMargin: UiConstants.DefaultMargin
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.name
                }
            }

            TextField {
                id: incomingUsernameField
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase
                placeholderText: "Username"
            }

            TextField {
                id: incomingPasswordField
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password
                placeholderText: "Password"
            }

            /* TODO: server address and port customisation
             * mostly just need to figure out how to tell the identity about it
             */
        }
    }

    onAccepted: {
        identity.userName = incomingUsernameField.text
        identity.secret = incomingPasswordField.text

        identity.sync()

    }

    onRejected: {
        // if this is a new account, delete the account
        if (root.accountId === 0) {
            if (identity.status === Identity.Initialized) {
                identity.remove()
            }
            if (account.status === Account.Initialized) {
                account.remove()
            }
        }
    }
}


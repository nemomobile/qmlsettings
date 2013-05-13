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

import QtQuick 1.1
import com.nokia.meego 1.0
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

    property bool smtpUsernameEdited: false
    property bool smtpPasswordEdited: false

    anchors.fill: parent

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
                console.log("Generic email provider account error:", errorMessage)
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
                console.log("Generic email provider identity error:", errorMessage)
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

            Button {
                id: serverType
                width:  parent.width
                text: "Incoming server type"
                property alias currentIndex: serverTypeDialog.selectedIndex

                SelectionDialog {
                    id: serverTypeDialog
                    titleText: serverType.text

                    model: ListModel {
                        ListElement { name: "IMAP4" }
                        ListElement { name: "POP3" }
                    }
                }

                onClicked: serverTypeDialog.open()
            }

            TextField {
                id: incomingUsernameField
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase
                placeholderText: "Incoming server username"
                onTextChanged: {
                    if(!smtpUsernameEdited) {
                        smtpUsernameField.text = text
                    }
                }
            }

            TextField {
                id: incomingPasswordField
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password
                placeholderText: "Incoming server password"
                onTextChanged: {
                    if(!smtpPasswordEdited) {
                        smtpPasswordField.text = text
                    }
                }
            }

            TextField {
                id: incomingServerField
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase
                placeholderText: "Incoming server address"
            }

            Button {
                id: incomingSecureConnection
                width:  parent.width
                text: "Secure connection"
                property alias currentIndex: incomingSecureConnectionDialog.selectedIndex

                SelectionDialog {
                    id: incomingSecureConnectionDialog
                    titleText: incomingSecureConnection.text

                    model: ListModel {
                        ListElement {
                            name: "None"
                        }
                        ListElement { name: "SSL" }
                        ListElement { name: "TLS" }
                    }
                }

                onClicked: incomingSecureConnectionDialog.open()
            }

            TextField {
                id: incomingPortField
                width: parent.width
                inputMethodHints: Qt.ImhDigitsOnly
                placeholderText: "Incoming server port"
            }

            TextField {
                id: smtpUsernameField
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase
                placeholderText: "Outgoing server username"

                //solution for faster input, since most accounts have same credentials for
                //username and password
                //this can go away if we get a initial page for username/password, depends on design
                onTextChanged: {
                    if(focus)
                        smtpUsernameEdited = true
                }
            }

            TextField {
                id: smtpPasswordField
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password
                placeholderText: "Outgoing server password"
                onTextChanged: {
                    if(focus)
                        smtpPasswordEdited = true
                }
            }

            TextField {
                id: smtpServerField
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase
                placeholderText: "Outgoing server address"
            }

            Button {
                id: smtpSecureConnection
                width:  parent.width
                text: "Secure connection"
                property alias currentIndex: smtpSecureConnectionDialog.selectedIndex

                SelectionDialog {
                    id: smtpSecureConnectionDialog
                    titleText: smtpSecureConnection.text

                    model: ListModel {
                        ListElement { name: "None" }
                        ListElement { name: "SSL" }
                        ListElement { name: "TLS" }
                    }
                }

                onClicked: smtpSecureConnectionDialog.open()
            }

            TextField {
                id: smtpPortField
                width: parent.width
                inputMethodHints: Qt.ImhDigitsOnly
                placeholderText: "Outgoing server port"
            }

            Button {
                id: smtpAuthentication
                width: parent.width
                text: "Authentication"

                SelectionDialog {
                    id: smtpAuthenticationDialog
                    titleText: smtpAuthentication.text

                    model: ListModel {
                        ListElement {
                            name: "None"
                        }
                        ListElement {
                            name: "Password"
                        }
                        ListElement {
                            name: "Encrypted Password"
                        }
                    }
                }

                onClicked: smtpAuthenticationDialog.open()
            }
        }
    }

    onAccepted: {
        identity.userName = incomingUsernameField.text
        identity.secret = incomingPasswordField.text
        //change to username depending on the design
        account.setConfigurationValue("emailaddress", incomingUsernameField.text, __defaultServiceName)

        //this should go to the service file
        account.setConfigurationValue("type", "8", __defaultServiceName)

        if(serverType.currentIndex == 0) {
            account.setConfigurationValue("imap4/password", incomingPasswordField.text, __defaultServiceName)
            account.setConfigurationValue("imap4/username", incomingUsernameField.text, __defaultServiceName)
            account.setConfigurationValue("imap4/server", incomingServerField.text, __defaultServiceName)
            account.setConfigurationValue("imap4/port", incomingPortField.text, __defaultServiceName)
            account.setConfigurationValue("imap4/encryption", incomingSecureConnection.currentIndex, __defaultServiceName)
            account.setConfigurationValue("imap4/pushCapable", 0, __defaultServiceName)
            account.setConfigurationValue("imap4/checkInterval", 0, __defaultServiceName)
            account.setConfigurationValue("imap4/servicetype", "source", __defaultServiceName)
        }
        else {
            account.setConfigurationValue("pop3/password", incomingPasswordField.text, __defaultServiceName)
            account.setConfigurationValue("pop3/username", incomingUsernameField.text, __defaultServiceName)
            account.setConfigurationValue("pop3/server", incomingServerField.text, __defaultServiceName)
            account.setConfigurationValue("pop3/port", incomingPortField.text, __defaultServiceName)
            account.setConfigurationValue("pop3/encryption", incomingSecureConnection.currentIndex, __defaultServiceName)
            account.setConfigurationValue("pop3/servicetype", "source", __defaultServiceName)
        }

        account.setConfigurationValue("smtp/smtppassword", smtpPasswordField.text, __defaultServiceName)
        account.setConfigurationValue("smtp/smtpusername", smtpUsernameField.text, __defaultServiceName)
        //change to username depending on the design
        account.setConfigurationValue("smtp/address", smtpUsernameField.text, __defaultServiceName)
        account.setConfigurationValue("smtp/server", smtpServerField.text, __defaultServiceName)
        account.setConfigurationValue("smtp/port", smtpPortField.text, __defaultServiceName)
        account.setConfigurationValue("smtp/encryption", smtpSecureConnection.currentIndex, __defaultServiceName)
        account.setConfigurationValue("smtp/authentication", smtpAuthentication.currentIndex, __defaultServiceName)
        account.setConfigurationValue("smtp/servicetype", "sink", __defaultServiceName)

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


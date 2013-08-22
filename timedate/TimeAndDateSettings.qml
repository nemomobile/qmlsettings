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
import org.nemomobile.time 1.0
import org.nemomobile.systemsettings 1.0
import ".."

Page {
    tools: commonTools

    WallClock {
        id: wallClock
        updateFrequency: WallClock.Minute
    }

    DateTimeSettings {
        id: dateTimeSettings
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: childrenRect.height

        Column {
            anchors.fill: parent

            AutomaticTimeUpdateApplet {
                id: autoTimeUpdate
                x: UiConstants.DefaultMargin
                width: parent.width - UiConstants.DefaultMargin * 2
            }

            DrilldownDelegate {
                titleText: "Time"
                subtitleText: Qt.formatTime(wallClock.time)
                enabled: !autoTimeUpdate.enabled

                onClicked: {
                    timePicker.hour = wallClock.time.getHours()
                    timePicker.minute = wallClock.time.getMinutes()
                    timePicker.second = wallClock.time.getSeconds()
                    timePicker.open()
                }
            }

            DrilldownDelegate {
                titleText: "Date"
                subtitleText: Qt.formatDate(wallClock.time)
                enabled: !autoTimeUpdate.enabled

                onClicked: {
                    datePicker.day = wallClock.time.getDate()
                    datePicker.month = wallClock.time.getMonth() + 1
                    datePicker.year = wallClock.time.getFullYear()
                    datePicker.open()
                }
            }
        }
    }
    ScrollDecorator {
        flickableItem: flickable
    }

    TimePickerDialog {
        id: timePicker
        titleText: "Set device time"
        onAccepted: {
            dateTimeSettings.setTime(timePicker.hour, timePicker.minute)
        }
    }

    DatePickerDialog {
        id: datePicker
        titleText: "Set device date"
        onAccepted: {
            dateTimeSettings.setDate(new Date(datePicker.year, datePicker.month - 1, datePicker.day))
        }
    }
}

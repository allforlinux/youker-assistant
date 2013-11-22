/*
 * Copyright (C) 2013 National University of Defense Technology(NUDT) & Kylin Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 1.1
import SessionType 0.1
import SystemType 0.1
import "common" as Common

Item {
    id:root
    width: parent.width
    height: 435//420//340
    property string btn_text: qsTr("Start scanning")//开始扫描
    property string title: qsTr("Clean history, and protect personal privacy")//清理历史记录,保护个人隐私
    property string description: qsTr("Clean up browser record and system opened documents recently")//清理浏览器上网记录和系统最近打开文件记录
    property string btn_flag: "history_scan"
    property string btn_flag2: "system_scan"
    property string work_result: ""
    property string keypage: "history"
    property int browserstatus_num: 0
    property int systemstatus_num: 0
    //母项字体
    property string headerItemFontName: "Helvetica"
    property int headerItemFontSize: 12
    property color headerItemFontColor: "black"
    property bool check_flag: true
    property bool null_flag: false
    property bool null_flag2: false
    //获取数据
    function getData(history_msg) {
        if (history_msg == "BrowserWork") {
            root.browserstatus_num = sessiondispatcher.scan_history_records_qt();
            if (root.browserstatus_num == 0) {
                root.null_flag = true;
                internetBtnRow.state = "BrowserWorkEmpty";
                //友情提示      扫描内容为空，不再执行清理！
                sessiondispatcher.showWarningDialog(qsTr("Tips:"), qsTr("Scanning content is empty, no longer to perform cleanup!"), mainwindow.pos.x, mainwindow.pos.y);
            }
            else {
                root.null_flag = false;
                internetBtnRow.state = "BrowserWork";
                toolkits.alertMSG(qsTr("Scan completed!"), mainwindow.pos.x, mainwindow.pos.y);//扫描完成！
                internetcacheBtn.text = qsTr("Start cleaning");//开始清理
                root.btn_flag = "history_work";
                browserstatus_label.visible = true;
                internetbackBtn.visible = true;
                internetrescanBtn.visible = true;
            }
        }
        else if (history_msg == "SystemWork") {
            root.systemstatus_num = sessiondispatcher.scan_system_history_qt();
            if (root.systemstatus_num == 0) {
                root.null_flag2 = true;
                fileBtnRow.state = "SystemWorkEmpty";
                //友情提示      扫描内容为空，不再执行清理！
                sessiondispatcher.showWarningDialog(qsTr("Tips:"), qsTr("Scanning content is empty, no longer to perform cleanup!"), mainwindow.pos.x, mainwindow.pos.y);
            }
            else {
                root.null_flag2 = false;
                fileBtnRow.state ="SystemWork";
                toolkits.alertMSG(qsTr("Scan completed!"), mainwindow.pos.x, mainwindow.pos.y);//扫描完成！
                syscacheBtn.text = qsTr("Start cleaning");//开始清理
                root.btn_flag = "system_work";
                systemstatus_label.visible = true;
                filebackBtn.visible = true;
                filerescanBtn.visible = true;
            }
        }
    }

//    Connections
//    {
//        target: sessiondispatcher
//        onFinishScanWork: {//扫描完成时收到的信号
//            if(msg == "history") {//上网记录
//                internetBtnRow.state = "BrowserWork";
//            }
//            else if(msg == "system") {//打开文件记录
//                fileBtnRow.state = "SystemWork";
//            }
//        }
//    }
    Connections
    {
        target: systemdispatcher
        onFinishCleanWorkError: {//清理出错时收到的信号
            if (btn_flag == "history_work") {
                if (msg == "history") {
                    internetBtnRow.state = "BrowserWorkError";
                    toolkits.alertMSG(qsTr("Exception occurred!"), mainwindow.pos.x, mainwindow.pos.y);//清理出现异常！
                }
            }
            else if(btn_flag2 == "system_work") {
                if (msg == "system") {
                    fileBtnRow.state = "SystemWorkError";
                    toolkits.alertMSG(qsTr("Exception occurred!"), mainwindow.pos.x, mainwindow.pos.y);//清理出现异常！
                }
            }
         }
        onFinishCleanWork: {//清理成功时收到的信号
            if (btn_flag == "history_work") {
                if (msg == "") {
                    toolkits.alertMSG(qsTr("Cleanup interrupted!"), mainwindow.pos.x, mainwindow.pos.y);//清理中断了！
                }
                else if (msg == "history") {
                    internetBtnRow.state = "BrowserWorkFinish";
                }
            }
            else if (btn_flag2 == "system_work") {
                if (msg == "") {
                    toolkits.alertMSG(qsTr("Cleanup interrupted!"), mainwindow.pos.x, mainwindow.pos.y);//清理中断了！
                }
                else if (msg == "system") {
                    fileBtnRow.state = "SystemWorkFinish";
                }
            }
        }
    }
    //背景
    Image {
        source: "../img/skin/bg-bottom-tab.png"
        anchors.fill: parent
    }
    //titlebar
    Row {
        id: titlebar
        spacing: 20
        width: parent.width
        anchors { top: parent.top; topMargin: 20; left: parent.left; leftMargin: 27 }
        Image {
            id: refreshArrow
            source: "../img/toolWidget/history-max.png"
            Behavior on rotation { NumberAnimation { duration: 200 } }
        }
        Column {
            spacing: 10
            id: mycolumn
            Text {
                id: text0
                width: 700
                text: root.title
                wrapMode: Text.WordWrap
                font.bold: true
                font.pixelSize: 14
                color: "#383838"
            }
            Text {
                id: text
                width: 700
                wrapMode: Text.WordWrap
                text: root.description
                font.pixelSize: 12
                color: "#7a7a7a"
            }
        }
    }
    //分割条
    Rectangle {
        id: splitbar
        anchors {
            top: titlebar.bottom
            topMargin: 18
            left: parent.left
            leftMargin: 2
        }
        width: parent.width - 4
        height: 1
        color: "#d8e0e6"
    }

    //文字显示Column
    Column {
        anchors {
            top: titlebar.bottom
            topMargin: 50
            left: parent.left
            leftMargin: 45
        }
        spacing:30
        //Internet browser record
        Row {
            id: internetRow
            spacing: 15
            Image {
                id: clearImage1
                width: 40; height: 42
                source:"../img/toolWidget/history-min.png"
            }
            Column {
                spacing: 5
                Row{
                    spacing: 15
                    Text {
                        text: qsTr("Clean up the Internet browser record")//清理浏览器上网记录
                        wrapMode: Text.WordWrap
                        font.bold: true
                        font.pixelSize: 14
                        color: "#383838"
                    }
                    Common.Label {//显示扫描后的结果
                        id: browserstatus_label
                        visible: false
                        text: ""
                    }
                }
                Text {
                    width: 450
                    text: qsTr("Clean up the Internet histories, currently only supports Firefox browser")//清理上网时留下的历史记录,目前仅支持Firefox浏览器
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    color: "#7a7a7a"
                }
            }
        }

        //opened documents recently
        Row {
            id: fileRow
            spacing: 15
            Image {
                id: clearImage2
                width: 40; height: 42
                source: "../img/toolWidget/systemtrace.png"
            }
            Column {
                spacing: 5
                Row{
                    spacing: 15
                    Text {
                        text: qsTr("Clean the opened documents recently")//清理最近打开文件记录
                        wrapMode: Text.WordWrap
                        font.bold: true
                        font.pixelSize: 14
                        color: "#383838"
                    }
                    Common.Label {
                        id: systemstatus_label
                        visible: false
                        text: ""
                    }
                }
                Text {
                    width: 450
                    text: qsTr("Clean the opened documents recently, and protect your privacy")//清理系统上最近的文件打开记录，保护您的个人隐私
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    color: "#7a7a7a"
                }
            }
        }
    }

    //按钮显示Column
    Column {
        anchors {
            top: titlebar.bottom
            topMargin: 50
            right: parent.right
            rightMargin: 20
        }
        spacing:30
        Row{
            id: internetBtnRow
            spacing: 20
            Row {
                spacing: 20
                Item {
                    id: internetbackBtn
                    visible: false
                    width: 60
                    height: 29
                    Text {
                        id:internetbackText
                        height: 10
                        anchors.centerIn: parent
                        text: qsTr("Go back")//返回
                        font.pointSize: 10
                        color: "#318d11"
                    }
                    Rectangle {
                        id: internetbtnImg
                        anchors.top: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: internetbackText.width
                        height: 1
                        color: "transparent"
                    }
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        onEntered: internetbtnImg.color = "#318d11"
                        onPressed: internetbtnImg.color = "#318d11"
                        onReleased: internetbtnImg.color = "#318d11"
                        onExited: internetbtnImg.color = "transparent"
                        onClicked: {
                            internetBtnRow.state = "BrowserWorkAGAIN";
                        }
                    }
                }
                Item {
                    id: internetrescanBtn
                    visible: false
                    width: 49
                    height: 29
                    Text {
                        id:internetrescanText
                        height: 10
                        anchors.centerIn: parent
                        text: qsTr("Scan again")//重新扫描
                        font.pointSize: 10
                        color: "#318d11"
                    }
                    Rectangle {
                        id: internetbtnImg2
                        anchors.top: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: internetrescanText.width
                        height: 1
                        color: "transparent"
                    }
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        onEntered: internetbtnImg2.color = "#318d11"
                        onPressed: internetbtnImg2.color = "#318d11"
                        onReleased: internetbtnImg2.color = "#318d11"
                        onExited: internetbtnImg2.color = "transparent"
                        onClicked: {
                            internetcacheBtn.text = qsTr("Start scanning");//开始扫描
                            root.btn_flag = "history_scan";
                            internetbackBtn.visible = false;
                            internetrescanBtn.visible = false;
                            browserstatus_label.visible = false;
                            root.getData("BrowserWork");
                        }
                    }
                }
            }
            Common.Button {
                id: internetcacheBtn
                width: 95
                height: 30
                hoverimage: "green2.png"
                text: root.btn_text
                onClicked: {
                    if (root.btn_flag == "history_scan") {
                        root.getData("BrowserWork");
                    }
                    else if (root.btn_flag == "history_work") {
                        if(root.null_flag == true) {
                            internetBtnRow.state = "BrowserWorkEmpty";
                            //友情提示      扫描内容为空，不再执行清理！
                            sessiondispatcher.showWarningDialog(qsTr("Tips:"), qsTr("Scanning content is empty, no longer to perform cleanup!"), mainwindow.pos.x, mainwindow.pos.y);
                        }
                        else {
                            systemdispatcher.set_user_homedir_qt();
                            systemdispatcher.clean_history_records_qt();
                        }
                    }
                }
            }

            states: [
                State {
                    name: "BrowserWork"
                    PropertyChanges { target: internetcacheBtn; text:qsTr("Start cleaning")}//开始清理
                    PropertyChanges { target: root; btn_flag: "history_work" }
                    PropertyChanges { target: browserstatus_label; visible: true; text: qsTr("(Scan")+ browserstatus_num + qsTr("records)")}//（扫描到     条记录）
                    PropertyChanges { target: internetbackBtn; visible: true}
                    PropertyChanges { target: internetrescanBtn; visible: true}
                },
                State {
                    name: "BrowserWorkAGAIN"
                    PropertyChanges { target: internetcacheBtn; text:qsTr("Start scanning") }//开始扫描
                    PropertyChanges { target: root; btn_flag: "history_scan" }
                    PropertyChanges { target: browserstatus_label; visible: false}
                    PropertyChanges { target: internetbackBtn; visible: false}
                    PropertyChanges { target: internetrescanBtn; visible: false}
                },
                State {
                    name: "BrowserWorkError"
                    PropertyChanges { target: internetcacheBtn; text:qsTr("Start scanning") }//开始扫描
                    PropertyChanges { target: root; btn_flag: "history_scan" }
                    PropertyChanges { target: browserstatus_label; visible: false}
                    PropertyChanges { target: internetbackBtn; visible: false}
                    PropertyChanges { target: internetrescanBtn; visible: false}
                },
                State {
                    name: "BrowserWorkFinish"
                    PropertyChanges { target: internetcacheBtn; text:qsTr("Start scanning")}//开始扫描
                    PropertyChanges { target: root; btn_flag: "history_scan" }
                    PropertyChanges { target: browserstatus_label; visible: true; text: root.work_result + qsTr("(Have cleared")+ browserstatus_num + qsTr("records)") }//（已清理     条记录）
                    PropertyChanges { target: internetbackBtn; visible: false}
                    PropertyChanges { target: internetrescanBtn; visible: false}

                },
                State {
                    name: "BrowserWorkEmpty"
                    PropertyChanges { target: internetcacheBtn; text:qsTr("Start scanning") }//开始扫描
                    PropertyChanges { target: root; btn_flag: "history_scan" }
                    PropertyChanges { target: browserstatus_label; visible: false}
                    PropertyChanges { target: internetbackBtn; visible: false}
                    PropertyChanges { target: internetrescanBtn; visible: false}
                }
            ]
        }

        Row{
            id: fileBtnRow
            spacing: 20
            Row {
                spacing: 20
                Item {
                    id: filebackBtn
                    visible: false
                    width: 60
                    height: 29
                    Text {
                        id:filebackText
                        height: 10
                        anchors.centerIn: parent
                        text: qsTr("Go back")//返回
                        font.pointSize: 10
                        color: "#318d11"
                    }
                    Rectangle {
                        id: filebtnImg
                        anchors.top: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: filebackText.width
                        height: 1
                        color: "transparent"
                    }
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        onEntered: filebtnImg.color = "#318d11"
                        onPressed: filebtnImg.color = "#318d11"
                        onReleased: filebtnImg.color = "#318d11"
                        onExited: filebtnImg.color = "transparent"
                        onClicked: {
                            fileBtnRow.state = "SystemWorkAGAIN";
                        }
                    }
                }
                Item {
                    id: filerescanBtn
                    visible: false
                    width: 49
                    height: 29
                    Text {
                        id:filerescanText
                        height: 10
                        anchors.centerIn: parent
                        text: qsTr("Scan again")//重新扫描
                        font.pointSize: 10
                        color: "#318d11"
                    }
                    Rectangle {
                        id: filebtnImg2
                        anchors.top: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: filerescanText.width
                        height: 1
                        color: "transparent"
                    }
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        onEntered: filebtnImg2.color = "#318d11"
                        onPressed: filebtnImg2.color = "#318d11"
                        onReleased: filebtnImg2.color = "#318d11"
                        onExited: filebtnImg2.color = "transparent"
                        onClicked: {
                            syscacheBtn.text = qsTr("Start scanning");//开始扫描
                            root.btn_flag2 = "system_scan";
                            filebackBtn.visible = false;
                            filerescanBtn.visible = false;
                            systemstatus_label.visible = false;
                            root.getData("SystemWork");
                        }
                    }
                }
            }
            Common.Button {
                id: syscacheBtn
                width: 95
                height: 30
                hoverimage: "green2.png"
                text: root.btn_text
                onClicked: {
                    if (root.btn_flag2 == "system_scan") {
                        root.getData("SystemWork");
                    }
                    else if (root.btn_flag2 == "system_work") {
                        if(root.null_flag2 == true) {
                            root.state = "SystemWorkEmpty";
                            //友情提示      扫描内容为空，不再执行清理！
                            sessiondispatcher.showWarningDialog(qsTr("Tips:"), qsTr("Scanning content is empty, no longer to perform cleanup!"), mainwindow.pos.x, mainwindow.pos.y);
                        }
                        else {
                            systemdispatcher.set_user_homedir_qt();
                            systemdispatcher.clean_system_history_qt();
                        }
                    }
                }
            }

            states: [
                State {
                    name: "SystemWork"
                    PropertyChanges { target: syscacheBtn; text:qsTr("Start cleaning")}//开始清理
                    PropertyChanges { target: root; btn_flag2: "system_work" }
                    PropertyChanges { target: systemstatus_label; visible: true; text: qsTr("(Scan")+ systemstatus_num + qsTr("records)")}//扫描到     条记录
                    PropertyChanges { target: filebackBtn; visible: true}
                    PropertyChanges { target: filerescanBtn; visible: true}
                },
                State {
                    name: "SystemWorkAGAIN"
                    PropertyChanges { target: syscacheBtn; text:qsTr("Start scanning") }//开始扫描
                    PropertyChanges { target: root; btn_flag2: "system_scan" }
                    PropertyChanges { target: browserstatus_label; visible: false}
                    PropertyChanges { target: filebackBtn; visible: false}
                    PropertyChanges { target: filerescanBtn; visible: false}
                },
                State {
                    name: "SystemWorkError"
                    PropertyChanges { target: syscacheBtn; text:qsTr("Start scanning") }//开始扫描
                    PropertyChanges { target: root; btn_flag2: "system_scan" }
                    PropertyChanges { target: browserstatus_label; visible: false}
                    PropertyChanges { target: filebackBtn; visible: false}
                    PropertyChanges { target: filerescanBtn; visible: false}
                },
                State {
                    name: "SystemWorkFinish"
                    PropertyChanges { target: syscacheBtn; text:qsTr("Start scanning") }//开始扫描
                    PropertyChanges { target: root; btn_flag2: "system_scan" }
                    PropertyChanges { target: systemstatus_label; visible: true; text: root.work_result + qsTr("(Have cleared")+ systemstatus_num + qsTr("records)")}//已清理     条记录
                    PropertyChanges { target: filebackBtn; visible: false}
                    PropertyChanges { target: filerescanBtn; visible: false}
                },
                State {
                    name: "SystemWorkEmpty"
                    PropertyChanges { target: syscacheBtn; text:qsTr("Start scanning") }//开始扫描
                    PropertyChanges { target: root; btn_flag2: "system_scan" }
                    PropertyChanges { target: browserstatus_label; visible: false}
                    PropertyChanges { target: filebackBtn; visible: false}
                    PropertyChanges { target: filerescanBtn; visible: false}
                }
            ]
        }
    }
}

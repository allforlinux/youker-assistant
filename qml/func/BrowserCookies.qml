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

//-----------origianal
Item {
    id:root
    width: parent.width
    height: 435//420//340
    property string btn_text: "开始扫描"
    property string title: "清理浏览器登录信息,保护个人隐私"
    property string description: "清理上网时留下的登录信息,目前仅支持Firefox浏览器"
    property string btn_flag: "cookies_scan"
    property ListModel listmodel: mainModel
    property ListModel submodel: subModel
    property int coo_sub_num: 0//number of subitem
    property string work_result: ""
    property int sub_num:coo_sub_num
    property bool check_flag: true
    property bool null_flag: false
    property int deleget_arrow :0

    signal cookies_signal(string cookies_msg);
    onCookies_signal: {
        if (cookies_msg == "CookiesWork") {
            //get data of cookies
//            var cookies_data = systemdispatcher.scan_cookies_records_qt();
            var cookies_data = sessiondispatcher.scan_cookies_records_qt();
            if (cookies_data == "") {
                root.null_flag = true;
                if(statusImage.visible == true)
                    statusImage.visible = false;
            }
            else {
                root.null_flag = false;
                statusImage.visible = true;
            }
            root.coo_sub_num = cookies_data.length;
            systemdispatcher.clear_cookies_args();
            subModel.clear();
            var num = 0;
            for (var i=0; i< cookies_data.length; i++) {
                //sina.com.cn<2_2>10
                var splitlist = cookies_data[i].split("<2_2>");
                if (splitlist[0] == "") {
                    num++;
                }
                else {
                    subModel.append({"itemTitle": splitlist[0], "desc": "","number": splitlist[1] + "个Cookie"});
                    systemdispatcher.set_cookies_args(splitlist[0]);
                }
            }

            root.coo_sub_num -= num;
            sub_num=coo_sub_num
            if(sub_num!=0)
                check_flag=true;
            mainModel.clear();
            mainModel.append({"itemTitle": "清理Cookies ( 发现" + root.coo_sub_num + "处记录 )",
                             "picture": "../img/toolWidget/cookies.png",
                             "detailstr": "清理Firefox浏览器自动保存的登录信息(Cookies)",
                             "flags": "clear_cookies",
                            "attributes":
                                 [{"subItemTitle": "Cookies1"},
                                 {"subItemTitle": "Cookies2"},
                                 {"subItemTitle": "Cookies3"},
                                 {"subItemTitle": "Cookies4"}]
                             })

        }
    }


    ListModel {
        id: mainModel
        ListElement {
            itemTitle: "清理Cookies"
            picture: "../img/toolWidget/cookies.png"
            detailstr: "清理Firefox浏览器自动保存的登录信息(Cookies)"
            flags: "clear_cookies"
            attributes: [
                ListElement { subItemTitle: "" }
            ]
        }
    }

    ListModel {
        id: subModel
        ListElement {itemTitle: ""; desc: ""; number: ""}
    }


    //信号绑定，绑定qt的信号finishCleanWork，该信号emit时触发onFinishCleanWork
    Connections
    {
//        target: sessiondispatcher
        target: systemdispatcher
//         onFinishScanWork: {
        //             if (btn_flag == "cookies_scan") {
        ////                 titleBar.work_result = msg;
        //                 titleBar.state = "CookiesWork";
        //             }

//         }
        onFinishCleanWorkError: {
            if (btn_flag == "cookies_work") {
                if (msg == "cookies") {
                    root.work_result = msg;
                    root.state = "CookiesWorkError";
                    toolkits.alertMSG("清理出现异常！", mainwindow.pos.x, mainwindow.pos.y);
                }
            }
         }
        onFinishCleanWork: {
            if (btn_flag == "cookies_work") {
                if (msg == "") {
                    resetBtn.visible = true;
                }
                else if (msg == "cookies") {
                    root.work_result = msg;
                    root.state = "CookiesWorkFinish";
                    toolkits.alertMSG("清理完毕！", mainwindow.pos.x, mainwindow.pos.y);
                    cookies_signal("CookiesWork");
                }
            }
        }
    }

//    //背景
    Image {
        source: "../img/skin/bg-bottom-tab.png"
        anchors.fill: parent
    }


    //titlebar
    Row {
        id: titlebar
        spacing: 20
        width: parent.width
//        height: 50
        anchors { top: parent.top; topMargin: 20; left: parent.left; leftMargin: 27 }
        Image {
            id: refreshArrow
            source: "../img/toolWidget/trace.png"
            Behavior on rotation { NumberAnimation { duration: 200 } }
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            Text {
                text: root.title
                font.bold: true
                font.pixelSize: 14
                color: "#383838"
            }
            Text {
                text: root.description
                font.pixelSize: 12
                color: "#7a7a7a"
            }
        }
    }
    Row{
        anchors { top: parent.top; topMargin: 30;right: parent.right ; rightMargin: 40 }
        spacing: 20
        //status picture
//        Image {
//            id: statusImage
//            source: "../img/toolWidget/unfinish.png"
//            fillMode: "PreserveAspectFit"
//            smooth: true
//            anchors.verticalCenter: parent.verticalCenter
//        }
        Common.StatusImage {
            id: statusImage
            visible: false
            iconName: "yellow.png"
            text: "未完成"
            anchors.verticalCenter: parent.verticalCenter
        }

        Common.Button {
            id: bitButton
            width: 120
            height: 39
            text: root.btn_text
            hoverimage: "green1.png"
            anchors.verticalCenter: parent.verticalCenter
            fontsize: 15
            onClicked: {
                resetBtn.visible = false;
                if(root.check_flag)
                {
                //broswer cookies
                 if (btn_flag == "cookies_scan") {
                     cookies_signal("CookiesWork");
                     if(root.null_flag == true) {
                        root.state = "CookiesWorkEmpty";
                         deleget_arrow=0;
                         sessiondispatcher.showWarningDialog("友情提示：","扫描内容为空，不再执行清理！", mainwindow.pos.x, mainwindow.pos.y);
                     }
                     else if(root.null_flag == false)
                     {
                        root.state = "CookiesWork";
                         deleget_arrow=1;
                         toolkits.alertMSG("扫描完成！", mainwindow.pos.x, mainwindow.pos.y);
                     }
                 }
                 else if (btn_flag == "cookies_work") {
                     systemdispatcher.set_user_homedir_qt();
                     systemdispatcher.clean_cookies_records_qt(systemdispatcher.get_cookies_args());
                     deleget_arrow=1;
                 }
                }
                else
                    sessiondispatcher.showWarningDialog("友情提示：","对不起，您没有选择需要清理的项，请确认！", mainwindow.pos.x, mainwindow.pos.y);
            }
        }
        SetBtn {
            id: resetBtn
            width: 12
            height: 15
            iconName: "revoke.png"
            visible: false
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                resetBtn.visible = false;
                subModel.clear();
                root.state = "CookiesWorkAGAIN";
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

    Common.ScrollArea {
        frame:false
        anchors.top: titlebar.bottom
        anchors.topMargin: 20//30
        anchors.left:parent.left
        anchors.leftMargin: 27
        height: root.height -titlebar.height - 37//50
        width: parent.width -27 -2
        Item {
            width: parent.width
            height: (root.sub_num + 1) * 40 //450 + //this height must be higher than root.height, then the slidebar can display
            //垃圾清理显示内容
            ListView {
                id: listView
                height: parent.height
                model: mainModel
                delegate: Cleardelegate{
                    sub_num:root.coo_sub_num;sub_model:subModel;btn_flag:root.btn_flag;arrow_display:deleget_arrow;
                    delegate_flag: false
                    onSubpressed: {root.sub_num = hMark}
                    onCheckchanged: {root.check_flag = checkchange}
                }
                cacheBuffer: 1000
                opacity: 1
                spacing: 10
                snapMode: ListView.NoSnap
                boundsBehavior: Flickable.DragOverBounds
                currentIndex: 0
                preferredHighlightBegin: 0
                preferredHighlightEnd: preferredHighlightBegin
                highlightRangeMode: ListView.StrictlyEnforceRange
            }
        }//Item
    }//ScrollArea

    states: [
        State {
            name: "CookiesWork"
             PropertyChanges { target: bitButton; text:"开始清理"}
            PropertyChanges { target: root; btn_flag: "cookies_work" }
            PropertyChanges { target: statusImage; visible: true; iconName: "yellow.png"; text: "未完成"}
        },
        State {
            name: "CookiesWorkAGAIN"
            PropertyChanges { target: bitButton; text:"开始扫描" }
            PropertyChanges { target: root; btn_flag: "cookies_scan" }
            PropertyChanges { target: statusImage; visible: false }
        },
        State {
            name: "CookiesWorkError"
            PropertyChanges { target: bitButton; text:"开始扫描" }
            PropertyChanges { target: root; btn_flag: "cookies_scan" }
            PropertyChanges { target: statusImage; visible: true; iconName: "red.png"; text: "出现异常"}
        },
        State {
            name: "CookiesWorkFinish"
            PropertyChanges { target: bitButton; text:"开始扫描"}
            PropertyChanges { target: root; btn_flag: "cookies_scan" }
            PropertyChanges { target: statusImage; visible: true; iconName: "green.png"; text: "已完成"}
        },
        State {
            name: "CookiesWorkEmpty"
            PropertyChanges { target: bitButton; text:"开始扫描"}
            PropertyChanges { target: root; btn_flag: "cookies_scan" }
            PropertyChanges { target: statusImage; visible: false}
        }
    ]
}











//-------------1031
//Item {
//    id:root
//    width: parent.width
//    height: 435
//    property string btn_text: "开始扫描"
//    property string title: "清理浏览器登录信息,保护个人隐私"
//    property string description: "清理上网时留下的登录信息,目前仅支持Firefox浏览器"
//    property string btn_flag: "cookies_scan"
//    property int coo_sub_num: 0//number of subitem
//    property string work_result: ""
//    property int sub_num: coo_sub_num
//    property bool check_flag: true
//    property bool null_flag: false
//    property int deleget_arrow :0
//    property bool expanded: true
//    property bool delegate_flag: false
//    property int check_num: sub_num   //记录子项个数，在确定总checkbox状态时需要的变量

//    property bool mainStatus: true//存放主checkbox的状态
//    Component{
//        id: yourselfDelegate
//        ListItem {
//            id: subListItem
//            split_status: root.delegate_flag//false
//            width: 850
//            height: 40
//            text: itemTitle
//            descript: desc
//            size_num: number
////            checkbox_status: check.checkedbool
//            checkbox_status: root.mainStatus
//            bgImage: ""
//            fontName: "Helvetica"
//            fontSize: 10
//            fontColor: "black"
//            textIndent: 20
//            btn_flag: root.btn_flag

//            //当单个checkbox状态变化时，收到其变化的值：check_status
//            onChange_num: {
//                if(check_status==true)//已经勾上的子项数量统计,check_num记录
//                    check_num=check_num+1;
//                else
//                    check_num=check_num-1;
//                if(sub_num != 0){  //在扫描出子项并下拉显示了子项的前提下,根据已经勾上的子项个数确定总checkbox处于三种状态中的哪种
//                    if(check_num == 0) {
//                        sessiondispatcher.change_maincheckbox_status("false");
//                    }
//                    else if(check_num == sub_num) {
//                        sessiondispatcher.change_maincheckbox_status("true");
//                    }
//                    else {
//                        sessiondispatcher.change_maincheckbox_status("mid");
//                    }
//                }
//                if(check_num == sub_num && sub_num > 0)   //根据是否有勾选项给清理页面传值判断是否能进行清理工作
//                    root.check_flag = true;
//                else
//                    root.check_flag = false;
//            }
//        }
//    }
//    signal cookies_signal(string cookies_msg);
//    onCookies_signal: {
//        if (cookies_msg == "CookiesWork") {
//            //get data of cookies
//            var cookies_data = sessiondispatcher.scan_cookies_records_qt();
//            if (cookies_data == "") {
//                root.null_flag = true;
//                if(statusImage.visible == true)
//                    statusImage.visible = false;
//            }
//            else {
//                root.null_flag = false;
//                statusImage.visible = true;
//            }
//            root.coo_sub_num = cookies_data.length;
//            systemdispatcher.clear_cookies_args();
//            subModel.clear();
//            var num = 0;
//            for (var i=0; i< cookies_data.length; i++) {
//                //sina.com.cn<2_2>10
//                var splitlist = cookies_data[i].split("<2_2>");
//                if (splitlist[0] == "") {
//                    num++;
//                }
//                else {
//                    subModel.append({"itemTitle": splitlist[0], "desc": "","number": splitlist[1] + "个Cookie"});
//                    systemdispatcher.set_cookies_args(splitlist[0]);
//                }
//            }

//            root.coo_sub_num -= num;
//            sub_num=coo_sub_num
//            if(sub_num!=0)
//                check_flag=true;
//        }
//    }
//    ListModel {
//        id: subModel
//        ListElement {itemTitle: ""; desc: ""; number: ""}
//    }


//    //信号绑定，绑定qt的信号finishCleanWork，该信号emit时触发onFinishCleanWork
//    Connections
//    {
////        target: sessiondispatcher
//        target: systemdispatcher
////         onFinishScanWork: {
//        //             if (btn_flag == "cookies_scan") {
//        ////                 titleBar.work_result = msg;
//        //                 titleBar.state = "CookiesWork";
//        //             }

////         }
//        onFinishCleanWorkError: {
//            if (btn_flag == "cookies_work") {
//                if (msg == "cookies") {
//                    root.work_result = msg;
//                    root.state = "CookiesWorkError";
//                    toolkits.alertMSG("清理出现异常！", mainwindow.pos.x, mainwindow.pos.y);
//                }
//            }
//         }
//        onFinishCleanWork: {
//            if (btn_flag == "cookies_work") {
//                if (msg == "") {
//                    resetBtn.visible = true;
//                }
//                else if (msg == "cookies") {
//                    root.work_result = msg;
//                    root.state = "CookiesWorkFinish";
//                    toolkits.alertMSG("清理完毕！", mainwindow.pos.x, mainwindow.pos.y);
//                    cookies_signal("CookiesWork");
//                }
//            }
//        }
//    }

////    //背景
//    Image {
//        source: "../img/skin/bg-bottom-tab.png"
//        anchors.fill: parent
//    }

//    //titlebar
//    Row {
//        id: titlebar
//        spacing: 20
//        width: parent.width
////        height: 50
//        anchors { top: parent.top; topMargin: 20; left: parent.left; leftMargin: 27 }
//        Image {
//            id: refreshArrow
//            source: "../img/toolWidget/trace.png"
//            Behavior on rotation { NumberAnimation { duration: 200 } }
//        }
//        Column {
//            anchors.verticalCenter: parent.verticalCenter
//            spacing: 10
//            Text {
//                text: root.title
//                font.bold: true
//                font.pixelSize: 14
//                color: "#383838"
//            }
//            Text {
//                text: root.description
//                font.pixelSize: 12
//                color: "#7a7a7a"
//            }
//        }
//    }
//    Row{
//        anchors { top: parent.top; topMargin: 30;right: parent.right ; rightMargin: 40 }
//        spacing: 20
//        //status picture
//        Common.StatusImage {
//            id: statusImage
//            visible: false
//            iconName: "yellow.png"
//            text: "未完成"
//            anchors.verticalCenter: parent.verticalCenter
//        }
//        Common.Button {
//            id: bitButton
//            width: 120
//            height: 39
//            text: root.btn_text
//            hoverimage: "green1.png"
//            anchors.verticalCenter: parent.verticalCenter
//            fontsize: 15
//            onClicked: {
//                resetBtn.visible = false;
//                if(root.check_flag)
//                {
//                //broswer cookies
//                 if (btn_flag == "cookies_scan") {
//                     cookies_signal("CookiesWork");
//                     if(root.null_flag == true) {
//                        root.state = "CookiesWorkEmpty";
//                         root.deleget_arrow=0;
//                         sessiondispatcher.showWarningDialog("友情提示：","扫描内容为空，不再执行清理！", mainwindow.pos.x, mainwindow.pos.y);
//                     }
//                     else if(root.null_flag == false)
//                     {
//                        root.state = "CookiesWork";
//                         root.deleget_arrow=1;
//                         toolkits.alertMSG("扫描完成！", mainwindow.pos.x, mainwindow.pos.y);
//                     }
//                 }
//                 else if (btn_flag == "cookies_work") {
//                     systemdispatcher.set_user_homedir_qt();
//                     systemdispatcher.clean_cookies_records_qt(systemdispatcher.get_cookies_args());
//                     root.deleget_arrow=1;
//                 }
//                }
//                else
//                    sessiondispatcher.showWarningDialog("友情提示：","对不起，您没有选择需要清理的项，请确认！", mainwindow.pos.x, mainwindow.pos.y);
//            }
//        }
//        SetBtn {
//            id: resetBtn
//            width: 12
//            height: 15
//            iconName: "revoke.png"
//            visible: false
//            anchors.verticalCenter: parent.verticalCenter
//            onClicked: {
//                resetBtn.visible = false;
//                subModel.clear();
//                root.state = "CookiesWorkAGAIN";
//            }
//        }
//    }
//    //分割条
//    Rectangle {
//        id: splitbar
//        anchors {
//            top: titlebar.bottom
//            topMargin: 18
//            left: parent.left
//            leftMargin: 2
//        }
//        width: parent.width - 4
//        height: 1
//        color: "#d8e0e6"
//    }

//    Common.ScrollArea {
//        frame:false
//        anchors.top: titlebar.bottom
//        anchors.topMargin: 20
//        height: root.height -titlebar.height- 37
//        width: parent.width
//        Item {
//            width: parent.width
//            height: (root.sub_num + 1) * 40 * 2
//            Column {
//                spacing: 30
//                anchors.top: parent.top
//                anchors.topMargin: 20
//                anchors.left: parent.left
//                anchors.leftMargin: 30
//                //firefox
//                ItemTitle {
//                    id: firefoxTitle
//                    imageSource: "../img/toolWidget/cookies.png"
//                    itemTitle: "清理Cookies"
//                    detailstr: "清理Firefox浏览器自动保存的登录信息(Cookies)"
//                    sub_num: root.coo_sub_num
//                    arrow_display: root.deleget_arrow
//                    checkboxStatus: root.mainStatus
//                    onClicked: {
//                        yourselfListView.visible = !yourselfListView.visible;
//                    }
////                    onSubpressed: {root.sub_num = hMark}
//                }
//                ListView {
//                    id: yourselfListView
//                    width: parent.width
//                    height: expanded ? yourselfListView.count * 40 : 0
//                    model: subModel
//                    delegate: yourselfDelegate
//                    visible: false
//                }
//                //hrominum
//                ItemTitle {
//                    id: chrominumTitle
//                    imageSource: "../img/toolWidget/cookies.png"
//                    itemTitle: "清理Cookies"
//                    detailstr: "清理Chrominum浏览器自动保存的登录信息(Cookies)"
//                    sub_num: root.coo_sub_num
//                    arrow_display: root.deleget_arrow
//                    onClicked: {
//                        systemListView.visible = !systemListView.visible;
//                    }
////                    onSubpressed: {root.sub_num = hMark}
//                }
//                ListView {
//                    id: systemListView
//                    width: parent.width
//                    height: expanded ? systemListView.count * 40 : 0
//                    model: subModel
//                    delegate: yourselfDelegate
//                    visible: false
//                }
//            }
//        }
//    }
//    states: [
//        State {
//            name: "CookiesWork"
//             PropertyChanges { target: bitButton; text:"开始清理"}
//            PropertyChanges { target: root; btn_flag: "cookies_work" }
//            PropertyChanges { target: statusImage; visible: true; iconName: "yellow.png"; text: "未完成"}
//        },
//        State {
//            name: "CookiesWorkAGAIN"
//            PropertyChanges { target: bitButton; text:"开始扫描" }
//            PropertyChanges { target: root; btn_flag: "cookies_scan" }
//            PropertyChanges { target: statusImage; visible: false }
//        },
//        State {
//            name: "CookiesWorkError"
//            PropertyChanges { target: bitButton; text:"开始扫描" }
//            PropertyChanges { target: root; btn_flag: "cookies_scan" }
//            PropertyChanges { target: statusImage; visible: true; iconName: "red.png"; text: "出现异常"}
//        },
//        State {
//            name: "CookiesWorkFinish"
//            PropertyChanges { target: bitButton; text:"开始扫描"}
//            PropertyChanges { target: root; btn_flag: "cookies_scan" }
//            PropertyChanges { target: statusImage; visible: true; iconName: "green.png"; text: "已完成"}
//        },
//        State {
//            name: "CookiesWorkEmpty"
//            PropertyChanges { target: bitButton; text:"开始扫描"}
//            PropertyChanges { target: root; btn_flag: "cookies_scan" }
//            PropertyChanges { target: statusImage; visible: false}
//        }
//    ]
//}




//-------------1030
//Item {
//    id:root
//    width: parent.width
//    height: 435
//    property string btn_text: "开始扫描"
//    property string title: "清理浏览器登录信息,保护个人隐私"
//    property string description: "清理上网时留下的登录信息,目前仅支持Firefox浏览器"
//    property string btn_flag: "cookies_scan"
//    property int coo_sub_num: 0//number of subitem
//    property string work_result: ""
//    property int sub_num: coo_sub_num
//    property bool check_flag: true
//    property bool null_flag: false
//    property int deleget_arrow :0

//    property bool expanded: true
//    property bool delegate_flag: false
//    property int check_num: sub_num   //记录子项个数，在确定总checkbox状态时需要的变量


//    Component{
//        id: yourselfDelegate
//        ListItem {
//            id: subListItem
//            split_status: root.delegate_flag//false
//            width: 850
//            height: 40
//            text: itemTitle
//            descript: desc
//            size_num: number
////            checkbox_status: check.checkedbool
//            checkbox_status: true
//            bgImage: ""
//            fontName: "Helvetica"
//            fontSize: 10
//            fontColor: "black"
//            textIndent: 20
//            btn_flag: root.btn_flag
//            onClicked: {}
//            onChange_num: {
//                if(check_status==true)//已经勾上的子项数量统计,check_num记录
//                    check_num=check_num+1;
//                else
//                    check_num=check_num-1;
//                if(sub_num!=0){  //在扫描出子项并下拉显示了子项的前提下,根据已经勾上的子项个数确定总checkbox处于三种状态中的哪种
//                    if(check_num ==0) {
//                        sessiondispatcher.change_maincheckbox_status("false");
//                    }
//                    else if(check_num ==sub_num) {
//                        sessiondispatcher.change_maincheckbox_status("true");
//                    }
//                    else {
//                        sessiondispatcher.change_maincheckbox_status("mid");
//                    }
//                }
//                if(check_num == sub_num && sub_num > 0)   //根据是否有勾选项给清理页面传值判断是否能进行清理工作
//                    root.check_flag = true;
//                else
//                    root.check_flag = false;
//            }
//        }
//    }
//    signal cookies_signal(string cookies_msg);
//    onCookies_signal: {
//        if (cookies_msg == "CookiesWork") {
//            //get data of cookies
//            var cookies_data = sessiondispatcher.scan_cookies_records_qt();
//            if (cookies_data == "") {
//                root.null_flag = true;
//                if(statusImage.visible == true)
//                    statusImage.visible = false;
//            }
//            else {
//                root.null_flag = false;
//                statusImage.visible = true;
//            }
//            root.coo_sub_num = cookies_data.length;
//            systemdispatcher.clear_cookies_args();
//            subModel.clear();
//            var num = 0;
//            for (var i=0; i< cookies_data.length; i++) {
//                //sina.com.cn<2_2>10
//                var splitlist = cookies_data[i].split("<2_2>");
//                if (splitlist[0] == "") {
//                    num++;
//                }
//                else {
//                    subModel.append({"itemTitle": splitlist[0], "desc": "","number": splitlist[1] + "个Cookie"});
//                    systemdispatcher.set_cookies_args(splitlist[0]);
//                }
//            }

//            root.coo_sub_num -= num;
//            sub_num=coo_sub_num
//            if(sub_num!=0)
//                check_flag=true;
//        }
//    }
//    ListModel {
//        id: subModel
//        ListElement {itemTitle: ""; desc: ""; number: ""}
//    }


//    //信号绑定，绑定qt的信号finishCleanWork，该信号emit时触发onFinishCleanWork
//    Connections
//    {
////        target: sessiondispatcher
//        target: systemdispatcher
////         onFinishScanWork: {
//        //             if (btn_flag == "cookies_scan") {
//        ////                 titleBar.work_result = msg;
//        //                 titleBar.state = "CookiesWork";
//        //             }

////         }
//        onFinishCleanWorkError: {
//            if (btn_flag == "cookies_work") {
//                if (msg == "cookies") {
//                    root.work_result = msg;
//                    root.state = "CookiesWorkError";
//                    toolkits.alertMSG("清理出现异常！", mainwindow.pos.x, mainwindow.pos.y);
//                }
//            }
//         }
//        onFinishCleanWork: {
//            if (btn_flag == "cookies_work") {
//                if (msg == "") {
//                    resetBtn.visible = true;
//                }
//                else if (msg == "cookies") {
//                    root.work_result = msg;
//                    root.state = "CookiesWorkFinish";
//                    toolkits.alertMSG("清理完毕！", mainwindow.pos.x, mainwindow.pos.y);
//                    cookies_signal("CookiesWork");
//                }
//            }
//        }
//    }

////    //背景
//    Image {
//        source: "../img/skin/bg-bottom-tab.png"
//        anchors.fill: parent
//    }

//    //titlebar
//    Row {
//        id: titlebar
//        spacing: 20
//        width: parent.width
////        height: 50
//        anchors { top: parent.top; topMargin: 20; left: parent.left; leftMargin: 27 }
//        Image {
//            id: refreshArrow
//            source: "../img/toolWidget/trace.png"
//            Behavior on rotation { NumberAnimation { duration: 200 } }
//        }
//        Column {
//            anchors.verticalCenter: parent.verticalCenter
//            spacing: 10
//            Text {
//                text: root.title
//                font.bold: true
//                font.pixelSize: 14
//                color: "#383838"
//            }
//            Text {
//                text: root.description
//                font.pixelSize: 12
//                color: "#7a7a7a"
//            }
//        }
//    }
//    Row{
//        anchors { top: parent.top; topMargin: 30;right: parent.right ; rightMargin: 40 }
//        spacing: 20
//        //status picture
//        Common.StatusImage {
//            id: statusImage
//            visible: false
//            iconName: "yellow.png"
//            text: "未完成"
//            anchors.verticalCenter: parent.verticalCenter
//        }
//        Common.Button {
//            id: bitButton
//            width: 120
//            height: 39
//            text: root.btn_text
//            hoverimage: "green1.png"
//            anchors.verticalCenter: parent.verticalCenter
//            fontsize: 15
//            onClicked: {
//                resetBtn.visible = false;
//                if(root.check_flag)
//                {
//                //broswer cookies
//                 if (btn_flag == "cookies_scan") {
//                     cookies_signal("CookiesWork");
//                     if(root.null_flag == true) {
//                        root.state = "CookiesWorkEmpty";
//                         root.deleget_arrow=0;
//                         sessiondispatcher.showWarningDialog("友情提示：","扫描内容为空，不再执行清理！", mainwindow.pos.x, mainwindow.pos.y);
//                     }
//                     else if(root.null_flag == false)
//                     {
//                        root.state = "CookiesWork";
//                         root.deleget_arrow=1;
//                         toolkits.alertMSG("扫描完成！", mainwindow.pos.x, mainwindow.pos.y);
//                     }
//                 }
//                 else if (btn_flag == "cookies_work") {
//                     systemdispatcher.set_user_homedir_qt();
//                     systemdispatcher.clean_cookies_records_qt(systemdispatcher.get_cookies_args());
//                     root.deleget_arrow=1;
//                 }
//                }
//                else
//                    sessiondispatcher.showWarningDialog("友情提示：","对不起，您没有选择需要清理的项，请确认！", mainwindow.pos.x, mainwindow.pos.y);
//            }
//        }
//        SetBtn {
//            id: resetBtn
//            width: 12
//            height: 15
//            iconName: "revoke.png"
//            visible: false
//            anchors.verticalCenter: parent.verticalCenter
//            onClicked: {
//                resetBtn.visible = false;
//                subModel.clear();
//                root.state = "CookiesWorkAGAIN";
//            }
//        }
//    }
//    //分割条
//    Rectangle {
//        id: splitbar
//        anchors {
//            top: titlebar.bottom
//            topMargin: 18
//            left: parent.left
//            leftMargin: 2
//        }
//        width: parent.width - 4
//        height: 1
//        color: "#d8e0e6"
//    }

//    Common.ScrollArea {
//        frame:false
//        anchors.top: titlebar.bottom
//        anchors.topMargin: 20
//        height: root.height -titlebar.height- 37
//        width: parent.width
//        Item {
//            width: parent.width
//            height: (root.sub_num + 1) * 40 * 2
//            Column {
//                spacing: 30
//                anchors.top: parent.top
//                anchors.topMargin: 20
//                anchors.left: parent.left
//                anchors.leftMargin: 30
//                //firefox
//                ItemTitle {
//                    id: firefoxTitle
//                    imageSource: "../img/toolWidget/cookies.png"
//                    itemTitle: "清理Cookies"
//                    detailstr: "清理Firefox浏览器自动保存的登录信息(Cookies)"
//                    sub_num: root.coo_sub_num
//                    arrow_display: root.deleget_arrow
//                    onClicked: {
//                        yourselfListView.visible = !yourselfListView.visible;
//                    }
////                    onSubpressed: {root.sub_num = hMark}
//                }
//                ListView {
//                    id: yourselfListView
//                    width: parent.width
//                    height: expanded ? yourselfListView.count * 40 : 0
//                    model: subModel
//                    delegate: yourselfDelegate
//                    visible: false
//                }
//                //hrominum
//                ItemTitle {
//                    id: chrominumTitle
//                    imageSource: "../img/toolWidget/cookies.png"
//                    itemTitle: "清理Cookies"
//                    detailstr: "清理Chrominum浏览器自动保存的登录信息(Cookies)"
//                    sub_num: root.coo_sub_num
//                    arrow_display: root.deleget_arrow
//                    onClicked: {
//                        systemListView.visible = !systemListView.visible;
//                    }
////                    onSubpressed: {root.sub_num = hMark}
//                }
//                ListView {
//                    id: systemListView
//                    width: parent.width
//                    height: expanded ? systemListView.count * 40 : 0
//                    model: subModel
//                    delegate: yourselfDelegate
//                    visible: false
//                }
//            }
//        }
//    }
//    states: [
//        State {
//            name: "CookiesWork"
//             PropertyChanges { target: bitButton; text:"开始清理"}
//            PropertyChanges { target: root; btn_flag: "cookies_work" }
//            PropertyChanges { target: statusImage; visible: true; iconName: "yellow.png"; text: "未完成"}
//        },
//        State {
//            name: "CookiesWorkAGAIN"
//            PropertyChanges { target: bitButton; text:"开始扫描" }
//            PropertyChanges { target: root; btn_flag: "cookies_scan" }
//            PropertyChanges { target: statusImage; visible: false }
//        },
//        State {
//            name: "CookiesWorkError"
//            PropertyChanges { target: bitButton; text:"开始扫描" }
//            PropertyChanges { target: root; btn_flag: "cookies_scan" }
//            PropertyChanges { target: statusImage; visible: true; iconName: "red.png"; text: "出现异常"}
//        },
//        State {
//            name: "CookiesWorkFinish"
//            PropertyChanges { target: bitButton; text:"开始扫描"}
//            PropertyChanges { target: root; btn_flag: "cookies_scan" }
//            PropertyChanges { target: statusImage; visible: true; iconName: "green.png"; text: "已完成"}
//        },
//        State {
//            name: "CookiesWorkEmpty"
//            PropertyChanges { target: bitButton; text:"开始扫描"}
//            PropertyChanges { target: root; btn_flag: "cookies_scan" }
//            PropertyChanges { target: statusImage; visible: false}
//        }
//    ]
//}

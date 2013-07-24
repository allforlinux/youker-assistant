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
import QtDesktop 0.1
//import SessionType 0.1
import SystemType 0.1
import "common" as Common
Item {
    id:root
    width: parent.width
    height: 435//420//340
    property string btn_text: "开始扫描"
    property string title: "清理Apt"
    property string description: "清理Apt可以节省磁盘空间"
    property string btn_flag: "apt_scan"
    property ListModel listmodel: mainModel
    property ListModel submodel: subModel
    property SystemDispatcher dis: systemdispatcher
    property int sub_num: 0
    property string work_result: ""

    //箭头图标
    property string arrow: '../img/icons/arrow.png'
    //母项字体
    property string headerItemFontName: "Helvetica"
    property int headerItemFontSize: 12
    property color headerItemFontColor: "black"
    //子项字体
    property string subItemFontName: "Helvetica"
    property int subItemFontSize: headerItemFontSize-2
    property color subItemFontColor: "black"
    property bool check_flag: true


    property int itemHeight: 40
//    property alias expandedItemCount: subItemRepeater.count
    property bool expanded: true //kobe:子项扩展默认打开



    signal apt_signal(string apt_msg);
    onApt_signal: {
        if (apt_msg == "AptWork") {
            //get data of cookies
            console.log("apt_msg == AptWork");
            var apt_data = systemdispatcher.scan_apt_cruft_qt();
//            console.log("1");
//            console.log(apt_data);
            root.sub_num = apt_data.length;
//            console.log("3");
//            console.log(root.sub_num);
            systemdispatcher.clear_apt_args();
            subModel.clear();
            var num = 0;
            for (var i=0; i< apt_data.length; i++) {
//                console.log("111");
//                console.log(apt_data[i]);//sina.com.cn<2_2>10
                var splitlist = apt_data[i].split("<2_2>");
                if (splitlist[0] == "") {
                    num++;
                }
                else {
                    subModel.append({"itemTitle": splitlist[0], "desc": "","number": splitlist[1] + "字节"});
                    systemdispatcher.set_apt_args(splitlist[0]);
                }
            }
            root.sub_num -= num;
            mainModel.clear();
            mainModel.append({"itemTitle": "清理Apt",
                             "picture": "../img/toolWidget/apt.png",
                             "detailstr": "清理Apt可以节省磁盘空间",
                             "flags": "clear_apt",
                            "attributes":
                                 [{"subItemTitle": "Cookies1"},
                                 {"subItemTitle": "Cookies2"},
                                 {"subItemTitle": "Cookies3"},
                                 {"subItemTitle": "Cookies4"}]
                             })
        }
    }



    Connections
    {
        target: systemdispatcher
//         onFinishScanWork: {
//             console.log("begin onFinishScanWork..............");
//             if (btn_flag == "apt_scan") {
//                 console.log("******apt_scan Signal handler received  Start******");
////                 console.log(msg);
//                 titleBar.work_result = msg;
//                 titleBar.state = "AptWork";
////                 console.log("******End******");
//             }

//         }
        onFinishCleanWork: {
//            console.log("33333333333333");
//            console.log(msg);//apt software   package   history   cookies
//            console.log(btn_flag);
            if (btn_flag == "apt_work") {
                if (msg == "apt") {
                    console.log("******Clear Signal handler received  Start apt_work******");
    //                 console.log(msg);
                    root.work_result = msg;
                    root.state = "AptWorkFinish";
                }
            }
        }
    }

    ListModel {
        id: mainModel
        ListElement {
            itemTitle: "清理Apt"
            picture: "../img/toolWidget/apt.png"
            detailstr: "清理Apt可以节省磁盘空间"
            flags: "clear_apt"
            attributes: [
                ListElement { subItemTitle: "" }
            ]
        }
    }

    ListModel {
        id: subModel
        ListElement {itemTitle: ""; desc: ""; number: ""}
    }

//    //背景
    Image {
        source: "../img/skin/bg-onekey.png"
        anchors.fill: parent
    }
    //titlebar
    Row {
        id: titlebar
        spacing: 20
        width: parent.width
//        height: 50
        anchors { top: parent.top; topMargin: 20; left: parent.left; leftMargin: 20 }
        Image {
            id: refreshArrow
            source: "../img/toolWidget/clear-pic.png"
//            width: 50; height: 50
            Behavior on rotation { NumberAnimation { duration: 200 } }
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
//            anchors.left: parent.left
//            anchors.leftMargin: 30
            spacing: 10
            Text {
                text: root.title
                font.bold: true
                font.pixelSize: 14
            }
            Text {
                text: root.description
                font.pixelSize: 12
                color: "#7a7a7a"
            }
        }
        Label {
            id: label
            visible: false
            text: ""
            anchors.right: bitButton.left
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
        }

        Common.Button {
            id: bitButton
            width: 120
            height: 39
            hoverimage: "scan-start.png"
//            text: root.btn_text
            anchors.right: parent.right
            anchors.rightMargin: 50
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                //apt cruft
                 if (btn_flag == "apt_scan") {
                     console.log("apt_scan---------------");
                     apt_signal("AptWork");
                     root.state = "AptWork";
                 }
                 else if (btn_flag == "apt_work") {
                       console.log("apt_work---------------");
                       console.log(systemdispatcher.get_apt_args());
                     systemdispatcher.clean_file_cruft_qt(systemdispatcher.get_apt_args(), "apt");
                 }
            }
        }
    }
    //分割条
    Rectangle {
        id: splitbar
        anchors.top: titlebar.bottom
        anchors.topMargin: 18
        width: parent.width-2
        height: 1
        color: "#b9c5cc"
    }

//    ItemListModel {
//        id: pluginlist
//        anchors.top: titlebar.bottom
//        anchors.topMargin: 20
//        height: parent.height -titlebar.height - 40
//        listmodel: root.listmodel
//        submodel: root.submodel
//        num: root.sub_num
//        btn_flag: root.btn_flag
//    }
    //----------------------------
    Component {
        id: listViewDelegate
        Item {
            id: delegate
            property alias expandedItemCount: subItemRepeater.count
            x: 5; y: 2
            width: root.width
            height: headerItemRect.height + subItemsRect.height

            //母项
            //checkbox, picture and words
            Row {
                id: headerItemRect
                x: 5; y: 2
                width: root.width
                height: root.itemHeight
                spacing: 10
                Image {
                    id: clearImage
                    fillMode: "PreserveAspectFit"
                    height: parent.height*0.9
                    source: picture
                    smooth: true
                }

                Column {
                    id: status_update_content
                    spacing: 5
                    anchors {
                        left: clearImage.right; leftMargin: 15
                        verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: itemTitle
                        font.pointSize: 11
                        color: "black"
                    }
                    Text {
                        text: detailstr
                        font.pointSize: 9
                        color: "gray"
                    }
                }

                Image {
                    id: arrow
                    fillMode: "PreserveAspectFit"
                    height: 28
                    width: 26
//                    height: parent.height*0.3
                    source: root.arrow
                    //当鼠标点击后,箭头图片旋转90度
//                    rotation: expanded ? 90 : 0
                    rotation: expanded ? 0 : -180
                    smooth: true
                    anchors {
                        left: clearImage.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 750
                    }
                }

                MouseArea {
                    id: mouseRegion
                    anchors.fill: status_update_content
                    onPressed: {
//                        console.log(root.width)
                        expanded = !expanded
                    }
                }
            }//母项Row

            //子项
            Item {
                id: subItemsRect
                property int itemHeight: root.itemHeight
                y: headerItemRect.height
                width: root.width
                //当高度需要扩展时,根据expandedItemCount数目和itemHeight高度去扩展
                height: expanded ? delegate.expandedItemCount * itemHeight : 0
                clip: true
                opacity: 1
                Behavior on height {
                    SequentialAnimation {
                        NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                    }
                }

                Column {
                    width: root.width
                    Repeater {
                        id: subItemRepeater
//                        model: attributes
                        model: subModel
//                        model: mysubmodel
                        width: subItemsRect.width
                        /*Common.*/ListItem {
                            id: subListItem
                            width: root.width
                            height: subItemsRect.itemHeight
//                            text: subItemTitle
                            text: itemTitle
                            descript: desc
                            size_num: number
                            checkbox_status: root.check_flag
//                            bgImage: "../../img/icons/list_subitem.png"
                            bgImage: ""
                            fontName: root.subItemFontName
                            fontSize: root.subItemFontSize
                            fontColor: root.subItemFontColor
                            textIndent: 20

                            btn_flag: root.btn_flag

                            onClicked: {/*console.log(number)*/}
                        }

                    }//Repeater
                }//Column
            }//子项Item
        }
    }//Component


    ScrollArea {
        frame:false
        anchors.top: titlebar.bottom
        anchors.topMargin: 30
        height: root.height -titlebar.height - 50
        width: parent.width
        Item {
            width: parent.width
            height: (root.sub_num + 1) * 40 //450 + //this height must be higher than root.height, then the slidebar can display
            //垃圾清理显示内容
            ListView {
                id: listView
                height: parent.height
                model: mainModel
                delegate: listViewDelegate
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
    //----------------------------

    //status picture
    Image {
        id: statusImage
        source: "../img/toolWidget/unfinish.png"
        fillMode: "PreserveAspectFit"
        smooth: true
        anchors {
            top: parent.top; topMargin: 110
            left: parent.left; leftMargin: 650
        }
    }

    states: [
        State {
            name: "AptWork"
             PropertyChanges { target: label; visible: true; text: "apt扫描完成"}
//            PropertyChanges { target: bitButton; text: "开始清理" }
             PropertyChanges { target: bitButton; hoverimage: "scan-ing.png" }
            PropertyChanges { target: root; btn_flag: "apt_work" }
        },

        State {
            name: "AptWorkFinish"
            PropertyChanges { target: label; visible: true; text: root.work_result + "清理完毕！" }
//            PropertyChanges { target: bitButton; text: "开始扫描111" }
            PropertyChanges { target: bitButton; hoverimage: "scan-start.png" }
            PropertyChanges { target: root; btn_flag: "apt_scan" }
            PropertyChanges { target: statusImage; source: "../img/toolWidget/finish.png"}
        }
    ]
}







//Item {
//    id:root
//    width: parent.width
//    height: 435//420//340
////    color:"#c3c3c3"
//    //垃圾清理自定义标题栏
//    property string btn_text: "开始扫描"
//    property string title: "清理Apt"
//    property string description: "清理Apt可以节省磁盘空间"
//    property string btn_flag: "apt_scan"
//    property ListModel listmodel: mainModel
//    property ListModel submodel: subModel
//    property SystemDispatcher dis: systemdispatcher
//    property int sub_num: 0
//    property string work_result: ""

//    signal apt_signal(string apt_msg);
//    onApt_signal: {
//        if (apt_msg == "AptWork") {
//            //get data of cookies
//            console.log("apt_msg == AptWork");
//            var apt_data = systemdispatcher.scan_apt_cruft_qt();
////            console.log("1");
////            console.log(apt_data);
//            root.sub_num = apt_data.length;
////            console.log("3");
////            console.log(root.sub_num);
//            systemdispatcher.clear_apt_args();
//            subModel.clear();
//            var num = 0;
//            for (var i=0; i< apt_data.length; i++) {
////                console.log("111");
////                console.log(apt_data[i]);//sina.com.cn<2_2>10
//                var splitlist = apt_data[i].split("<2_2>");
//                if (splitlist[0] == "") {
//                    num++;
//                }
//                else {
//                    subModel.append({"itemTitle": splitlist[0], "desc": "","number": splitlist[1] + "字节"});
//                    systemdispatcher.set_apt_args(splitlist[0]);
//                }
//            }
//            root.sub_num -= num;
//            mainModel.clear();
//            mainModel.append({"itemTitle": "清理Apt",
//                             "picture": "../img/icons/user.png",
//                             "detailstr": "清理Apt可以节省磁盘空间",
//                             "flags": "clear_apt",
//                            "attributes":
//                                 [{"subItemTitle": "Cookies1"},
//                                 {"subItemTitle": "Cookies2"},
//                                 {"subItemTitle": "Cookies3"},
//                                 {"subItemTitle": "Cookies4"}]
//                             })
//        }
//    }



//    //信号绑定，绑定qt的信号finishCleanWork，该信号emit时触发onFinishCleanWork
//    Connections
//    {
//        target: systemdispatcher
////         onFinishScanWork: {
////             console.log("begin onFinishScanWork..............");
////             if (btn_flag == "apt_scan") {
////                 console.log("******apt_scan Signal handler received  Start******");
//////                 console.log(msg);
////                 titleBar.work_result = msg;
////                 titleBar.state = "AptWork";
//////                 console.log("******End******");
////             }

////         }
//        onFinishCleanWork: {
////            console.log("33333333333333");
////            console.log(msg);//apt software   package   history   cookies
////            console.log(btn_flag);
//            if (btn_flag == "apt_work") {
//                if (msg == "apt") {
//                    console.log("******Clear Signal handler received  Start apt_work******");
//    //                 console.log(msg);
//                    root.work_result = msg;
//                    root.state = "AptWorkFinish";
//                }
//            }
//        }
//    }

//    ListModel {
//        id: mainModel
//        ListElement {
//            itemTitle: "清理Apt"
//            picture: "../img/icons/user.png"
//            detailstr: "清理Apt可以节省磁盘空间"
//            flags: "clear_apt"
//            attributes: [
//                ListElement { subItemTitle: "" }
//            ]
//        }
//    }

//    ListModel {
//        id: subModel
//        ListElement {itemTitle: ""; desc: ""; number: ""}
//    }

//    //titlebar
//    Row {
//        id: titlebar
//        spacing: 50
//        width: parent.width
//        height: 50
//        Column {
//            anchors.verticalCenter: parent.verticalCenter
//            anchors.left: parent.left
//            anchors.leftMargin: 30
////                width: parent.width - 150
//            spacing: 2
//            Text {
//                text: root.title
//                font.bold: true
//                font.pixelSize: 14
//            }
//            Text {
//                text: root.description
//                font.pixelSize: 12
//                color: "#7a7a7a"
//            }
//        }
//        Label {
//            id: label
//            visible: false
//            text: ""
//            anchors.right: bitButton.left
//            anchors.rightMargin: 20
//            anchors.verticalCenter: parent.verticalCenter
//        }
//        Button {
//            id: bitButton
//            width: 95
//            height: 32
//            text: root.btn_text
//            anchors.right: parent.right
//            anchors.rightMargin: 50
//            anchors.verticalCenter: parent.verticalCenter
//            onClicked: {
//                //apt cruft
//                 if (btn_flag == "apt_scan") {
//                     console.log("apt_scan---------------");
//                     apt_signal("AptWork");
//                     root.state = "AptWork";
//                 }
//                 else if (btn_flag == "apt_work") {
//                       console.log("apt_work---------------");
//                       console.log(systemdispatcher.get_apt_args());
//                     systemdispatcher.clean_file_cruft_qt(systemdispatcher.get_apt_args(), "apt");
//                 }
//            }
//        }
//    }

//    ItemListModel {
//        id: pluginlist
//        anchors.top: titlebar.bottom
//        height: parent.height -titlebar.height
//        listmodel: root.listmodel
//        submodel: root.submodel
//        num: root.sub_num
//        btn_flag: root.btn_flag
//    }


//    states: [
//        State {
//            name: "AptWork"
//             PropertyChanges { target: label; visible: true; text: "apt扫描完成"}
//            PropertyChanges { target: bitButton; text: "开始清理" }
//            PropertyChanges { target: root; btn_flag: "apt_work" }
//        },

//        State {
//            name: "AptWorkFinish"
//            PropertyChanges { target: label; visible: true; text: root.work_result + "清理完毕！" }
//            PropertyChanges { target: bitButton; text: "开始扫描" }
//            PropertyChanges { target: root; btn_flag: "apt_scan" }
//        }
//    ]
//}

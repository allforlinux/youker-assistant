/*
 * Copyright (C) 2013 ~ 2015 National University of Defense Technology(NUDT) & Kylin Ltd.
 *
 * Authors:
 *  Kobe Lee    xiangli@ubuntukylin.com/kobe24_lixiang@126.com
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

#include "autogroup.h"
#include "utils.h"
#include <QPalette>

AutoGroup::AutoGroup(QWidget *parent) :
    QWidget(parent)
{
    this->resize(400, 50);
    //边框
//    this->setStyleSheet("border:1px solid black;");

    //背景
//    this->setAutoFillBackground(true);
//    QPalette palette;
////    palette.setColor(QPalette::Background, QColor(192,253,123));
//    palette.setBrush(QPalette::Background, QBrush(QPixmap(":/background/res/bg/6.png")));
//    this->setPalette(palette);


//    h_layout = new QHBoxLayout();
    logo_label = new QLabel();
    name_label = new QLabel();
    comment_label = new QLabel();
    switcher = new KylinSwitcher();
    connect(switcher, SIGNAL(clicked()), this, SIGNAL(autoStatusChange()));
//    key_info->setFixedSize(180, ITEMHEIGHT);
//    value_info->setFixedHeight(ITEMHEIGHT);

//    QFont font = key_info->font();
//    font.setPointSize(14);
//    key_info->setFont(font);
//    key_info->setObjectName("titleLabel");
//    value_info->setFont(font);
//    value_info->setObjectName("grayLabel");

    QVBoxLayout *v_layout = new QVBoxLayout();
    v_layout->addWidget(name_label);
    v_layout->addWidget(comment_label);
    QHBoxLayout *h_layout = new QHBoxLayout();
    h_layout->addWidget(logo_label);
    h_layout->addLayout(v_layout);
    h_layout->addStretch();
    h_layout->addWidget(switcher);
    h_layout->setSpacing(10);
    h_layout->setMargin(0);//设置总的外围边框
    h_layout->setContentsMargins(0,0,0,0);
    setLayout(h_layout);

//    this->initData();
}

//void AutoGroup::pushMap(QString key, QString value)
//{
//    this->name[key] = value;
//}

void AutoGroup::setLanguage(QString key, QString value)
{
//    key_info->setText(tr("%1:").arg(key));
//    value_info->setText(tr("%1").arg(value));
}

void AutoGroup::initData(QMap<QString,QString> data)
{
//    logo_label = new QLabel();
//    logo_label->setScaledContents(true);//自动缩放,显示图像大小自动调整为Qlabel大小
//    QPixmap label_pixmap("://res/ubuntukylin.png");
//    logo_label->setPixmap(label_pixmap);
////    logo_label->setFixedSize(label_pixmap.size());
//    logo_label->setFixedSize(40, 40);
//    name_label->setText("app");
//    comment_label->setText("app comment");
//    switcher->switchedOn = true;
//    QString abs_path = data.value("Path");
//    int  start_pos = abs_path.lastIndexOf("/") + 1;
//    int end_pos = abs_path.length();
//    dekstopFile = abs_path.mid(start_pos, end_pos-start_pos);
    dekstopFile = data.value("Path");
    logo_label->setScaledContents(true);//自动缩放,显示图像大小自动调整为Qlabel大小
    if(data.value("Icon").isEmpty())
    {
        QPixmap label_pixmap("://res/ubuntukylin.png");
        logo_label->setPixmap(label_pixmap);
    }
    else
    {
        QPixmap label_pixmap(data.value("Icon"));
        logo_label->setPixmap(label_pixmap);
    }
//    logo_label->setFixedSize(label_pixmap.size());
    logo_label->setFixedSize(40, 40);
    name_label->setText(data.value("Name"));
    if(data.value("Comment").isEmpty())
    {
        comment_label->setText(data.value("NONE"));
    }
    else
    {
        comment_label->setText(data.value("Comment"));
    }

    if(data.value("Status") == "true")
        switcher->switchedOn = true;
    else
        switcher->switchedOn = false;
}

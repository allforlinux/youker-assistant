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

#include "cleanlistwidget.h"
#include "ui_cleanlistwidget.h"
#include <QDebug>
#include <QVBoxLayout>
#include <QSignalMapper>
//#include "../dbusproxy/youkersessiondbus.h"
#include "../component/utils.h"


CleanListWidget::CleanListWidget(QStringList &arglist, const QString title_text, QWidget *parent/*, SessionDispatcher *proxy*/) :
    QWidget(parent),titleName(title_text),
    ui(new Ui::CleanListWidget)//sessionproxy(proxy),
{
    ui->setupUi(this);
    this->setFixedSize(560, 398);
    setWindowFlags(Qt::FramelessWindowHint);
    tip_label = new QLabel();
    num_label = new QLabel();

    ui->widget_1->setAutoFillBackground(true);
    QPalette palette;
    palette.setColor(QPalette::Background, QColor(233,238,241));//#e9eef1
    ui->widget_1->setPalette(palette);

    ui->scrollArea->setAutoFillBackground(true);
    palette.setBrush(QPalette::Window, QBrush(Qt::white));
    ui->scrollArea->setPalette(palette);

    tip_label->setText(tr("Clean Items:"));

    QHBoxLayout *tip_layout = new QHBoxLayout();
    tip_layout->addWidget(tip_label);
    tip_layout->addWidget(num_label);
    tip_layout->addStretch();
    tip_layout->setSpacing(0);
    tip_layout->setMargin(0);
    tip_layout->setContentsMargins(20, 0, 0, 0);
    ui->widget_1->setLayout(tip_layout);

    title_bar = new KylinTitleBar(this);
    title_bar->move(0,0);
    title_bar->show();
    initTitleBar();
    ui->scrollArea->setFixedSize(560,333);


    QVBoxLayout *button_layout = new QVBoxLayout;
    int count = arglist.count();
    num_label->setText(QString::number(count));
    //    QSignalMapper *signal_mapper = new QSignalMapper(this);
    for(int i=0; i<count; i++)
    {
//        qDebug() << arglist.at(i);
        QCheckBox *checkbox = new QCheckBox(arglist.at(i));
        checkbox->setFocusPolicy(Qt::NoFocus);
        checkbox->setCheckState(Qt::Checked);
        checkbox_list.append(checkbox);
//        connect(checkbox, SIGNAL(clicked()), signal_mapper, SLOT(map()));
        connect(checkbox, SIGNAL(clicked()), this, SLOT(scanAllSubCheckbox()));
//        signal_mapper->setMapping(checkbox, QString::number(i, 10));
        button_layout->addWidget(checkbox);
    }
    button_layout->setSpacing(20);
    button_layout->setMargin(0);
    button_layout->setContentsMargins(0, 0, 0, 0);
//    connect(signal_mapper, SIGNAL(mapped(QString)), this, SLOT(switchPageIndex(QString)));
//    setLayout(button_layout);

    QVBoxLayout *layout  = new QVBoxLayout();
//    layout->addWidget(title_bar);
    layout->addLayout(button_layout);
    layout->addStretch();
//    layout->addWidget(scroll_widget);
    layout->setSpacing(0);
    layout->setMargin(0);
    layout->setContentsMargins(10, 0, 10, 10);
    ui->scrollAreaWidgetContents->setLayout(layout);

    this->setLanguage();
    this->initConnect();
}

CleanListWidget::~CleanListWidget()
{
    delete ui;
}

//void CleanListWidget::initData()
//{
//    sessionproxy->getAutoStartAppStatus();
//}

QStringList CleanListWidget::getSelectedItems()
{
    QStringList text_list;
    int count = checkbox_list.count();
    for(int i=0; i<count; i++)
    {
        QCheckBox *checkbox = checkbox_list.at(i);
        if (checkbox->isChecked()) {
            text_list.append(checkbox->text());
        }
    }
    return text_list;
}

void CleanListWidget::scanAllSubCheckbox() {
    int count = checkbox_list.count();
    int m = 0;
    for(int i=0; i<count; i++)
    {
        QCheckBox *checkbox = checkbox_list.at(i);
        if (checkbox->isChecked()) {
            m +=1;
        }
    }
    num_label->setText(QString::number(m));
    if (m == 0) {
        emit this->notifyMainCheckBox(0);
    }
    else if (m == count) {
        emit this->notifyMainCheckBox(2);
    }
    else {
        emit this->notifyMainCheckBox(1);
    }
}

void CleanListWidget::resetSubCheckbox(int status) {
    if(status == 0) {
        for(int i=0; i<checkbox_list.count(); i++)
        {
            QCheckBox *checkbox = checkbox_list.at(i);
            checkbox->setChecked(false);
        }
    }
    else if(status == 2) {
        for(int i=0; i<checkbox_list.count(); i++)
        {
            QCheckBox *checkbox = checkbox_list.at(i);
            checkbox->setChecked(true);
        }
    }
}

void CleanListWidget::setLanguage()
{

}

void CleanListWidget::initConnect()
{
    connect(title_bar,SIGNAL(closeDialog()), this, SLOT(onCloseButtonClicked()));
}

void CleanListWidget::initTitleBar()
{
    title_bar->setTitleWidth(560);
    title_bar->setTitleName(titleName);
    title_bar->setTitleBackgound(":/background/res/skin/1.png");
}

void CleanListWidget::onCloseButtonClicked()
{
    this->close();
}

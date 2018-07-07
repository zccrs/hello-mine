import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.4

import "GameCommon.js" as Common

Window {
    id: rootWindow

    property var mineMap
    property int mineMapWidth: radioGroup.checkedButton.columns
    property int mineMapHeight: radioGroup.checkedButton.rows
    property int gameState: Common.GameStateEnum.NormalState
    property int mineCount: mineMapWidth * mineMapHeight * mineMapHeight / 60
    property int markedMineCount: 0
    property int gameStartTime: 0

    visible: true
    width: 640
    height: 480
    title: "Hello Mine(点击翻开土地, [长按/右键/Ctrl+左键][标记/取消标记])"

    function beginGame(safeIndex) {
        mineMap = Common.createMineMap(mineMapWidth, mineMapHeight, mineCount, safeIndex);

        //                            for (var i in rootWindow.mineMap) {
        //                                console.log(i, ": ", rootWindow.mineMap[i]);
        //                            }

        gameState = Common.GameStateEnum.GameingState;
        markedMineCount = 0;
    }

    function resetGame() {
        gameState = Common.GameStateEnum.NormalState;
        rootWindow.mineMap = undefined;
        markedMineCount = 0;
    }

    MessageDialog {
        id: messageDialog

        title: "Game Over"
        text: "Retry?"
        icon: StandardIcon.Critical
        modality: Qt.ApplicationModal
        standardButtons: StandardButton.Retry | StandardButton.Cancel

        onAccepted: {
            rootWindow.resetGame();
        }

        onRejected: close();
    }

    ButtonGroup { id: radioGroup }

    Row {
        id: buttonRow

        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            Timer {
                id: gameTimer
                running: gameState === Common.GameStateEnum.GameingState
                interval: 1000
                repeat: true

                onTriggered: {
                    rootWindow.gameStartTime++;
                }

                onRunningChanged: {
                    if (gameState === Common.GameStateEnum.NormalState) {
                        rootWindow.gameStartTime = 0;
                    }
                }
            }

            text: {
                var string = "⏲:";
                var minute = Math.floor(gameStartTime / 60);
                var hour = Math.floor(minute / 60);
                var second = gameStartTime % 60;

                if (hour > 0) {
                    string += hour + "小时";
                }

                if (minute > 0) {
                    string += minute + "分钟";
                }

                string += second + "秒"

                return string;
            }

            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 20
        }

        RadioButton {
            property int columns: 10
            property int rows: 6

            enabled: rootWindow.gameState === Common.GameStateEnum.NormalState
            text: "我是菜鸟"
            ButtonGroup.group: radioGroup
        }

        RadioButton {
            property int columns: 16
            property int rows: 9

            enabled: rootWindow.gameState === Common.GameStateEnum.NormalState
            checked: true
            text: "正常人"
            ButtonGroup.group: radioGroup
        }

        RadioButton {
            property int columns: 20
            property int rows: 12

            enabled: rootWindow.gameState === Common.GameStateEnum.NormalState
            text: "挑战一下"
            ButtonGroup.group: radioGroup
        }

        RadioButton {
            property int columns: 30
            property int rows: 17

            enabled: rootWindow.gameState === Common.GameStateEnum.NormalState
            text: "变态"
            ButtonGroup.group: radioGroup
        }

        RadioButton {
            property int columns: 50
            property int rows: 28

            enabled: rootWindow.gameState === Common.GameStateEnum.NormalState
            text: "我不服"
            ButtonGroup.group: radioGroup
        }

        Button {
            anchors.verticalCenter: parent.verticalCenter
            width: 50
            height: 24
            text: "restart"
            onClicked: {
                gameState = Common.GameStateEnum.NormalState;
                rootWindow.mineMap = undefined;
            }
        }
    }

    Grid {
        id: mineGrid

        enabled: rootWindow.gameState !== Common.GameStateEnum.OverState
        columns: rootWindow.mineMapWidth
        rows: rootWindow.mineMapHeight
        spacing: 2
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: buttonRow.bottom
            topMargin: 20
        }

        Repeater {
            id: repeater

            model: parent.rows * parent.columns
            delegate: Rectangle {
                property bool cleared: false
                property int mineMapValue: 0

                color: {
                    if (mineMapValue === -2) {
                        return "red";
                    }

                    if (cleared) {
                        if (mineMapValue < 0)
                            return rootWindow.markedMineCount === rootWindow.mineCount ? "white" :  "black";

                        return "green";
                    }

                    return "#2F4F4F";
                }

                width: (rootWindow.width - 40) / rootWindow.mineMapWidth - 2
                height: width
                radius: 2

                function getNeighbors() {
                    var x = index % rootWindow.mineMapWidth;
                    var y = Math.floor(index / rootWindow.mineMapWidth);

                    var list = [(y - 1) * rootWindow.mineMapWidth + x - 1, //0: left top
                                (y - 1) * rootWindow.mineMapWidth + x, //1: top
                                (y - 1) * rootWindow.mineMapWidth + x + 1, //2: right top
                                index + 1, //3: right
                                (y + 1) * rootWindow.mineMapWidth + x + 1, //4: right bottom
                                (y + 1) * rootWindow.mineMapWidth + x, //5: bottom
                                (y + 1) * rootWindow.mineMapWidth + x - 1, //6: left bottom
                                index - 1];//7: left

                    if (y === 0) {
                        list[0] = list[1] = list[2] = undefined;
                    }

                    if (x === 0) {
                        list[6] = list[7] = list[0] = undefined;
                    }

                    if (y === rootWindow.mineMapHeight - 1) {
                        list[4] = list[5] = list[6] = undefined;
                    }

                    if (x === rootWindow.mineMapWidth - 1) {
                        list[2] = list[3] = list [4] = undefined;
                    }

                    for (var i in list) {
                        var _inddex = list[i];

                        if (_inddex !== undefined) {
                            list[i] = repeater.itemAt(_inddex)
                        }
                    }

                    return list;
                }

                function clear() {
                    if (cleared)
                        return;

                    mineMapValue = Common.getMineMapValueByIndex(rootWindow.mineMap, rootWindow.mineMapWidth, index)
                    cleared = true;

                    if (mineMapValue === -1) {
                        if (rootWindow.gameState === Common.GameStateEnum.OverState)
                            return;

                        rootWindow.gameState = Common.GameStateEnum.OverState;
                        radius = width / 2;
                        messageDialog.open();
                    } else if (mineMapValue === 0) {
                        var neighbors = getNeighbors();

                        for (var i in neighbors) {
                            if (neighbors[i]) {
                                neighbors[i].clear();
                            }
                        }
                    }
                }

                function reset() {
                    cleared = false;
                    mineMapValue = 0;
                    radius = 0;
                }

                function toggleMark() {
                    if (cleared)
                        return;

                    var value = Common.getMineMapValueByIndex(rootWindow.mineMap, rootWindow.mineMapWidth, index);

                    if (mineMapValue === -2) {
                        mineMapValue = 0;

                        if (value === -1) {
                            --rootWindow.markedMineCount;
                        }
                    } else {
                        mineMapValue = -2;

                        if (value === -1) {
                            ++rootWindow.markedMineCount;

                            // 已标记所有地雷
                            if (rootWindow.markedMineCount === rootWindow.mineCount) {
                                rootWindow.gameState = Common.GameStateEnum.OverState;
                            }
                        }
                    }
                }

                Connections {
                    target: rootWindow
                    onGameStateChanged: {
                        if (rootWindow.gameState === Common.GameStateEnum.NormalState) {
                            reset();
                        } else if (rootWindow.gameState === Common.GameStateEnum.OverState) {
                            clear();
                        }
                    }
                }

                Text {
                    id: label

                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: parent.height * 2 / 3.0
                    text: parent.mineMapValue > 0 ? parent.mineMapValue : ""
                    //                    text: rootWindow.mineMap ? Common.getMineMapValueByIndex(rootWindow.mineMap, rootWindow.mineMapWidth, index) : ""
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton | Qt.LeftButton
                    onClicked:  {
                        if (mouse.button === Qt.RightButton || mouse.modifiers === Qt.ControlModifier) {
                            parent.toggleMark();
                        } else if (mouse.button === Qt.LeftButton) {
                            if (mineMapValue === -2 || cleared)
                                return;

                            if (rootWindow.gameState === Common.GameStateEnum.NormalState) {
                                rootWindow.beginGame(index);
                            }

                            clear();
                        }
                    }

                    onPressAndHold: {
                        parent.toggleMark();
                    }
                }
            }
        }
    }
}

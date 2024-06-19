import QtQuick 2.0

import HmiGuiFramework 1.0
import Hmi.Ford.Views 1.0
import HmiGuiFramework.Controls 1.0
import HmiGui 1.0
import Hmi.Ford 1.0
import HmiClimate 1.0

import "../hmiclimate/climate-utils.js" as ClimateUtils
import AL2HMIBridge 1.0 as AL2HMIBridge
FullScreenView {
    id: root
    //touchinputreceiverthread.cpp is specifically checking for objectName to be "ProjectionView"
    objectName: "ProjectionView"

    height: 480 + 72 // FORDSYNC3-12529: (Per Rob M.) this is safe because 10L (which uses 720) is file-selected.
    transparentWindow: true
    transientsAllowed: true
    blockedTransients: [
        "BluetoothConnected",
        "BluetoothAttemptingReconnect",
        "BluetoothNotConnected"
    ]
    
    //property bool sourceAA: AL2HMIBridge.projectionSource.projectionMode == AL2HMIBridge.ProjectionSource.Projection_GAL

	function setStatus() {
		var xhr = new XMLHttpRequest();
		var rvcStatus = "enabled";
		xhr.open("PUT", "file:///fs/rwdata/customSettings/rvc/camera_control");
		xhr.send(rvcStatus);
	}

    function readPosX(id) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///fs/rwdata/customSettings/ProjectionWidget/"+id+"PosX",false);
        xhr.send();
        return xhr.responseText;
	}

    function readPosY(id) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///fs/rwdata/customSettings/ProjectionWidget/"+id+"PosY",false);
        xhr.send();
        return xhr.responseText;
	}
    
    function storeNewPosition(id, posX, posY) {
        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "file:///fs/rwdata/customSettings/ProjectionWidget/"+id+"PosX", false);
        xhr.send(posX);
        var xhr2 = new XMLHttpRequest();
        xhr2.open("PUT", "file:///fs/rwdata/customSettings/ProjectionWidget/"+id+"PosY", false);
        xhr2.send(posY);
    }

    Rectangle {
		id: rearCameraWidget
        x: readPosX(camera)
        y: readPosY(camera)
        width: 60
        height: 60
        color: "black"
        opacity: 1
        radius: 14
        visible: true

        MouseArea {
           id: itemMouseArea
           property bool beepOnClick: true
           anchors.fill: parent
           drag.target: parent
           drag.axis: Drag.XAndYAxis

           onPressed: {
                rearCameraWidget.color = 'gray';
           }
           onClicked: {
               setStatus();
           }

           onReleased: {
                rearCameraWidget.color = "black";
                if(rearCameraWidget.y < 0) rearCameraWidget.y = 0;
                if(rearCameraWidget.y > 420) rearCameraWidget.y = 420;
                if(rearCameraWidget.x < 0) rearCameraWidget.x = 0;
                if(rearCameraWidget.x > 740) rearCameraWidget.x = 740;
                storeNewPosition(camera, rearCameraWidget.x,rearCameraWidget.y)
           }
        }
	}

    HmiImage {
			id: rvcIcon
            anchors.centerIn: rearCameraWidget
            visible: true		
			source: touchArea.pressed ? UiTheme.palette.icon("40x40/DAT/icon_rear_camera_view_selected") : UiTheme.palette.icon("40x40/DAT/icon_rear_camera_view_selectedpressed")
		}

    Rectangle {
        id: outsideTemperatureLabelBG
        x: readPosX(temp)
        y: readPosY(temp)
        width: 60
        height: 60
        color: "black"
        opacity: 1
        radius: 14
        visible: true

        MouseArea {
           id: itemMouseArea
           property bool beepOnClick: true
           anchors.fill: parent
           drag.target: parent
           drag.axis: Drag.XAndYAxis

           onPressed: {
                outsideTemperatureLabelBG.color = 'gray';
           }
           onClicked: {
               _homeController.goHome();
           }

           onReleased: {
                outsideTemperatureLabelBG.color = "black";
                if(outsideTemperatureLabelBG.y < 0) outsideTemperatureLabelBG.y = 0;
                if(outsideTemperatureLabelBG.y > 420) outsideTemperatureLabelBG.y = 420;
                if(outsideTemperatureLabelBG.x < 0) outsideTemperatureLabelBG.x = 0;
                if(outsideTemperatureLabelBG.x > 740) outsideTemperatureLabelBG.x = 740;
                storeNewPosition(temp, outsideTemperatureLabelBG.x,outsideTemperatureLabelBG.y)
           }
        }
    }

    TextLabel {
        id: outsideTemperatureLabel
        anchors.centerIn: outsideTemperatureLabelBG
        visible: true
        text: AL2HMIBridge.climateSource.outsideAirTemperatureAvailable
                    && ((AL2HMIBridge.globalSource.vehicleIgnitionStatus === AL2HMIBridge.GlobalSource.VehicleIgnitionStatus_Run)
                    || (AL2HMIBridge.globalSource.vehicleIgnitionStatus === AL2HMIBridge.GlobalSource.VehicleIgnitionStatus_Crank)) ? ClimateUtils.getOutsideAirTemperature() : "--°"
        font: variationOverride({"size": 25, "family": "HelveticaNeueForFord-ACKe Rom"})
        color: 'white'
    }
}

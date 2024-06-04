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

     function readPosX() {
	var xhr = new XMLHttpRequest();
	xhr.open("GET", "file:///fs/rwdata/customSettings/ProjectionWidget/posX",false);
	xhr.send();
	return xhr.responseText;
	}

     function readPosY() {
	var xhr = new XMLHttpRequest();
	xhr.open("GET", "file:///fs/rwdata/customSettings/ProjectionWidget/posY",false);
	xhr.send();
	return xhr.responseText;
	}
    
    function storeNewPosition(posX, posY) {
        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "file:///fs/rwdata/customSettings/ProjectionWidget/posX", false);
        xhr.send(posX);
        var xhr2 = new XMLHttpRequest();
        xhr2.open("PUT", "file:///fs/rwdata/customSettings/ProjectionWidget/posY", false);
        xhr2.send(posY);
    }

    Rectangle {
        id: outsideTemperatureLabelBG
        x: readPosX()
        y: readPosY()
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
                storeNewPosition(outsideTemperatureLabelBG.x,outsideTemperatureLabelBG.y)
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

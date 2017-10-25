#include "ofApp.h"

int main() {
	
  
    
    ofiOSWindowSettings settings;
    settings.enableRetina = false;
    settings.enableDepth = false;
    settings.enableAntiAliasing = false;
    settings.numOfAntiAliasingSamples = 0;
    settings.enableHardwareOrientation = false;
    settings.enableHardwareOrientationAnimation = false;
    settings.glesVersion = OFXIOS_RENDERER_ES2;
    
    ofCreateWindow(settings);
    
    return ofRunApp(new ofApp);
}


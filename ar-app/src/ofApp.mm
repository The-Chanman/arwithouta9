#include "ofApp.h"

static const string licenseKey = "Ae9EM2z/////AAAAGYDthRucfE4/uW4XvjSy+OgwfZue4UfofAgog3nyru7Qc/Cvnz1T3zSFgXc5H9xVY66vuU0LA2Eie/7r7VP83/azab+1z42ZYSELOywQ1p6CQj2P4EYK8zE3JHsKEaCn7pwJPKKsP4xVjcTTgi3HzFn+9YkRUh1C/TZ6vAp5v5fRTP+i0DUX+b0x8aIarAlEDiiZvMpfP1f9btQgBQl7yB8RfszqN88N9k8F3gzm6/lnYXPMOq0cCtzpURIvAwkD9B53BijHAQvGlVBEQG6YTdipPfsLRlTD1BgAziu/eC1pIeewt1cCmgXNmjrtXDF+XIXCOLuxX0gRnWmQG57OskElq513y2jKjnzimFyscZe/";

//--------------------------------------------------------------
void ofApp::setup() {
    ofSetLogLevel(OF_LOG_VERBOSE);
	ofBackground(0);
    ofSetOrientation(OF_ORIENTATION_DEFAULT);
	
    ofDisableArbTex(); // we need GL_TEXTURE_2D for our models coords.
    ofEnableDepthTest();
    
	// null out touchpoint
    touchPoint.x = touchPoint.y = -1;
	
	// setup vuforia
    ofxQCAR & QCAR = *ofxQCAR::getInstance();
    QCAR.setLicenseKey(licenseKey);
    QCAR.addMarkerDataPath("database/SampleTargets1.xml");
    QCAR.autoFocusOn();
    QCAR.setCameraPixelsFlag(true);
    QCAR.setup();
	
	lastLoadedVideoName = "";
    lastLoadedModelIndex = -1;
    alpha = 0;
    
    
    glShadeModel(GL_SMOOTH); //some model / light stuff
    light.enable();
//    ofEnableSeparateSpecularLight();
    NSLog(@"IS LIGHTING ENABLED? %@",light.getIsEnabled()? @"YES" : @"NO");
}

//--------------------------------------------------------------
void ofApp::loadVideoForTag(string tag) {
	string videoName = videoNameFromTag(tag);

	if (lastLoadedVideoName != videoName) {
		cout << "Load video " << videoName << endl;
		video.stop();
		video.close();
		video.load("videos/"+videoName);
		video.play();
		lastLoadedVideoName = videoName;
	}
}

//--------------------------------------------------------------
bool ofApp::isVideoLoaded(string tag) {
	string videoName = videoNameFromTag(tag);
	return videoName == lastLoadedVideoName;
}

//--------------------------------------------------------------
string ofApp::videoNameFromTag(string tag) {
	
	if (tag == "statehouse") {
		return "video-1-720.mov";
	}
	
	
	return "";
}

//--------------------------------------------------------------
void ofApp::loadModel(string modelString){
    int modelIndex = modelNameFromTag(modelString);
    
    switch(modelIndex){
        case 0:
            model.loadModel("Modesty Veiled Armchair/Modesty Veiled Armchair.DAE");
            model.setScale(10, 10, 10);
            model.setRotation(0, 90, 1, 0, 0);
            break;
        case 1:
        {   model.loadModel("astroBoy_walk.dae");
            model.setScale(10, 10, 10);
            model.setRotation(0, 90, 1, 0, 0);
//            ofSetGlobalAmbientColor(ofColor(255));
//            ofEnableSeparateSpecularLight();
            light.setDiffuseColor(ofColor(0.0, 255.0, 0.0));
            
            light.setPointLight();
            break;
        }
        default:
            
            break;
    }
    
    model.setLoopStateForAllAnimations(OF_LOOP_NORMAL);
    model.playAllAnimations();
    lastLoadedModelIndex = modelIndex;
}
void ofApp::setLightOri(ofLight &light, ofVec3f rot) {
    ofVec3f xax(1, 0, 0);
    ofVec3f yax(0, 1, 0);
    ofVec3f zax(0, 0, 1);
    ofQuaternion q;
    q.makeRotate(rot.x, xax, rot.y, yax, rot.z, zax);
    light.setOrientation(q);
}

//--------------------------------------------------------------
int ofApp::modelNameFromTag(string tag) {
    
    if (tag == "statehouse") {
        return 1;
    }
    
    
    return -1;
}
//--------------------------------------------------------------
bool ofApp::isModelLoaded(string tag) {
    int videoName = modelNameFromTag(tag);
    return videoName == lastLoadedModelIndex;
}

//--------------------------------------------------------------
void ofApp::update(){
    ofxQCAR & QCAR = *ofxQCAR::getInstance();
    QCAR.update();
    video.update();
    model.update();
	
	if(!QCAR.hasFoundMarker()) {
		fbo.begin();
		ofClear(0, 0, 0, 0);
		ofFill();
		ofSetColor(0);
		ofDrawRectangle(0, 0, fbo.getWidth(), fbo.getHeight());
		fbo.end();
	}
}



//--------------------------------------------------------------
void ofApp::draw(){
	
	// get instance to the vuforia app
    ofxQCAR & QCAR = *ofxQCAR::getInstance();
	
	// draw the camera pixels
	QCAR.drawBackground();
    
	// flag to see if we touched the marker.
    bool bPressed;
    bPressed = touchPoint.x >= 0 && touchPoint.y >= 0;
	
	// if we found a marker un-pause the video instance
    video.setPaused(!QCAR.hasFoundMarker());
	
	// lerp that alpha to 100%
    alpha = ofLerp(alpha, QCAR.hasFoundMarker() ? 255 : 0, 0.1);
	
	// did we find something
    if(QCAR.hasFoundMarker()) {
        
        for (int i=0; i<QCAR.numOfMarkersFound(); i++) {
			
            ofxQCAR_Marker marker = QCAR.getMarker(i);
            cout << marker.markerName << endl;
			
			float mw = marker.markerRect.getWidth();
			float mh = marker.markerRect.getHeight();
			
			// re-allocate the buffer if the marker does
			// not match the fbo current size
			if(fbo.getWidth() != mw || fbo.getHeight() != mh) {
				fbo.allocate(mw, mh);
				fbo.begin();
				ofClear(0, 0, 0, 0);
				fbo.end();
			}
			
			// if this video is not loaded we need to load it
			// based on the mark that is found.
            if (!isVideoLoaded(marker.markerName)) {
                loadVideoForTag(marker.markerName);
            }
            
            // if this a model and its not loaded we need to load it
            if (!isModelLoaded(marker.markerName)){
                loadModel(marker.markerName);
            }
			
			// draw the video in the fbo, this is a ghetto
			// way to mask the video...
			fbo.begin();
			ofClear(0, 0, 0, 0);
			float r1 = video.getWidth() / video.getHeight();
			// float r2 = video.getHeight() / video.getWidth();
			ofSetColor(255);
			video.draw(0, 0, mh*r1, mh);
			fbo.end();
			
			
            ofDisableDepthTest();
            ofEnableBlendMode(OF_BLENDMODE_ALPHA);
            ofSetLineWidth(3);
			
			// are we inside the markers bounds and pressed down
            bool bInside = false;
            if(bPressed) {
                vector<ofPoint> markerPoly;
                markerPoly.push_back(QCAR.getMarkerCorner((ofxQCAR_MarkerCorner)0, i));
                markerPoly.push_back(QCAR.getMarkerCorner((ofxQCAR_MarkerCorner)1, i));
                markerPoly.push_back(QCAR.getMarkerCorner((ofxQCAR_MarkerCorner)2, i));
                markerPoly.push_back(QCAR.getMarkerCorner((ofxQCAR_MarkerCorner)3, i));
                bInside = ofInsidePoly(touchPoint, markerPoly);
            }
            
            if(bInside == true) {
				// maybe play video fullscreen?
            }
			
            //QCAR.drawMarkerRect();
            //QCAR.drawMarkerBounds();;
            //QCAR.drawMarkerCenter();
            //QCAR.drawMarkerCorners();
            ofSetColor(255);
            ofSetLineWidth(1);
            ofEnableDepthTest();
			
            
			//ofEnableNormalizedTexCoords();
            QCAR.begin(i);
            ofSetRectMode(OF_RECTMODE_CENTER);
			ofSetColor(255, alpha);
            fbo.draw(0, 0);
            ofSetColor(255);
            ofEnableAlphaBlending();
//            light.draw();
            model.drawFaces();
            ofSetRectMode(OF_RECTMODE_CORNER);
			QCAR.end();
            
        }
		
    }
	
    ofDisableDepthTest();
	
	// ya - a hack to cover the watermark :|
	ofFill();
	ofSetColor(0);
	ofDrawRectangle(0, ofGetHeight()-40, ofGetWidth(), 40);
}


//--------------------------------------------------------------
void ofApp::exit(){
    ofxQCAR::getInstance()->exit();
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    touchPoint.set(touch.x, touch.y);
    markerPoint = ofxQCAR::getInstance()->screenPointToMarkerPoint(ofVec2f(touch.x, touch.y));
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    touchPoint.set(touch.x, touch.y);
    markerPoint = ofxQCAR::getInstance()->screenPointToMarkerPoint(ofVec2f(touch.x, touch.y));
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    touchPoint.set(-1, -1);
    markerPoint = ofxQCAR::getInstance()->screenPointToMarkerPoint(ofVec2f(touch.x, touch.y));
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}


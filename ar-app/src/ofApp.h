#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxQCAR.h"
#include "ofxAssimpModelLoader.h"
#include "ofxiOS.h"

class ofApp : public ofxQCAR_App {
	
public:
    void setup();
    void update();
    void draw();
    void exit();
	
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);

	// load a video for the marker that was found
	void loadVideoForTag(string tag);
	
	// did we already load this video
	bool isVideoLoaded(string tag);
	
	// store the last video loaded
	string lastLoadedVideoName;
	
	// get video path from tag name
	string videoNameFromTag(string tag);
	
	// main render fbo
	ofFbo fbo;
	
	// touch point for markers
    ofVec2f touchPoint;
	
	// marker point for rendering
    ofVec2f markerPoint;
	
	// video player for markers
    ofVideoPlayer video;
	
	// opactiy to fade in videos
    float alpha;
    
    // create an assimp Model Loader for them 3D files woohoo
    ofxAssimpModelLoader model;
    
    // Lighting
    void setLightOri(ofLight &light, ofVec3f rot);
    
    // Loading function for the 3D models
    void loadModel(string modelIndex);
    
    // did we already load this video
    bool isModelLoaded(string tag);
    
    // store the last video loaded
    int lastLoadedModelIndex;
    
    // get video path from tag name
    int modelNameFromTag(string tag);
    
    ofLight light;
};



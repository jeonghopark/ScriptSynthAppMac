#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"

#include "ofxMaxim.h"

class ofApp : public ofxiOSApp{
	
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
    
    void audioRequested(float * output, int Buffersize, int nChannels);
    
    ofxMaxiOsc tone1, tone2;
    
    float touchMovY;
    
    float parameter1, parameter2, parameter3, parameter4, parameter5;
    float secondParameter1, secondParameter2, secondParameter3, secondParameter4, secondParameter5;
    
    int spectrogramWidth, spectrogramWidth2;

	ofMutex soundMutex;
    vector<float> drawBuffer, middleBuffer, audioBuffer;
    vector<float> drawBins, middleBins, audioBins;

    vector<float> drawBuffer2, middleBuffer2, audioBuffer2;
    vector<float> drawBins2, middleBins2, audioBins2;

	int plotHeight, bufferSize;

    void plot(vector<float>& buffer, float scale, float offset);

    int spectrogramOffset;
	ofImage spectrogram;

    int spectrogramOffset2;
	ofImage spectrogram2;

    
    ofxMaxiMix mix;
    
    vector<int> spectrum1PosX, spectrum2PosX;
    
};



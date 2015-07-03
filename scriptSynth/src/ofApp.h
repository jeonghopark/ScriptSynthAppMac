#pragma once

#include "ofMain.h"
#include "ofxMaxim.h"

class ofApp : public ofBaseApp{
	
public:
    void setup();
    void update();
    void draw();
    void exit();

    void keyPressed(int key);
    void keyReleased(int key);
    void mouseMoved(int x, int y);
    void mouseDragged(int x, int y, int button);
    void mousePressed(int x, int y, int button);
    void mouseReleased(int x, int y, int button);
    void windowResized(int w, int h);
    void dragEvent(ofDragInfo dragInfo);
    void gotMessage(ofMessage msg);
    
    void audioRequested(float * output, int Buffersize, int nChannels);
    
    ofxMaxiOsc tone0, tone1, tone2;
    
    float touchMovY;
    
    float parameter1, parameter2, parameter3, parameter4, parameter5;
    float secondParameter1, secondParameter2, secondParameter3, secondParameter4, secondParameter5;
    
    int spectrogramWidth, spectrogramWidth2;

    ofMutex soundMutex;
    
    vector<float> drawBuffer_0, middleBuffer_0, audioBuffer_0;
    vector<float> drawBins_0, middleBins_0, audioBins_0;

    vector<float> drawBuffer_1, middleBuffer_1, audioBuffer_1;
    vector<float> drawBins_1, middleBins_1, audioBins_1;

    vector<float> drawBuffer_2, middleBuffer_2, audioBuffer_2;
    vector<float> drawBins_2, middleBins_2, audioBins_2;

	int plotHeight, bufferSize;

    void plot(vector<float>& buffer, float scale, float offset);

    int spectrogramOffset;
	ofImage spectrogramUP;

    int spectrogramOffset2;
	ofImage spectrogramDN;

    
    ofxMaxiMix mix;
    
    vector<int> spectrum1PosX, spectrum2PosX;
    
    float scale[27] = {
        16.35,
        32.70, 49.00,
        65.41, 82.41, 98.00, 116.54,
        130.81, 146.83, 164.81, 185.00, 207.65, 233.08, 246.94,
        261.63, 277.18, 293.66, 311.13, 329.63, 349.23, 369.99, 392.00, 415.30, 440.00, 466.16, 493.88, 523.25
    };
    
    float scale1, scale2;
    bool fullscreen;
    
    
};



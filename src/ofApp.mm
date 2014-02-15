// http://entropedia.co.uk/generative_music/#b64K9EqAQA%3D

#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){	

    
    ofSetOrientation(OF_ORIENTATION_90_RIGHT);
    ofSetFrameRate(60);
    
	plotHeight = 128;
    bufferSize = 1024;

 	ofSoundStreamSetup(2,0,this, 44100, bufferSize, 4);
   
    drawBuffer.resize(bufferSize);
	middleBuffer.resize(bufferSize);
	audioBuffer.resize(bufferSize);

    spectrogram.allocate(bufferSize, 256, OF_IMAGE_GRAYSCALE);
	memset(spectrogram.getPixels(), 0, (int) (spectrogram.getWidth() * spectrogram.getHeight()) );
	spectrogramOffset = 0;

    ofBackground(10, 255);
    
}

//--------------------------------------------------------------
void ofApp::update(){
    
    parameter1 = parameter1 + 2;

    if (parameter1>40) {
        parameter1 = 0;
        parameter2 = ofRandom(400);
        parameter3 = ofRandom(5);
        parameter4 = ofRandom(parameter2*2);
    }
    
}

void ofApp::draw() {
	ofSetColor(255);
	ofPushMatrix();
	ofTranslate(0, 0);
	ofDrawBitmapString("Time Domain", 0, 0);
	
	soundMutex.lock();
	drawBuffer = middleBuffer;
	drawBins = middleBins;
	soundMutex.unlock();
	
//	plot(drawBuffer, plotHeight / 2, 0);
//	ofTranslate(0, plotHeight + 16);
//	ofDrawBitmapString("Frequency Domain", 0, 0);
//	plot(drawBins, -plotHeight, plotHeight / 2);
	ofNoFill();
	ofTranslate(0, plotHeight);
	spectrogram.update();
	spectrogram.draw(0, 0);
	ofRect(0, 0, bufferSize, bufferSize / 4);
//	ofDrawBitmapString("Spectrogram", 0, 0);
	ofPopMatrix();
	string msg = ofToString((int) ofGetFrameRate()) + " fps";
//	ofDrawBitmapString(msg, appWidth - 80, appHeight - 20);
}

float powFreq(float i) {
	return powf(i, 3);
}

void ofApp::plot(vector<float>& buffer, float scale, float offset) {
	ofNoFill();
	int n = buffer.size();
	ofRect(0, 0, n, plotHeight);
	glPushMatrix();
	glTranslatef(0, plotHeight / 2 + offset, 0);
	ofBeginShape();
	for (int i = 0; i < n; i++) {
		ofVertex(i, buffer[i] * scale);
	}
	ofEndShape();
	glPopMatrix();
}
//--------------------------------------------------------------
void ofApp::exit(){

}

void ofApp::audioRequested(float *output, int Buffersize, int nChannels){
    
    
    float _fq = 55;
    float _volume = 0.1;
    double _t1;
    
    
    for (int i=0; i<Buffersize; i++) {
        
        
        float _changeAble = ofMap( touchMovY, 0, ofGetHeight(), 0, 500 ) * parameter3;
        
//        if ((i*nChannels<_changeAble)&&(i*nChannels+1<_changeAble)) {
//            _t1 = 0;
//        } else {
//            float _randomFQ = 440 + parameter2;
//            _t1 = tone1.sinewave( _randomFQ*parameter1/10 ) * _volume + tone1.saw( parameter4 ) * _volume / 2;
//        }
        
        
        _t1 = tone1.saw(_fq*_changeAble) * _volume;

        testFQdraw = &_t1;
        
//        memcpy(&audioBuffer[0], _t1, sizeof(float) * bufferSize);
        audioBuffer[i] = _t1;
        
        output[i*nChannels] = _t1;
        output[i*nChannels+1] = _t1;
        
    }
    
    
    float maxValue = 0.0;
    for(int i = 0; i < Buffersize; i++) {
		if(abs(audioBuffer[i]) > maxValue) {
			maxValue = abs(audioBuffer[i]);
		}
	}
	for(int i = 0; i < Buffersize; i++) {
		audioBuffer[i] /= maxValue;
	}


    int spectrogramWidth = (int) spectrogram.getWidth();
	int n = (int) spectrogram.getHeight();
	unsigned char* pixels = spectrogram.getPixels();
	for(int i = 0; i < n; i++) {
		int j = (n - i - 1) * spectrogramWidth + spectrogramOffset;
		int logi = ofMap(powFreq(i), powFreq(0), powFreq(n), 0, n);
		pixels[j] = (unsigned char) (255. * audioBuffer[logi]);
	}
	spectrogramOffset = (spectrogramOffset + 1) % spectrogramWidth;
    
    soundMutex.lock();
	middleBuffer = audioBuffer;
	middleBins = audioBins;
	soundMutex.unlock();
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    if (touch.id==0) {
        touchMovY = touch.y;
    }
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){

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


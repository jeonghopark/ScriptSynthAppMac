// http://entropedia.co.uk/generative_music/#b64K9EqAQA%3D

#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){	

    
    ofSetOrientation(OF_ORIENTATION_90_RIGHT);
    ofSetFrameRate(60);
    
    ofxAccelerometer.setup();               //accesses accelerometer data
    ofxiPhoneAlerts.addListener(this);      //allows elerts to appear while app is running
	ofRegisterTouchEvents(this);            //method that passes touch events

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    
	plotHeight = 128;
    bufferSize = 512;

 	ofSoundStreamSetup(2,0,this, 44100, bufferSize, 4);
   
    drawBuffer.resize(bufferSize);
	middleBuffer.resize(bufferSize);
	audioBuffer.resize(bufferSize);

    drawBuffer2.resize(bufferSize);
	middleBuffer2.resize(bufferSize);
	audioBuffer2.resize(bufferSize);

    spectrogram.allocate(bufferSize*2, plotHeight, OF_IMAGE_GRAYSCALE);
	memset(spectrogram.getPixels(), 0, (int) (spectrogram.getWidth() * spectrogram.getHeight()) );
	spectrogramOffset = 0;

    spectrogram2.allocate(bufferSize*2, plotHeight, OF_IMAGE_GRAYSCALE);
	memset(spectrogram2.getPixels(), 0, (int) (spectrogram2.getWidth() * spectrogram2.getHeight()) );
	spectrogramOffset2 = 0;

    ofBackground(10, 255);
    
}

//--------------------------------------------------------------
void ofApp::update(){
    
    parameter1 = parameter1 + 2;

    if (parameter1>parameter2) {
        parameter1 = 0;
        parameter2 = (int)ofRandom(10,20);
        parameter3 = ofRandom(0.5);
        parameter4 = ofRandom(parameter2*2);
        parameter5 = ofRandom(0.2);
    }

    secondParameter1 = secondParameter1 + 2;
    
    if (secondParameter1>secondParameter2) {
        secondParameter1 = 0;
        secondParameter2 = (int)ofRandom(10,60);
        secondParameter3 = ofRandom(0.5);
        secondParameter4 = ofRandom(secondParameter2*2);
        secondParameter5 = ofRandom(0.2);
    }

	soundMutex.lock();
	drawBuffer = middleBuffer;
	drawBins = middleBins;
	drawBuffer2 = middleBuffer2;
	drawBins2 = middleBins2;
	soundMutex.unlock();

}

void ofApp::draw() {
	
    ofSetColor(255, 255);
	ofPushMatrix();
	ofTranslate(0, ofGetHeight()/2-plotHeight - 5);
	spectrogram.update();
	spectrogram.draw(0, 0);
	ofPopMatrix();

	ofPushMatrix();
	ofTranslate(0, ofGetHeight()/2 + 5);
	spectrogram2.update();
	spectrogram2.draw(0, 0);
	ofPopMatrix();
    
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
    
    float _fq = 22.5;
    float _volume = 0.5;
    double _t1;

    float _fq2 = _fq*1.5;
    float _volume2 = 0.5;
    double _t2;

    for (int i=0; i<Buffersize; i++) {
        
        float _changeAble = ofMap( touchMovY, 0, ofGetHeight(), 0, _fq*30 ) * parameter3;
        float _changeAble2 = ofMap( touchMovY, 0, ofGetHeight(), 0, _fq2*30 ) * secondParameter3;
        
        audioBuffer[i] = _t1;
        _t1 = tone1.sinewave(_fq*_changeAble * 0.1) * tone1.sinewave(_fq*_changeAble * 0.07) * tone1.phasor(_fq*_changeAble * 0.07) * _volume;

        audioBuffer2[i] = _t2;
        _t2 = tone2.saw(_fq2*_changeAble2 * 0.1) * tone2.sinewave(_fq2*_changeAble2 * 0.05) * _volume2;

        double _output = ( _t1 + _t2 ) * 0.5;
        
        output[i*nChannels] = _output;
        output[i*nChannels+1] = _output;
        
    }
    
    float maxValue = 0.0;
    float maxValue2 = 0.0;
    for(int i = 0; i < Buffersize; i++) {
		if(abs(audioBuffer[i]) > maxValue) {
			maxValue = abs(audioBuffer[i]);
		}
		if(abs(audioBuffer2[i]) > maxValue2) {
			maxValue2 = abs(audioBuffer2[i]);
		}
	}
	for(int i = 0; i < Buffersize; i++) {
		audioBuffer[i] /= maxValue;
	}
	for(int i = 0; i < Buffersize; i++) {
		audioBuffer2[i] /= maxValue2;
	}


    spectrogramWidth = (int) spectrogram.getWidth();
	int n = (int) spectrogram.getHeight();
	unsigned char* pixels = spectrogram.getPixels();
	for(int i = 0; i < n; i++) {
		int j = (n - i - 1) * spectrogramWidth + spectrogramOffset;
		int logi = ofMap(powFreq(i), powFreq(0), powFreq(n), 0, n);
		pixels[j] = (unsigned char) (255. * audioBuffer[logi]);
	}
	spectrogramOffset = (spectrogramOffset + 1) % spectrogramWidth;

    spectrogramWidth2 = (int) spectrogram2.getWidth();
	int n2 = (int) spectrogram2.getHeight();
	unsigned char* pixels2 = spectrogram2.getPixels();
	for(int i = 0; i < n2; i++) {
		int j = (n2 - i - 1) * spectrogramWidth2 + spectrogramOffset2;
		int logi = ofMap(powFreq(i), powFreq(0), powFreq(n2), 0, n2);
		pixels2[j] = (unsigned char) (255. * audioBuffer2[logi]);
	}
	spectrogramOffset2 = (spectrogramOffset2 + 1) % spectrogramWidth2;
    
    soundMutex.lock();
	middleBuffer = audioBuffer;
	middleBins = audioBins;
	middleBuffer2 = audioBuffer2;
	middleBins2 = audioBins2;
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


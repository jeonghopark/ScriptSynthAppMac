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

    ofBackground(10, 255);
    
	plotHeight = 128*2;
    bufferSize = 512;

 	ofSoundStreamSetup(2,0,this, 44100, bufferSize, 4);
   
    drawBuffer_0.resize(bufferSize);
	middleBuffer_0.resize(bufferSize);
	audioBuffer_0.resize(bufferSize);
    
    drawBuffer_1.resize(bufferSize);
	middleBuffer_1.resize(bufferSize);
	audioBuffer_1.resize(bufferSize);

    drawBuffer_2.resize(bufferSize);
    middleBuffer_2.resize(bufferSize);
	audioBuffer_2.resize(bufferSize);

    spectrogram.allocate(bufferSize*2, plotHeight, OF_IMAGE_GRAYSCALE);
	memset(spectrogram.getPixels(), 0, (int) (spectrogram.getWidth() * spectrogram.getHeight()) );
	spectrogramOffset = 0;

    spectrogram2.allocate(bufferSize*2, plotHeight, OF_IMAGE_GRAYSCALE);
	memset(spectrogram2.getPixels(), 0, (int) (spectrogram2.getWidth() * spectrogram2.getHeight()) );
	spectrogramOffset2 = 0;

    touchMovY = ofGetHeight()/2;
    
}

//--------------------------------------------------------------
void ofApp::update(){
    
    parameter1 = parameter1 + 2;

    float scaleFactor = 1.5;
    
    if (parameter1>4) {
        parameter1 = 0;
//        parameter2 = (int)ofRandom(10,20);
        parameter2 = 60;
        parameter3 = ofRandom(0.5);
        parameter4 = ofRandom(parameter2*2);
        parameter5 = ofRandom(0.2);
        
        scale1 = scale [(int)round(ofRandom( 27 ))] * scaleFactor;

    }

    secondParameter1 = secondParameter1 + 2;
    
    if (secondParameter1>8) {
        secondParameter1 = 0;
        //        secondParameter2 = (int)ofRandom(10,60);
        secondParameter2 = 60;
        secondParameter3 = ofRandom(0.5);
        secondParameter4 = ofRandom(secondParameter2*2);
        secondParameter5++;
        
        if ( (int)secondParameter5%8==0 ) {
            scale2 = scale [(int)round(ofRandom( 27 ))] * scaleFactor;
            secondParameter5 = 0;
        }

    }

	soundMutex.lock();
	drawBuffer_0 = middleBuffer_0;
	drawBins_0 = middleBins_0;
	drawBuffer_1 = middleBuffer_1;
	drawBins_1 = middleBins_1;
	drawBuffer_2 = middleBuffer_2;
	drawBins_2 = middleBins_2;
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
    
    float _fq0 = 22.5;
    float _volume0 = 0.5;
    double _t0;

    float _fq = 22.5;
    float _volume = 0.5;
    double _t1;

    float _fq2 = _fq*1.5;
    float _volume2 = 0.5;
    double _t2;

    for (int i=0; i<Buffersize; i++) {
        
        float _changeAble = ofMap( touchMovY, 0, ofGetHeight(), 0, _fq*30 ) * parameter3;
        float _changeAble2 = ofMap( touchMovY, 0, ofGetHeight(), 0, _fq2*30 ) * secondParameter3;
        
//        _t1 = tone1.sinewave( tone0.sinewave(_fq0*_changeAble * 0.1) ) * tone1.sinewave(_fq*_changeAble * 0.07) + tone1.phasor(_fq*_changeAble * 0.07) * _volume;
//
//        _t2 = tone2.sinewave(_fq2*_changeAble2 * 0.1) * tone2.sinewave(_fq2*_changeAble2 * 0.05) * _volume2;
        

        _t1 = tone0.saw( scale1 ) + tone2.sinewave( scale1 );
        audioBuffer_1[i] = _t1;

//        _t2 = tone2.sinewave( scale2 );
//        audioBuffer_2[i] = _t2;
        
        double _output = ( _t1 ) * 0.5;
        
        output[i*nChannels] = _output;
        output[i*nChannels+1] = _output;
        
    }
    
    float maxValue = 0.0;
    float maxValue2 = 0.0;
    for(int i = 0; i < Buffersize; i++) {
		if(abs(audioBuffer_1[i]) > maxValue) {
			maxValue = abs(audioBuffer_1[i]);
		}
		if(abs(audioBuffer_2[i]) > maxValue2) {
			maxValue2 = abs(audioBuffer_2[i]);
		}
	}
	for(int i = 0; i < Buffersize; i++) {
		audioBuffer_1[i] /= maxValue;
	}
	for(int i = 0; i < Buffersize; i++) {
		audioBuffer_2[i] /= maxValue2;
	}


    spectrogramWidth = (int) spectrogram.getWidth();
	int n = (int) spectrogram.getHeight();
	unsigned char* pixels = spectrogram.getPixels();
	for(int i = 0; i < n; i++) {
		int j = (n - i - 1) * spectrogramWidth + spectrogramOffset;
		int logi = ofMap(powFreq(i), powFreq(0), powFreq(n), 0, n);
		pixels[j] = (unsigned char) (255. * audioBuffer_1[logi]) * 3;
	}
	spectrogramOffset = (spectrogramOffset + 1) % spectrogramWidth;

    spectrogramWidth2 = (int) spectrogram2.getWidth();
	int n2 = (int) spectrogram2.getHeight();
	unsigned char* pixels2 = spectrogram2.getPixels();
	for(int i = 0; i < n2; i++) {
		int j = (n2 - i - 1) * spectrogramWidth2 + spectrogramOffset2;
		int logi = ofMap(powFreq(i), powFreq(0), powFreq(n2), 0, n2);
		pixels2[j] = (unsigned char) (255. * audioBuffer_2[logi]);
	}
	spectrogramOffset2 = (spectrogramOffset2 + 1) % spectrogramWidth2;
    
    soundMutex.lock();

	middleBuffer_1 = audioBuffer_1;
	middleBins_1 = audioBins_1;

	middleBuffer_2 = audioBuffer_2;
	middleBins_2 = audioBins_2;

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


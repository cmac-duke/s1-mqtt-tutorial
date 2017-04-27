import processing.io.*;
import beads.*;
import java.util.Arrays; 

AudioContext ac;
Glide carrierFreq, modFreqRatio;


import mqtt.*;

MQTTClient client;


int max = 0;
int min = 9999;

void setup(){
  size(600, 600);
  background(0);
  client = new MQTTClient(this); 
  client.connect("http://104.131.167.212", "1883");
  client.subscribe("testTopic"); 
  
  
  ac = new AudioContext();
  carrierFreq = new Glide(ac, 500);
  modFreqRatio = new Glide(ac, 1);
  Function modFreq = new Function(carrierFreq, modFreqRatio) {
    public float calculate() {
      return x[0] * x[1];
    }
  };
  WavePlayer freqModulator = new WavePlayer(ac, modFreq, Buffer.SINE);
  Function carrierMod = new Function(freqModulator, carrierFreq) {
    public float calculate() {
      return x[0] * 400.0 + x[1];    
    }
  };
  WavePlayer wp = new WavePlayer(ac, carrierMod, Buffer.SINE);
  Gain g = new Gain(ac, 1, 0.1);
  g.addInput(wp);
  ac.out.addInput(g);
  ac.start();
 
}
void draw(){
   int val = sensorRead(4);
  println(val);
  client.publish("testTopic", str(val));
}

int sensorRead(int pin){
  GPIO.pinMode(pin, GPIO.OUTPUT); 
  GPIO.digitalWrite(pin, GPIO.LOW);
  delay(1); 
  
  GPIO.pinMode(pin, GPIO.INPUT); 
  int start = millis(); 
  
  while (GPIO.digitalRead(pin) == GPIO.LOW){
    //wait
  }
  
  return millis() - start; 
}

void messageReceived(String topic, byte[] payload){
  println("new message: " + topic + " - " + new String(payload));
  text(new String(payload), random(0, width), random(0, height)); 
  

  carrierFreq.setValue(100*float(new String(payload)));
  modFreqRatio.setValue(float(new String(payload)));
}
import processing.io.*;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import mqtt.*;

MQTTClient client;

Minim minim;
AudioOutput out;

int max = 0;
int min = 9999;

void setup(){
  size(600, 600);
  background(0);
  client = new MQTTClient(this); 
  client.connect("http://104.131.167.212", "1883");
  client.subscribe("testTopic"); 
  
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 2048 );
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
  ToneInstrument myNote = new ToneInstrument( 587.3f, 0.9, out );
  // play a note with the myNote object
  out.playNote( 0.5, 2.6, myNote );
}




class ToneInstrument implements Instrument
{
  Oscil sineOsc;
  AudioOutput out;
  ToneInstrument( float frequency, float amplitude, AudioOutput output )
  {
    out = output;
    sineOsc = new Oscil( frequency, amplitude, Waves.SINE );
  }
  
  void noteOn( float dur )
  {
    sineOsc.patch( out );
  }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    sineOsc.unpatch( out );
  }
}
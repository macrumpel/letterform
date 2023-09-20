import processing.serial.*;
import controlP5.*;

Serial myPort;    // Create object from Serial class
Plotter plotter;  // Create a plotter object
int serialPort=2; // select the port
int val;          // Data received from the serial port
int lf = 10;      // ASCII linefeed


// controlp5
ControlP5 controlP5;
boolean toggleAmp = true;
boolean toggleFreq = true;
boolean togglePlotter = true;
boolean toggleSpeed = false;
boolean toggleAuto = false;
int controlDelay = 100;

//Enable plotting?
final boolean PLOTTING_ENABLED = true;

//Label
String label = "SYMB";

//Plotter dimensions
int xMin = 170;
int yMin = 602;
int xMax = 10800;
int yMax = 7500;

//Plotter speed
int pSpeed = 5;
int vsOld; // last speed

//Current rows and cols
int row = 0;
int col = 0;


//Let's set this up
void setup(){
  fullScreen(); // to use the whole screen, projector etc
  background(233, 233, 220);
  //size(1080, 750);
  smooth();
  
  
  // interface 
  
  controlP5 = new ControlP5(this);
  controlP5.addToggle("toggleAmp").setPosition(20,20).setSize(20,20)
    .setCaptionLabel("Amplitude")
    .setColorCaptionLabel(0);
  controlP5.addToggle("toggleFreq").setPosition(70,20).setSize(20,20)
    .setCaptionLabel("Frequency")
    .setColorCaptionLabel(0);
  controlP5.addToggle("toggleAuto").setPosition(120,20).setSize(20,20)
    .setCaptionLabel("Auto")
    .setColorCaptionLabel(0);
  controlP5.addSlider("controlDelay").setPosition(170,20).setSize(80,20)
    .setRange(50,300)
    .setCaptionLabel("delay")
    .setColorCaptionLabel(0);
  controlP5.addSlider("pSpeed").setPosition(300,20).setSize(80,20)
    .setColorCaptionLabel(0)
    .setRange(1,38)
    .setCaptionLabel("Plot speed");

  //Select a serial port
  println(Serial.list()); //Print all serial ports to the console
  int portNumber = Serial.list().length;
  println("Number of ports: " + portNumber + ", port selected: " + serialPort);
  if (serialPort>=portNumber){
    serialPort = portNumber-1;
    println("Selected port not available, changing to last port...");
  }
  String portName = Serial.list()[serialPort]; //make sure you pick the right one
  println("Plotting to port: " + portName);
  
  //Open the port
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil(lf);
  
  //Associate with a plotter object
  plotter = new Plotter(myPort);
  
  //Initialize plotter
  plotter.write("IN;SP1;");
  
//Wait 0.5 second per character while printing label
/*  if (PLOTTING_ENABLED) {
    delay(label.length() * 500);
  }
*/    
}

void draw(){
 plotLabel();
}



void plotLabel(){
  //Draw a label at the end
  //label = "XY // ";
  float ty = map(80, 0, height, yMin, yMax);
  println(label);
  plotter.write("PU"+10800+","+ty+";"); //Position pen
  plotter.write("SI0.14,0.14;DI0,1;LB" + label + char(3)); //Draw label
}

void keyReleased() {
 if (key == 'E' || key == 'e') {
      plotLabel();
      delay(5000);
      exit();
    } else if (key == 'A' || key == 'a') {
      toggleAmp = !toggleAmp;
      controlP5.getController("toggleAmp").setValue(int(toggleAmp)); 
    } else if (key == 'F' || key == 'f') {
      toggleFreq = !toggleFreq;
      controlP5.getController("toggleFreq").setValue(int(toggleFreq)); 
    } else if (key == 'M' || key == 'm') {
      toggleAuto = !toggleAuto;
      controlP5.getController("toggleAuto").setValue(int(toggleAuto)); 
    } 

 }
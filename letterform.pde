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
float controlSize = 1.5;

//Enable plotting?
final boolean PLOTTING_ENABLED = true;

//Label
String label = "RIEN\r\nNOW";
String label2= "   DE";
String label3= "abcdefghijklm";
String label4= "nopqrstuvwxyz";
boolean ambigFlag = false;

//Plotter dimensions
int xMin = 170;
int yMin = 602;
int xMax = 10800;
int yMax = 7500;

//Plotter initial pen number
int penNumber = 4;

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
  controlP5.addSlider("controlSize").setPosition(170,20).setSize(80,20)
    .setRange(0.1,5)
    .setCaptionLabel("text size")
    .setColorCaptionLabel(0);
  controlP5.addSlider("pSpeed").setPosition(300,20).setSize(80,20)
    .setColorCaptionLabel(0)
    .setRange(1,38)
    .setCaptionLabel("Plot speed");

  //Select a serial port
  println(Serial.list()); //Print all serial ports to the console
  int portNumber = Serial.list().length;
  println("Number of ports: " + portNumber + ", port selected: " + serialPort);
  /*if (serialPort>=portNumber){
    serialPort = portNumber-1;
    println("Selected port not available, changing to last port...");
  }
  String portName = Serial.list()[serialPort]; //make sure you pick the right one
  println("Plotting to port: " + portName);
  */
  String portName = "/dev/ttys002"; // for Moxa Device
  //Open the port
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil(lf);
  
  //Associate with a plotter object
  plotter = new Plotter(myPort);
  delay(5000);
  //Initialize plotter
  plotter.write("IN;");
  plotPosition(4000,100);
  plotTextSize(controlSize,controlSize*2);
  plotDirection(0,1);
  plotSpeed(pSpeed);
  plotPenselect(4);
  
//Wait 0.5 second per character while printing label
/*  if (PLOTTING_ENABLED) {
    delay(label.length() * 500);
  }
*/    
}

void draw(){
  println(); // take the label and individually sent the letters to the plotter
  for (int i=0; i < label.length(); i = i+1){
    char c = label.charAt(i);
    char cnew = evaluateLetter(c); // send to evaluation
    println("Now plotting: " + cnew);
    plotLabel(str(cnew));
  }
  plotPosition(0,0); // show the paper
  delay(1000);
  if (ambigFlag = true) { // if there was an abigous letter then...
    plotPenselect(3); // draw now in red
    plotPosition(4000,100); // go to initial position (multiline)
    //plotLetterPosition(-label.length(), 0); // go back to the latest place
    for (int i=0; i < label.length(); i = i+1){
      char c = label.charAt(i);
      char cnew = evaluateAmbigLetter(c); // send to evaluation
      println("Now plotting: " + cnew);
     }
  }
  plotPenselect(0);
  exit();
}



void plotLabel(String text){
  //Draw a label at the end
  //println(text);
  plotter.write("LB" + text + char(3)); //Draw label taille 1cm, direction 0, char(3)= terminateur
}
void plotPenselect(int penNumber){
  //Send pen selection to plotter
  println("Pen slection: " + penNumber);
  plotter.write("SP" + penNumber + ";");
}

void plotLetterPosition(int letterposX, int letterposY){
  // move cursor to x and y places of letters
  println("Move by " + letterposX + " places horizontally, " + letterposY + " vertically");
  plotter.write("CP" + letterposX + "," + letterposY + ";");
}

void plotPosition(float xPos, float yPos){
  float ty = map(yPos, 0, height, yMin, yMax); // map coordinate Y
  println(ty);
  println(height);
  plotter.write("PU"+xPos+","+ty+";"); // position pen
}

void plotSpeed(int speed){
  println("Plotter speed: " + speed + " cm/s");
  plotter.write("VS" + speed + ";");
}

void plotTextSize(float sizeL, float sizeH){
 plotter.write("SI" + sizeL + "," + sizeH + ";");
}

void plotDirection(int directCourse, int directElevation){
  plotter.write("DI" + directCourse + "," + directElevation + ";");
}

void keyReleased() {
 if (key == 'P' || key == 'p') {
      plotTextSize(controlSize,controlSize*2);
      plotDirection(1,0);
      plotPosition(500,400);
      plotSpeed(pSpeed);
      plotPenselect(4);
      plotLabel(label);
      plotLetterPosition(-label.length(), 0);
      //plotPosition(500,600);
      plotLabel(label2);
      /*plotPosition(500,400);
      plotLabel(label3);
      plotPosition(500,200);
      plotLabel(label4); */
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
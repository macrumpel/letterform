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
float controlSize = 1.0; // text size in cm

//Enable plotting?
final boolean PLOTTING_ENABLED = true;

//Label
String label1= "BYE BYE\r\nWHAT IS?";
String label5 = "IL Y A\r\nUNE ERREUR\r\nDANS\r\nLE SYSTEM?";
String label2= "IL FAUT\r\nDETRUIRE\r\nLA SYNTAXE";
String label6= "JE\r\nM'EXCUSE\r\nPOUR\r\nL'ERREUR\r\nPRECEDENTE";
String label4= "DIFFERENT PREDATORS. DIFFERENT WORDS AND WHEELS. BUT THE SAME SKY. THAT'S THE DARK AGE WE STILL LIVE IN TODAY.";
String label7= "YOU CAN\r\nDESCRIBE YOUR\r\nOWN LANGUAGE IN\r\nYOUR OWN\r\nLANGUAGE:\r\nBUT NOT QUITE.\r\nYOU CAN\r\nINVESTIGAE YOUR\r\nOWN BRAIN BY\r\nMEANS OF YOUR\r\nOWN BRAIN:\r\nBUT NOT QUITE.";
String label= ""; 
boolean ambigFlag = false;
String ambigousLetters = "EORB?T";
String SpecialCharacter = "";
JSONArray poesieJSON;
int poesieNumber = 1;


//Plotter dimensions
int xMin = 170;
int yMin = 602;
int xMax = 10800;
int yMax = 7500;

//Plotter initial pen number
int penNumber = 4;

//Plotter speed
int pSpeed = 10;
int vsOld; // last speed



//Let's set this up
void setup(){
  fullScreen(); // to use the whole screen, projector etc
  background(233, 233, 220);
  //size(1080, 750);
  smooth();
  

  // JSON import
  poesieJSON = loadJSONArray("poesie.json");
  println("Number of poesie found: " + poesieJSON.size());
  JSONObject poesieObject = poesieJSON.getJSONObject(poesieNumber);
  println("Plotting poesie: " + poesieObject);
  String poesieName = poesieObject.getString("name");
  println ("Poesie selected: " + poesieName);
  ambigousLetters = poesieObject.getString("ambigous");
  println ("Ambigous letters used: " + ambigousLetters);
  controlSize = poesieObject.getFloat("font size");
  println ("This is for font size of " + controlSize + "cm.");
  int poesieLines = poesieObject.getJSONArray("text lines").size();
  println(poesieLines + " line(s) in this poesie.");
  println ("[JSON] Poesie loaded.");
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
  delay(2000);
  //Initialize plotter
  plotter.write("IN;");
  plotPosition(1000,10);
  plotTextSize(controlSize,controlSize*2);
  plotDirection(0,1);
  plotSpeed(pSpeed);
  plotPenselect(4);
  // plotSpacing(0,-0.5); not supported
  
//Wait 0.5 second per character while printing label
/*  if (PLOTTING_ENABLED) {
    delay(label.length() * 500);
  }
*/    
}

void draw(){
  // plotSpacing(0,-1); not supported
  println("*** now starting to plot ***"); // take the label and individually sent the letters to the plotter
  println("Plotting text: " + label);
  println("Number of characters :" + label.length());
  for (int i=0; i < label.length(); i = i+1){
    char c = label.charAt(i);
    char cnew = evaluateLetter(c); // send to evaluation
    if (cnew == '\n'){
      println("Now making a linefeed");
      plotLetterPosition(0,0.2); // reduce linefeed distance
      plotLabel(str(cnew));
    } else if (cnew == '\r') {
      println("Now making a carriage return");
      plotLabel(str(cnew));
    }  
      else if (cnew == '\t') {
      println("Now plotting a special character");
      plotter.write(SpecialCharacter);
    } else {
      println("Now plotting: " + cnew);
      plotLabel(str(cnew));
    }
  }
  plotPosition(0,0); // show the paper
  delay(label.length() * 500);
  if (ambigFlag = true) { // if there was an abigous letter then...
    println("Overwriting ambigous letters now...");
    plotPenselect(3); // draw now in red
    plotPosition(1000,10); // go to initial position (multiline)
    //plotLetterPosition(-label.length(), 0); // go back to the latest place
    for (int i=0; i < label.length(); i = i+1){
      char c = label.charAt(i);
      char cnew = evaluateAmbigLetter(c); // send to evaluation
      println("Now plotting: " + cnew);
     }
  }
  plotPosition(0,0);
  plotPenselect(0);
  exit();
}

// functions :

void plotLabel(String text){
  //Draw a label at the end
  //println(text);
  plotter.write("LB" + text + char(3)); //Draw label, char(3)= terminator
  delay(500);
}

void plotPenselect(int penNumber){
  //Send pen selection to plotter
  println("Pen slection: " + penNumber);
  plotter.write("SP" + penNumber + ";");
}

/* void plotSpacing(float spacing, float lining){
  //Send spacing and linefeed to plotter
  println("Spacing / Linefeed: " + spacing + "/ " + lining);
  plotter.write("ES" + spacing + "," + lining + ";");
} */ // not supported in HPGL-1

void plotLetterPosition(float letterposX, float letterposY){
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
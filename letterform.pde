import processing.serial.*;

Serial myPort;    // Create object from Serial class
Plotter plotter;  // Create a plotter object
int serialPort=2; // select the port
int val;          // Data received from the serial port
int lf = 10;      // ASCII linefeed
PFont font;

//Enable plotting?
final boolean PLOTTING_ENABLED = false;

//Label
String label1= "BYE BYE\nWHAT IS?";
String label5 = "IL Y A\nUNE ERREUR\nDANS\nLE SYSTEM?";
String label2= "IL FAUT\nDETRUIRE\nLA SYNTAXE";
String label6= "JE\nM'EXCUSE\nPOUR\nL'ERREUR\nPRECEDENTE";
String label4= "DIFFERENT PREDATORS. DIFFERENT WORDS AND WHEELS. BUT THE SAME SKY. THAT'S THE DARK AGE WE STILL LIVE IN TODAY.";
String label7= "YOU CAN\nDESCRIBE YOUR\nOWN LANGUAGE IN\nYOUR OWN\nLANGUAGE:\nBUT NOT QUITE.\nYOU CAN\nINVESTIGAE YOUR\nOWN BRAIN BY\nMEANS OF YOUR\nOWN BRAIN:\nBUT NOT QUITE.";
String label= ""; 
boolean ambigFlag = false;
boolean poesieLoaded = false;
boolean directionChange = false;
String ambigousLetters = "EORB?T";
String SpecialCharacter = "";
JSONArray poesieJSON;
JSONArray poesieTextJSON;
JSONObject poesieObject;
JSONObject textLine;
String ambigousLabel = "";
int poesieNumber = 9; // select inital poesie in json file
int poesieLines = 1;
int ambigousPen = 3;
float ambigousSpeed = 9;
float fontSize = 1; // text size in cm
float plotSize = 0;
float writeSpeed = 9;
float paperHeight = 402; // in milimeters A3 -> for A4 change to
float paperWidth = 275; // in milimeters A3 -> for A4 change to


//Plotter starting
int xPos_mm = 25;
int yPos_mm = 1;
int horizontalDirection = 0;
int verticalDirection = 1;


//Plotter initial pen number
int penNumber = 2;

//Plotter speed
float pSpeed = writeSpeed;
int vsOld; // last speed



//Let's set this up
void setup(){
  fullScreen(); // to use the whole screen, projector etc
  //size(1080, 750);
  background(200);
  //smooth();
  //textSize(26);
  font = loadFont("HelveticaNeue-Light-48.vlw");
  fill(0);
  textFont(font,36);
  

  // JSON import
  poesieJSON = loadJSONArray("poesie.json");
  loadPoesie(0); // not actually, to allow application to start without plotting
  poesieLoaded = false;

  //Select a serial port
  println(Serial.list()); //Print all serial ports to the console
  int portNumber = Serial.list().length;
  println("Number of ports: " + portNumber + ", port selected: " + serialPort);
  if (serialPort>=portNumber){
    serialPort = portNumber-1;
    println("Selected port not available, changing to last port...");
  }
  //String portName = Serial.list()[serialPort]; //make sure you pick the right one
  String portName = "/dev/ttys007"; // for Moxa Device
  println("Plotting to port: " + portName);
  //Open the port
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil(lf);
  
  //Associate with a plotter object
  plotter = new Plotter(myPort);

  //Initialize plotter
  plotter.write("IN;");
 //this was calculated 
  plotTextSize(fontSize,fontSize*2);
  plotDirection(horizontalDirection, verticalDirection);
  plotSpeed(pSpeed);
  delay(4000);
  // plotSpacing(0,-0.5); not supported
  
//Wait 0.5 second per character while printing label
/*  if (PLOTTING_ENABLED) {
    delay(label.length() * 500);
  }
*/    
}

void draw(){
  if (poesieLoaded) { // this gets loaded after number key pressed, see dowmwards
    for (int l=0; l<poesieLines; l=l+1){ // getting the text lines from JSON poesie
      textLine = poesieTextJSON.getJSONObject(l);
      penNumber = textLine.getInt("pen_number");
      writeSpeed = textLine.getFloat("write_speed");
      label = textLine.getString("line");
      plotPenselect(penNumber);
      plotSpeed(writeSpeed);
      plotTextSize(fontSize,fontSize*2);
      plotPosition(xPos_mm,yPos_mm);
      println("*** now starting to plot ***"); // take the label and individually sent the letters to the plotter
      println("Plotting text " + l+1 + "/" + poesieLines + ": " + label);
      println("Number of characters :" + label.length());
      for (int i=0; i < label.length(); i = i+1){
        char c = label.charAt(i);
        char cnew = evaluateLetter(c); // send to evaluation
        if (cnew == '\n'){
          println("Now making a linefeed");
          plotNewline();
          plotLetterPosition(0,0.2); // reduce linefeed distance
          //plotLabel(str(cnew));
        } else if (cnew == '\r') {
          println("Now making a carriage return");
          plotLabel(str(cnew));
        }  
          else if (cnew == '\t') {
          println("Now making a turn");
          plotSwitchDirection();
        } else if (cnew == '\b') {
          println("Now plotting a special character");
          plotter.write(SpecialCharacter);
        }  
          else {
          print();
          print(" " + cnew);
          plotLabel(str(cnew));
        }
      }
      horizontalDirection = 0;
      verticalDirection = 1;
      plotDirection(horizontalDirection, verticalDirection);
      plotPosition(0,0); // show the paper
      plotPenselect(0);
      delay(5000 * int(10 / writeSpeed));
      }
    if (ambigFlag = true) { // if there was an ambigous letter then...
      if (ambigousLabel != null){ // if there is an ambigous text specified in the json, take it
        label = ambigousLabel;
      }
      plotPenselect(ambigousPen);
      plotSpeed(ambigousSpeed);
      println("Overwriting ambigous letters now...");
      //plotPenselect(3); // draw now in red
      plotPosition(xPos_mm,yPos_mm); // go to initial position (multiline)
      //plotLetterPosition(-label.length(), 0); // go back to the latest place
      for (int i=0; i < label.length(); i = i+1){
        char c = label.charAt(i);
        char cnew = evaluateAmbigLetter(c); // send to evaluation
        print("" + cnew);
      }
    }
    plotPosition(0,0);
    plotPenselect(0);
    println("Finished plotting. Waiting for next poetry.");
    poesieLoaded = false;
    }
  }

  // functions :

  void plotLabel(String text){
    //Draw a label at the end
    //println(text);
    if (text.equals(" ")) {
      plotter.write("LB" + text + char(3),400);
      //println("Delay" + 300);
    } else {
      plotter.write("LB" + text + char(3), int(1200 *10 / writeSpeed)); //Draw label, char(3)= terminator
    }
}

void plotPenselect(int penNumber){
  //Send pen selection to plotter
  println("Pen slection: " + penNumber);
  plotter.write("SP" + penNumber + ";");
  delay(3000); // let the plotter change the pen
}

/* void plotSpacing(float spacing, float lining){
  //Send spacing and linefeed to plotter
  println("Spacing / Linefeed: " + spacing + "/ " + lining);
  plotter.write("ES" + spacing + "," + lining + ";");
} */ // not supported in HPGL-1

void plotLetterPosition(float letterposX, float letterposY){
  // move cursor to x and y places of letters
  println("Move by " + letterposX + " places horizontally, " + letterposY + " vertically");
  plotter.write("CP" + letterposX + "," + letterposY + ";",1000);
}

void plotNewline(){
  // make a carriage return and a new line
  //println("New line...");
  plotter.write("CP;",750);
}

void plotPosition(int xPos, int yPos){ // now in mm
  float xUnits = xPos / 0.025;
  float yUnits = yPos / 0.025; // calculation for plotter units / resolution
  plotter.write("PU"+xUnits+"," + yUnits + ";",1000); // position pen
}

void plotSpeed(float speed){
  println("Plotter speed: " + speed + " cm/s");
  plotter.write("VS" + speed + ";");
}

void plotTextSize(float sizeL, float sizeH){
 plotter.write("SI" + sizeL + "," + sizeH + ";");
}

void plotDirection(int directCourse, int directElevation){
  plotter.write("DI" + directCourse + "," + directElevation + ";");
}

void plotSwitchDirection(){
  String direction = str(horizontalDirection) + str(verticalDirection);
  println("HPGL direction is " + direction);
  switch (direction){
    case "01":
      horizontalDirection = 1;
      verticalDirection = 0;
      println("switching direction to 90°");
      break;
    case "10":
      horizontalDirection = 0;
      verticalDirection = -1;
      println("switching direction to 135°");
      break;
    case "0-1":
      horizontalDirection = -1;
      verticalDirection = 0;
      println("switching direction to 180°");
      break;
    case "-10":
      horizontalDirection = 0;
      verticalDirection = 1;
      println("switching direction to 0°");
      break;
  } 
  plotDirection(horizontalDirection, verticalDirection);
}
void loadPoesie(int poesieNr){ // loading from JSON file
  // displaying the names of poetry
  text("/// PLAIN IFXI 2.0 ///", 100, 50);
  for (int p=0; p<poesieJSON.size(); p=p+1){
    poesieObject = poesieJSON.getJSONObject(p);
    if (p == poesieNr){
      fill(180, 50, 50);
    } else { fill(0);}
    text(p + " / " + poesieObject.getString("name") + " [" + poesieObject.getString("author") + "]",100,125+50*p);
    println(poesieObject.getString("name"));
  }
  println("Number of poesie found: " + poesieJSON.size());
  println("Looking for poesie number " + poesieNr);
  poesieObject = poesieJSON.getJSONObject(poesieNr);
  ambigousLabel = poesieObject.getString("ambigous line");
  if (poesieObject.isNull("pen_number") == false){
    ambigousPen = poesieObject.getInt("pen_number");
    println("Ambigous pen number is set to:" + ambigousPen);}
  if (poesieObject.isNull("write_speed") == false){
    ambigousSpeed = poesieObject.getFloat("write_speed");}
  println("Ambigous is " + ambigousLabel);
  println("Plotting poesie: " + poesieObject);
  String poesieName = poesieObject.getString("name");
  println ("Poesie selected: " + poesieName);
  ambigousLetters = poesieObject.getString("ambigous");
  println ("Ambigous letters used: " + ambigousLetters);
  fontSize = poesieObject.getFloat("font size");
  println ("Setting font size of " + fontSize + "cm.");
  if (poesieObject.isNull("direction change") == false){
    directionChange = poesieObject.getBoolean("direction change");
    println("Change direction activated. " + directionChange);
  }
  poesieTextJSON = poesieObject.getJSONArray("text lines");
  poesieLines = poesieObject.getJSONArray("text lines").size();
  println(poesieLines + " Text(s) in this poesie.");
  textLine = poesieTextJSON.getJSONObject(0);
  String labelLines = textLine.getString("line");
  int lineCounter = 0;
  int characterCounter = 0;
  int maxCharacterCounter = 0;
  float lineLength = 0;
  for (int k=0; k<labelLines.length(); k=k+1){
    char d = labelLines.charAt(k);
    characterCounter++;
    if (d == '\n' || d =='\t'){
      lineCounter++;
      if (characterCounter > maxCharacterCounter){
      maxCharacterCounter = characterCounter;
      characterCounter = 0;
      }
    }
    if (characterCounter > maxCharacterCounter){
      maxCharacterCounter = characterCounter;
      characterCounter = 0;
      }
  }
  plotSize = (lineCounter)*(4*fontSize-4*fontSize*0.2)+fontSize*2; // total size = lines-1 * 2* fontsize * 2 height + 2* fontsize
  lineLength = maxCharacterCounter * fontSize;
  println("Plotting poesie will take " + lineCounter + " lines and this will be : " + plotSize +" cm.");
  println("Maximal line length is " + lineLength + "cm for " + maxCharacterCounter + " characters at " + fontSize + "cm font width.");
  if (lineLength * 10 > paperWidth) {
    fontSize = paperWidth / (maxCharacterCounter * 10); // from centimeters to milimeters
    println("*** At least one line has too many characters and plotting will be partial.  ***");
    println("*** So reducing font size to plot everything.                                ***");
    plotSize = (lineCounter)*(4*fontSize-4*fontSize*0.2)+fontSize*2; // total size = lines-1 * 2* fontsize * 2 height + 2* fontsize
    lineLength = maxCharacterCounter * fontSize;
    println("*** New font size " + fontSize + "cm. New line length " + lineLength + "cm. New plotSize " + plotSize + "cm. ***");
  }
  println("[JSON] Poesie loaded.");
  println();
  // calculate poetry position on paper
  xPos_mm = int((paperHeight / 2) - plotSize*10/2); // A3 plotter area is 401 mm long >>> Golden / middle position. A3 420 * 297 mm
  yPos_mm = 10;
  poesieLoaded = true;
}

void keyReleased() {
 if (key == 'P' || key == 'p') {
      plotTextSize(fontSize,fontSize*2);
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
    } else if (key == 'Q' || key == 'q') {
      exit();
    } else if (key == '0' || key == '1' || key == '2' || key == '3' || key == '4' || key == '5' || key == '6' || key == '7' || key == '8'|| key == '9') {
      int selectKey = int(str(key));
      println("Key pressed is " + selectKey);
      loadPoesie(selectKey);
      delay(2000);
    } 
 }
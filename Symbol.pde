/*************************
  Symbol class
*************************/

class Symbol{
  float tx, ty;
  float w, h;
  float r;
  int selector;
  ArrayList<PVector> points = new ArrayList<PVector>();
  
  Symbol(float xpos, float ypos, float scaleX, float scaleY, float rot, int symbolSelect){
    tx  = xpos;
    ty  = ypos;
    w = scaleX; //scale + modify by osc_amplitude
    h = scaleY;//*map(osc_amplitude,1,10,-5,10);
    r = radians(rot);
    selector = symbolSelect;
    
    switch (selector){
    case 1: //here's a cube, for instrument A
      points.add( new PVector(1,0) );
      points.add( new PVector(1,1) );
      points.add( new PVector(0,1) );
      points.add( new PVector(0,0) );
      points.add( new PVector(1,0) );
      break;
    case 2: // triangle for instrument B
      points.add( new PVector(0,0) );
      points.add( new PVector(1,1) );
      points.add( new PVector(1,0) );
      points.add( new PVector(0,0) );
      break;//*/
    /* simple flash
      points.add( new PVector(0,0) );
      points.add( new PVector(2,0) );
      points.add( new PVector(1,0.5) );
      points.add( new PVector(1,-0.5) );
      points.add( new PVector(2,0) );
      break;
    /*
    //here's a chevron
    points.add( new PVector(0,0) );
    points.add( new PVector(0.5,0.5) );
    points.add( new PVector(0,1) );
    points.add( new PVector(1,1) );
    points.add( new PVector(1.5,0.5) );
    points.add( new PVector(1,0) );
    points.add( new PVector(0,0) );
    
    //here's a bunch of upside down crosses \m/
    w /= 3; //scale down to a third of the size
    h /= 3;
    points.add( new PVector(0,1) );
    points.add( new PVector(2,1) );
    points.add( new PVector(2,0) );
    points.add( new PVector(3,0) );
    points.add( new PVector(3,1) );
    points.add( new PVector(4,1) );
    points.add( new PVector(4,2) );
    points.add( new PVector(3,2) );
    points.add( new PVector(3,3) );
    points.add( new PVector(2,3) );
    points.add( new PVector(2,2) );
    points.add( new PVector(0,2) );
    points.add( new PVector(0,1) );
    
    /*
    //here's a simple lightning bolt shape
    w /= 7; //scale down
    h /= 7;
    points.add( new PVector(5,0) );
    points.add( new PVector(0,4) );
    points.add( new PVector(4.2, 2.3) );
    points.add( new PVector(4,5) );
    points.add( new PVector(9,1) );
    points.add( new PVector(4.8,2.7) );
    points.add( new PVector(5,0) );
    
    */
    }
  }
  
  void drawIt(int vs){  
    if ((vs!=vsOld)){ //||(vs == vsOld) to make write VS command everythime
      plotter.write("VS"+vs+";"); // set drawing speed on plotter if changed
      println("Plotting at " + vs + " cm/s");
      vsOld = vs;
    }
    for (int i=0; i<points.size()-1; i++){
      drawLine(
        rotX(points.get(i).x, 
        points.get(i).y)*w+tx, 
        rotY(points.get(i).x, 
        points.get(i).y)*h+ty, 
        rotX(points.get(i+1).x, 
        points.get(i+1).y)*w+tx, 
        rotY(points.get(i+1).x, 
        points.get(i+1).y)*h+ty, 
        (i==0)
      );
      
      if (i==points.size()-2){
        plotter.write("PU;");  
      }
    }

    if (PLOTTING_ENABLED){
      delay(750);
    }
  }
  
  void drawLine(float x1, float y1, float x2, float y2, boolean up){
    line(x1, y1, x2, y2);
    float _x1 = map(x1, 0, width, xMin, xMax);
    float _y1 = map(y1, 0, height, yMin, yMax);
    
    float _x2 = map(x2, 0, width, xMin, xMax);
    float _y2 = map(y2, 0, height, yMin, yMax);
    
    String pen = "PD";
    if (up) {pen="PU";}
    
    plotter.write(pen+_x1+","+_y1+";");
    //println(pen+_x1+","+_y1+";");
    plotter.write("PD"+_x2+","+_y2+";", controlDelay); //75 ms delay
  }
    float rotX(float inX, float inY){
    inX = inX-0.5; // translate from center point for rectancgle
    inY = inY-0.5; // translate from center point
    float sinus = inX*cos(r) - inY*sin(r);
    sinus = sinus + 0.5; // retranslate to origine
  return sinus;
  }
  
  float rotY(float inX, float inY){
     inX = inX-0.5;
     inY = inY-0.5;
     float sinus = inX*sin(r) + inY*cos(r);
     sinus = sinus + 0.5;
   return sinus;
  }
  /*float rotX(float inX, float inY){
   return (inX*cos(r) - inY*sin(r)); 
  }
  
  float rotY(float inX, float inY){
   return (inX*sin(r) + inY*cos(r)); 
  }
  */
}

/*************************
  Simple plotter class
*************************/

class Plotter {
  Serial port;
  
  Plotter(Serial _port){
    port = _port;
  }
  
  void write(String hpgl){
    if (PLOTTING_ENABLED){
      port.write(hpgl);
    }
  }
  
  void write(String hpgl, int del){
    if (PLOTTING_ENABLED){
      port.write(hpgl);
      delay(del);
    }
  }
}

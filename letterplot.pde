void plotletterAmbig (char letterAmbig){
    switch(letterAmbig) {
    case 'E':
        plotter.write("UC4,0,99,-4,0;");
        println("Now plotting to complete letter " + letterAmbig);
        break;
    case 'O':
        plotter.write("UC4,6,99,0,-4");
        println("Now plotting to complete letter " + letterAmbig);
        break;
    case 'R':
        plotter.write("UC3,3.5,99,0.5,-0.2,0.5,-0.3,0,-3");
        println("Now plotting to complete letter " + letterAmbig);
        break;
    
    }
}
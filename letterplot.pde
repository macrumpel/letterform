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
    
    }
}
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
        plotter.write("UC3,3.5,99,0.5,-0.2,0.3,-0.3,0.2,-0.5,0,-2.5");
        println("Now plotting to complete letter " + letterAmbig);
        break;
    case '?':
        plotLabel("?");
        println("Now plotting to complete sign " + letterAmbig);
        break;
    case '!':
        plotLabel("!");
        println("Now plotting to complete sign " + letterAmbig);
        break;
    case 'T':
        plotter.write("UC0,8,99,4,0");
        println("Now plotting to complete letter " + letterAmbig);
        break;
    case 'U':
        plotter.write("UC0,3,99,0,5");
        println("Now plotting to complete letter " + letterAmbig);
        break;
    case 'B':
        plotter.write("UC3,8,99,0.5,-0.2,0.3,-0.3,0.2,-0.5,0,-1.5,-0.2,-0.5,-0.3,-0.3,-0.5,-0.2,0.5,-0.2,0.3,-0.3,0.2,-0.5,0,-2.5,-0.2,-0.5,-0.3,-0.3,-0.5,-0.2,");
        println("Now plotting to complete letter " + letterAmbig);
        break;
    case 'Q':
        plotter.write("UC3,3,99,-3,-1");
        println("Now plotting to complete letter " + letterAmbig);
        break;
    
    }
}

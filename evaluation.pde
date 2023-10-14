/************************
Replace ambigous letters
***********************/

char evaluateLetter(char letter){ 
 if (letter == 'E'){
      letter = 'F';
      boolean ambigFlag = true;
  }

return letter;
}

char evaluateAmbigLetter(char letter){ 
 if (letter == 'E'){
      letter = 'E';
      boolean ambigFlag = false;
      plotletterAmbig(letter);
  } else {
    plotLabel(" ");
  }

return letter;
}
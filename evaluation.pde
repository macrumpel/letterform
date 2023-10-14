/************************
Replace ambigous letters
***********************/

char evaluateLetter(char letter){ 
 switch (letter) {
      case 'E' :
        letter = 'F';
        ambigFlag = true;
        break;
      case 'O' :
        letter = 'C';
        ambigFlag = true;
        break;
  }

return letter;
}

char evaluateAmbigLetter(char letter){ 
  String ambigousLetters = "EO";
 if (ambigousLetters.contains(str(letter))){
      ambigFlag = false;
      plotletterAmbig(letter);
  } else if ((letter == '\n') || (letter == '\r')) {
      plotLabel(str(letter));
  } else {
      plotLabel(" ");
  }

return letter;
}
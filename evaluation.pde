/************************
Replace ambigous letters
***********************/

char evaluateLetter(char letter){ 
  if (ambigousLetters.contains(str(letter))){
  switch (letter) {
        case 'E' :
          letter = 'F';
          ambigFlag = true;
          break;
        case 'O' :
          letter = 'C';
          ambigFlag = true;
          break;
        case 'R' :
          letter = 'P';
          ambigFlag = true;
          break;
        case 'B' :
          letter = 'E';
          ambigFlag = true;
          break;
        case '?' :
          letter = '.';
          ambigFlag = true;
          break;
        case 'T' :
          letter = '\t';
          SpecialCharacter = "UC2,0,99,0,8";
          //plotPosition(-1,0);
          ambigFlag = true;
          break;
        case 'U' :
          letter = 'J';
          ambigFlag = true;
          break;
  }
  }
return letter;
}

char evaluateAmbigLetter(char letter){ 
 if (ambigousLetters.contains(str(letter))){
      ambigFlag = false;
      plotletterAmbig(letter);
  } else if (letter == '\n') {
      plotLabel(str(letter));
      plotLetterPosition(0,0.1); // reduce linefeed distance
  }  else if (letter == '\r') {
      plotLabel(str(letter));
  }  else {
      plotLabel(" ");
  }

return letter;
}
/* Is this class still in use?*/

//kuler: aarb test1
//color [] cPalette = {#B28484, #CC5051, #FFFC60, #B2B151, #8FD5FF};

//kuler: robots are cool
//color cBackground = #1E3A40;
//color [] cPalette = {#688C8C, #D9D1BA, #F2D194, #F2A057};
//color cAlpha = 0xFF;

//red-centered analagous
//color cBackground = #EFEFEF;
//color [] cPalette = {#E80653, #FF2606, #FFA606, #E86005};
//color cAlpha = (int)random(255);
// 0x40; old colour value

//infographic colors
//color cBackground = 0xFFFFED;
//color [] cPalette = {#FF2C38, #FF9A3A, #FFF040, #67D9FF};
//float [] probPalette = {0.166, 0.166, 0.166, 0.5};
//float [] probPalette = {0, 0, 0, 1};
//color cAlpha = 0xff;

//data colors
//color cBackground = 0x000000;
color [] cPalette = { #ffffff};
float [] probPalette = {1};
//float [] probPalette = {0, 0, 0, 1};
color cAlpha = 0xff;

int randomColorSeed;
int randomColorNext;

void setupColors() {
    randomColorSeed = (int)random(2147483647);
    randomColorNext = randomColorSeed;
    println(randomColorSeed);
}


//gets the first color in the sequence
void goFirstColor() {
  randomColorNext = randomColorSeed;
}

//gets the next color in the sequence
color nextColor() {
  //backup the seed
  int seedOld = (int)random(2147483647);
  randomSeed(randomColorNext);
  
  //pick a random number and initialize
  float rnd = random(1);
  float probAccum = 0;
  int index=cPalette.length - 1;
  
  //choose a color value given the probability distribution
  for (int i=0; i<cPalette.length; i++) {
    probAccum+=probPalette[i];
    if (rnd<=probAccum) {
      index = i;
      break;
    }
  }
    
  //restore the seed
  randomColorNext = (int) (rnd*2147483647);
  randomSeed(seedOld);
  
  //return the selected color value
  return cPalette[index];
}

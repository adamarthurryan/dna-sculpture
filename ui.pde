import processing.dxf.*;
import java.awt.event.*;

/** UI states*/
boolean editMode = false;
int editIndex = 0;
boolean flatten = false;
boolean plotNumbers = false;
boolean hideAfterEditIndex = false;
boolean recordDXF = false;
boolean captureScene = false;

boolean renderFX = true;
boolean renderBlur = false;
boolean animateAngle = false;
boolean renderWireframe = false;

/** Mouse position variables. */
boolean mouseDownLeft = false;
boolean mouseDownRight = false;
int lastMouseX=0, lastMouseY=0;

boolean shiftDown = false;
boolean ctrlDown = false;

/** The current position of the mouse wheel (as a delta). */

/** The length of interpolation in milliseconds.*/
int interpolationFactorMouse = 500;
int interpolationFactorAngle = 500;
int animationFactorAngle = 100;
int millisLastDraw = 0;
int elapsedLastDraw = 0;


PShader fog;
PShader depth;


PShader wireframe;


void setupUI() {
  setupMouseWheel();


  fog = loadShader("FogFrag.glsl", "FogVert.glsl");

  depth = loadShader("DepthFrag.glsl", "DepthVert.glsl");

  displayAngleDegrees = state.sequenceData.angleDegrees;
  wireframe = loadShader("Wireframe.glsl");

}

void renderScene() {
  //initialize the lights
  noLights();
  directionalLight(256, 256, 256, -1, -1, 1);
  ambientLight(128, 128, 128);
  
  //lights();

  //the background
  background(state.colorData.background);
  //noStroke();

  pushMatrix();

  //center and resize the scene so that an edge length of 1 is useful
  translate(width/2, height/2);
  scale(width/2/10);

  //push the sequence back into the scene a bit, so it fits in the frustrum
  float depthOffset=-10;
  translate(0, 0, depthOffset);

  //apply the view transformations specified by the mouse
  //(with interpolation effects)
  doMousePan();
  doMouseRotate();
  doMouseScale();

  if (renderFX) {
    //pushMatrix();
    //scale(0.01);
    //plotSequence(polyShapes, sequence, 0);
    //popMatrix();
    shader(fog);
  }

  //plot the sequence
  plotSequence(polyShapes, state.sequenceData.sequence, radians(displayAngleDegrees));

  
  if (renderWireframe) 
    filter(wireframe);

  if (renderFX) {
    
    
    //filter(BLUR, 1);
    //filter(BLUR, 5);
    //translate(0, 0, 0.01);
    //resetShader();
    //plotSequence(polyShapes, sequence, radians(displayAngleDegrees));
  }

  if (renderBlur) {
    filter(BLUR, 1);
  }
  resetShader();
  popMatrix();
}

/** Draw handler. */
void draw() {
  if (recordDXF) {
    beginRaw(DXF, "output.dxf");
  }

  //calculate the time elapsed since the last draw call
  elapsedLastDraw = millis() - millisLastDraw;
  millisLastDraw = millis();

  if (animateAngle)
    doAnimateAngle();
  else 
    doDisplayAngleInterpolate();

  //set the shader parameters
  float [] fogColor = new float[] {red(state.colorData.background)/255.0, green(state.colorData.background)/255.0, blue(state.colorData.background)/255.0, 1.0};
  float [] shadowColor = new float[] {red(state.colorData.shadow)/255.0, green(state.colorData.shadow)/255.0, blue(state.colorData.shadow)/255.0, 1.0};
  float [] lightColor = new float[] {red(state.colorData.light)/255.0, green(state.colorData.light)/255.0, blue(state.colorData.light)/255.0, 1.0}; 
  fog.set("fogColor", fogColor, 4);
  fog.set("shadowColor", shadowColor, 4);
  fog.set("lightColor", lightColor, 4);
  fog.set("fogOffset", state.fog.offset);
  fog.set("fogScale", state.fog.scale);
  depth.set("fogOffset", state.fog.offset);
  depth.set("fogScale", state.fog.scale);
  wireframe.set("backgroundColor", fogColor, 4);
  wireframe.set("lineColor", shadowColor, 4);
  

  initializeCaptureCamera();
  renderScene();

  if (captureScene) {
    captureScene=false;
    captureScene();
  }

  if (recordDXF) {
    endRaw();
    recordDXF = false;
  }
}


/** Prompt for a sequence length and then produce a random sequence of that length.*/
void editRandomLength() {
  String sLengthRandom = javax.swing.JOptionPane.showInputDialog("Random sequence length:", state.sequenceData.lengthRandom);
  if (sLengthRandom!=null) {
    state.sequenceData.lengthRandom = int(sLengthRandom);
    state.sequenceData.sequence = Sequence.calcRandomSequence(state.sequenceData.seed, state.sequenceData.lengthRandom);
  }
}


float displayAngleDegrees;
/** Prompt for an inter-shape angle. */
void editAngle() {
  String sAngleDegrees = javax.swing.JOptionPane.showInputDialog("Inter-shape angle (in degrees):", state.sequenceData.angleDegrees);
  if (sAngleDegrees!=null)
    state.sequenceData.angleDegrees = float(sAngleDegrees);

  millisLastDraw = millis();
}

/** Prompt to edit the current sequence. */
void editSequence() {
  String sSequence = Sequence.toString(state.sequenceData.sequence);
  sSequence = javax.swing.JOptionPane.showInputDialog("Sequence:", sSequence);
  if (sSequence!=null)
    state.sequenceData.sequence = Sequence.parse(sSequence);
}
/** Prompt to edit the current sequence. */
void editColors() {
  String sColor;
  sColor = javax.swing.JOptionPane.showInputDialog("Background color:", Integer.toHexString(state.colorData.background));
  if (sColor!=null)
    state.colorData.background = Integer.parseInt(sColor, 16);

  sColor = javax.swing.JOptionPane.showInputDialog("Light color:", Integer.toHexString(state.colorData.light));
  if (sColor!=null)
    state.colorData.light = Integer.parseInt(sColor, 16);

  sColor = javax.swing.JOptionPane.showInputDialog("Shadow color:", Integer.toHexString(state.colorData.shadow));
  if (sColor!=null)
    state.colorData.shadow = Integer.parseInt(sColor, 16);
}

void editSequenceRepeatCount() {
  String sSequenceRepeatCount = javax.swing.JOptionPane.showInputDialog("Sequence repeat count:", state.sequenceData.repeatCount);
  if (sSequenceRepeatCount!=null)
    state.sequenceData.repeatCount = int(sSequenceRepeatCount);
}

/** Prompt to edit the effects parameters. */
void editEffects() {
  String sFogOffset = javax.swing.JOptionPane.showInputDialog("Fog offset:", state.fog.offset);
  if (sFogOffset != null) {
    state.fog.offset = float(sFogOffset);
  }
  String sFogScale = javax.swing.JOptionPane.showInputDialog("Fog scale:", state.fog.scale);
  if (sFogScale != null) {
    state.fog.scale = float(sFogScale);
  }
}

/** Mouse handler. */
void mouseClicked() {
  //  sequence = calcRandomSequence(polyShapes, lengthRandom);
  //  printSequence(polyShapes, sequence);
}

void mousePressed() {
  if (mouseButton == LEFT)
    mouseDownLeft = true;
  else if (mouseButton == RIGHT)
    mouseDownRight = true;

  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

void mouseReleased() {
  mouseDownLeft = false;
  mouseDownRight = false;
}

void mouseDragged() {
  if (mouseDownLeft && !shiftDown) {
    state.pan.x = state.pan.x + (mouseX-lastMouseX);
    state.pan.y = state.pan.y + (mouseY-lastMouseY);
  }
  else if (mouseDownRight || (mouseDownLeft && shiftDown)) {
    state.rotate.x = state.rotate.x + (mouseX-lastMouseX);
    state.rotate.y = state.rotate.y + (mouseY-lastMouseY);
  }
  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

/** Sets up the mouse wheel listener.*/
void setupMouseWheel() {
  /*  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
   public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
   state.scale += evt.getWheelRotation();
   }}); 
   */
}


/** Key handler. */
void keyPressed() {
  if (key == CODED && keyCode == SHIFT) {
    shiftDown = true;
  }    
  if (key == CODED && keyCode == CONTROL) {
    ctrlDown = true;

  }    
  
  if (key == CODED) {
    if (keyCode == LEFT && shiftDown)
      state.rotate.x -= 30;
    else if (keyCode == LEFT)
      state.pan.x -= 30;
    else if (keyCode == RIGHT && shiftDown)
      state.rotate.x += 30;
    else if (keyCode == RIGHT)
      state.pan.x += 30;
    else if (keyCode == UP && shiftDown)
      state.rotate.y -= 30;
    else if (keyCode == UP)
      state.pan.y -= 30;
    else if (keyCode == DOWN && shiftDown)
      state.rotate.y += 30;
    else if (keyCode == DOWN)
      state.pan.y += 30;
    else if (keyCode == java.awt.event.KeyEvent.VK_PAGE_DOWN && shiftDown)
      state.rotate.z -= 30; 
    else if (keyCode == java.awt.event.KeyEvent.VK_PAGE_DOWN)
      state.pan.z -= 30;
    else if (keyCode == java.awt.event.KeyEvent.VK_PAGE_UP && shiftDown)
      state.rotate.z += 30; 
    else if (keyCode == java.awt.event.KeyEvent.VK_PAGE_UP)
      state.pan.z += 30;
  }
  //zoom in - like the scroll wheel
  if (key =='+' || key == '=')
    state.scale.factor++;
  //zome out - like the scroll wheel
  else if (key == '-' || key == '_')
    state.scale.factor--;
  
  //reset the view
  else if (key == '0') {
    state.rotate.x = 0;
    state.rotate.y = 0;
    state.rotate.z = 0;
    state.pan.x = 0;
    state.pan.y = 0;
    state.pan.z = 0;
    state.scale.factor = 1;
  }
    
  //edit the color values
  else if (key == 'c') {
    editColors();
  }
  //calculate a random sequence with a user input length
  else if (key == 'l') {
    editRandomLength();
  }
  //new random sequence
  else if (key == 'r') {
    randomSeed(millis());
    state.sequenceData.seed = (int)random(2147483647); 
    state.sequenceData.sequence = Sequence.calcRandomSequence(state.sequenceData.seed, state.sequenceData.lengthRandom);
  }
  //read state file
  else if (ctrlDown && keyCode == java.awt.event.KeyEvent.VK_O) {
    readState();
  }
  //write state file
  else if (ctrlDown  && keyCode == java.awt.event.KeyEvent.VK_S) {
    writeState();
  }
  //write default state file
  else if (ctrlDown  && keyCode == java.awt.event.KeyEvent.VK_Q) {
    writeDefaultState();
  }
  
  //prompt for a user input angle
  else if (key == 'a') {
    editAngle();
  }
  else if (key == 'A') {
    animateAngle = !animateAngle;
  }
  //prompt for a user input sequence
  else if (key == ENTER || key == RETURN || key == 'e') {
    editSequence();
  }
  else if (key == 'k') {
    editSequenceRepeatCount();
  }
  
  //flatten the object while SPACE is held
  else if (key == ' ') {
    flatten = true;
  }
  //toggle number display
  else if (key == 'n') {
    plotNumbers = !plotNumbers;
  }

  //record DXF
  else if (ctrlDown && keyCode == java.awt.event.KeyEvent.VK_D) {
    recordDXF = true;
  }
  else if (ctrlDown && keyCode == java.awt.event.KeyEvent.VK_C) {
    captureScene = true;
  }

  //show effects
  else if (key == 'f') {
    renderFX = !renderFX;
  }
  else if (key == 'w') {
    renderWireframe = !renderWireframe;
  }
  else if (key == 'b') {
    renderBlur = !renderBlur;
    println(renderBlur);
  }
  else if (key == 'F') { 
    editEffects();
  }

/*
  if (key == TAB) {
    editMode = !editMode;
    if (!editMode)
      hideAfterEditIndex = false;
  }
*/
/*
  if (editMode) {
    if (key == 'q') {
      editIndex--;
      editIndex = max(0, editIndex);
    }
    if (key == 'w') {
      editIndex++;
      editIndex = min((state.sequence.length-1)/2, editIndex);
    }
    if (key == 't' || key =='h' || key == 'p' || key == 's') {
      int shapeIndex = ((Integer) (Sequence.codeToIndex.get(key))).intValue();
      if (state.sequence.length > editIndex*2+1) {
        state.sequence[editIndex*2+1] = min(polyShapes[shapeIndex].getVertexCount()-1, state.sequence[editIndex*2+1]);
      }
      state.sequence[editIndex*2] = shapeIndex;
    }
    if (key >= '1' && key <= '9') {
      int sideIndex = int(key) - int('1') + 1;
      if (state.sequence.length > editIndex*2+1 && polyShapes[state.sequence[editIndex*2]].getVertexCount() > sideIndex)
        state.sequence[editIndex*2+1] = sideIndex;
    }
    if (key == 'z')
      hideAfterEditIndex = !hideAfterEditIndex;
  }
*/
}

/** Key handler. */
void keyReleased() {
  if (key == ' ')
    flatten = false;

  if (key == CODED && keyCode == SHIFT) {
    shiftDown = false;
  }
  if (key == CODED && keyCode == CONTROL) {
    ctrlDown = false;
  }
}

/** Adjusts the angle between elements*/
void doDisplayAngleInterpolate() {
  float itrp = ((float) elapsedLastDraw) / interpolationFactorAngle;
  displayAngleDegrees = (displayAngleDegrees*(1-itrp))+((flatten? 0:state.sequenceData.angleDegrees)*itrp);
}

/** Adjusts the angle between elements*/
void doAnimateAngle() {
  float itrp = ((float) elapsedLastDraw) / animationFactorAngle;
  displayAngleDegrees = (displayAngleDegrees*(1-itrp))+((displayAngleDegrees+1)*itrp);
  
  if (displayAngleDegrees > 360)
    displayAngleDegrees -= 360;
}

float rx = 0;
float ry = 0;
float rz = 0;
/** rotates the scene given the mouse position*/
void doMouseRotate() {
  float rxp = ((state.rotate.x)*0.005);
  float ryp = ((state.rotate.y)*0.005);
  float rzp = ((state.rotate.z)*0.005);
  float itrp = ((float) elapsedLastDraw) / interpolationFactorMouse;
  rx = (rx*(1-itrp))+(rxp*itrp);
  ry = (ry*(1-itrp))+(ryp*itrp);
  rz = (rz*(1-itrp))+(rzp*itrp);
  
  rotateZ(rz);
  rotateY(rx);
  rotateX(ry);
}

float panx = 0;
float pany = 0;
float panz = 0;
void doMousePan() {
  float panxp = (state.pan.x)*0.02;
  float panyp = (state.pan.y)*0.02;
  float panzp = (state.pan.z)*0.02;
  float itrp = ((float) elapsedLastDraw) / interpolationFactorMouse;
  panx = (panx*(1-itrp))+(panxp*itrp);
  pany = (pany*(1-itrp))+(panyp*itrp);
  panz = (panz*(1-itrp))+(panzp*itrp);
  translate(panx, pany, panz);
}

/** scales the scene given the mouse wheel */
void doMouseScale() {
  float sceneScale = pow(2, state.scale.factor/12f);
  scale(sceneScale);
}


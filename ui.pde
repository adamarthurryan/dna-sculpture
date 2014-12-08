import processing.dxf.*;
import java.awt.event.*;

/* ------ UI states*/

/** Set to true when recording the scene as a DXF file.*/
boolean recordDXF = false;

/** Set to true when rendering the scene as an image.*/
boolean captureScene = false;

/** Set to false to disable all visual fx.*/
boolean renderFX = true;

/** Set to true to render a soft-focus blur.*/
boolean renderBlur = false;

/** Set to true to animate the dihedral angle - folding the sequence open and closed. */
boolean animateAngle = false;

/** Set to true to render the squence as a wireframe.*/
boolean renderWireframe = false;

/* ---------- Mouse position variables. */

/** True when the left mouse button is pressed.*/
boolean mouseDownLeft = false;

/** True when the right mouse button is pressed.*/
boolean mouseDownRight = false;

/** The coordinates of the mouse position during the last draw cycle.*/
int lastMouseX=0, lastMouseY=0;

/** True when shift is held down.*/ 
boolean shiftDown = false;

/** True when control is held down.*/
boolean ctrlDown = false;


/* --- Interpolation parameters 
  Changes to the state are not reflected instantly, rather they are 
  phased in - interpolated in - using these parameters.*/

/** The length of mouse interpolation in milliseconds 
  - the amount of time it takes a mouse movement to be fully reflected in the display.*/
int interpolationFactorMouse = 500;

/** The length of angle interpolation in milliseconds 
  - the amount of time it takes an angle change to be fully reflected in the display.*/int interpolationFactorAngle = 500;
int animationFactorAngle = 100;

/** The millisecond timestamp of the last draw cycle.*/
int millisLastDraw = 0;
/** The time elapsed since the last draw cycle.*/
int elapsedLastDraw = 0;

/** If true, flatten the sequence and render with a dihedral angle of 0.*/
boolean flatten = false;

//render shaders
PShader fog;
PShader depth;
PShader wireframe;

/** Initialize the UI: shaders, listeners, etc. */
void setupUI() {
  //setupMouseWheel();

  //initialize the display degrees from the state
  displayAngleDegrees = state.sequenceData.angleDegrees;
  
  fog = loadShader("FogFrag.glsl", "FogVert.glsl");
  depth = loadShader("DepthFrag.glsl", "DepthVert.glsl");
  wireframe = loadShader("Wireframe.glsl");
}

/** Render the current scene.
  This method is called by draw once each render cycle.
  This is the heart of the render cycle.*/
void renderScene() {
  //initialize the lights
  noLights();
  directionalLight(256, 256, 256, -1, -1, 1);
  ambientLight(128, 128, 128);
  
  //lights();

  //the background
  background(state.colorData.background);
  //noStroke();

  //push a transformation matrix
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

  //render fx if they are enabled
  if (renderFX) {
    //pushMatrix();
    //scale(0.01);
    //plotSequence(polyShapes, sequence, 0);
    //popMatrix();
    shader(fog);
  }

  //plot the sequence
  plotSequence(polyShapes, state.sequenceData.sequence, radians(displayAngleDegrees));

  //render the wireframe with a shader, if it is enabled
  if (renderWireframe) 
    filter(wireframe);

  //render fx if they are enabled
  if (renderFX) {
    //filter(BLUR, 1);
    //filter(BLUR, 5);
    //translate(0, 0, 0.01);
    //resetShader();
    //plotSequence(polyShapes, sequence, radians(displayAngleDegrees));
  }

  //render the blur with a shader if it is enabled
  if (renderBlur) {
    filter(BLUR, 1);
  }

  //reset the shaders
  resetShader();

  //pop the transformation matrix
  popMatrix();
}

/** Draw handler.
  Draw is called once per render cycle.
  This method reads changes to the state or user input and calculates the interpolation of each.
  Calls renderScene() for the actual rendering. */
void draw() {
  //record to a DXF if enabled
  if (recordDXF) {
    beginRaw(DXF, "output.dxf");
  }

  //calculate the time elapsed since the last draw call
  elapsedLastDraw = millis() - millisLastDraw;
  millisLastDraw = millis();

  //if we are currently animating the dihedral, update the dihedral based on the animation parameters
  if (animateAngle)
    doAnimateAngle();
  //otherwise, interpolate the display dihedral from the state
  else 
    doDisplayAngleInterpolate();

  //set the shader parameters
  //shader parameters are given in the application state
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
  
  //initialize the camera
  initializeCaptureCamera();

  //render the scene
  renderScene();

  //if we are capturing the scene
  if (captureScene) {
    //reset the flag
    captureScene=false;
    //do the capture
    captureScene();
  }

  //if we are recording a DXF, end the recording and reset the flag
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

/** The dihedral angle that is currently being displayed 
  - a function of state dihedral and interpolation, or dihedral animation.*/
float displayAngleDegrees;

/** Prompt for a dihedral angle. */
void editAngle() {
  //prompt
  String sAngleDegrees = javax.swing.JOptionPane.showInputDialog("Inter-shape angle (in degrees):", state.sequenceData.angleDegrees);

  //update the state
  if (sAngleDegrees!=null)
    state.sequenceData.angleDegrees = float(sAngleDegrees);

  //update the draw timestamp
  millisLastDraw = millis();
}

/** Prompt to edit the current sequence. */
void editSequence() {
  //prompt
  String sSequence = Sequence.toString(state.sequenceData.sequence);
  sSequence = javax.swing.JOptionPane.showInputDialog("Sequence:", sSequence);
  
  //update the state
  if (sSequence!=null)
    state.sequenceData.sequence = Sequence.parse(sSequence);
}

/** Prompt to edit the display colors. */
void editColors() {
  //background color: prompt and update state
  String sColor;
  sColor = javax.swing.JOptionPane.showInputDialog("Background color:", Integer.toHexString(state.colorData.background));
  if (sColor!=null)
    state.colorData.background = Integer.parseInt(sColor, 16);

  //color of light
  sColor = javax.swing.JOptionPane.showInputDialog("Light color:", Integer.toHexString(state.colorData.light));
  if (sColor!=null)
    state.colorData.light = Integer.parseInt(sColor, 16);

  //color of shadow
  sColor = javax.swing.JOptionPane.showInputDialog("Shadow color:", Integer.toHexString(state.colorData.shadow));
  if (sColor!=null)
    state.colorData.shadow = Integer.parseInt(sColor, 16);
}

/** Prompt to change the number of times the sequence repeats */
void editSequenceRepeatCount() {
  //prompt
  String sSequenceRepeatCount = javax.swing.JOptionPane.showInputDialog("Sequence repeat count:", state.sequenceData.repeatCount);

  //update state
  if (sSequenceRepeatCount!=null)
    state.sequenceData.repeatCount = int(sSequenceRepeatCount);
}

/** Prompt to edit the effects parameters. */
void editEffects() {
  //fog starting depth: prompt and edit state
  String sFogOffset = javax.swing.JOptionPane.showInputDialog("Fog offset:", state.fog.offset);
  if (sFogOffset != null) {
    state.fog.offset = float(sFogOffset);
  }

  //fog scale (density by depth)
  String sFogScale = javax.swing.JOptionPane.showInputDialog("Fog scale:", state.fog.scale);
  if (sFogScale != null) {
    state.fog.scale = float(sFogScale);
  }
}

/** Does nothing */
void mouseClicked() {
  //  sequence = calcRandomSequence(polyShapes, lengthRandom);
  //  printSequence(polyShapes, sequence);
}

/** Respond to mouse events.
  Simply updates the mouse position flags and variables:
    mouseDownLeft, mouseDownRight, lastMouseX, lastMouseY.*/
void mousePressed() {
  if (mouseButton == LEFT)
    mouseDownLeft = true;
  else if (mouseButton == RIGHT)
    mouseDownRight = true;

  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

/* Respond to mouse events.
  Simply updates the mouse position flags and variables:
    mouseDownLeft, mouseDownRight.*/
void mouseReleased() {
  mouseDownLeft = false;
  mouseDownRight = false;
}

/* Respond to mouse events.
    Left button drag: pan
    Right button drag: rotate.
    Updates the pan or rotation in the state as well as the mouse position flags and variables.
    */
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

/** Sets up the mouse wheel listener.
  This may cause an exception on some OSs or versions of Processing.*/
void setupMouseWheel() {
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
   public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
   state.scale.factor += evt.getWheelRotation();
   }}); 
}


/** Keyboard handler.
  Responds to numerous key commands, as follows. Camera or render settings changes are made directly to the state and will be noticed by the render loop on the next cycle.
     arrow key: pan xy
     SHIFT + arrow key: rotate xy
     page up/down: pan depth
     SHIFT + page up/down: rotate z
     -/+: zoom out/in
     0: reset pan, rotation and zoom
     c: edit colors
     l: edit random sequence length
     r: generate a new random sequence
     CTRL + o: open a state file
     CTRL + s: save the current state to a file
     CTRL + q: write the current state to the default state file
     a: edit the dihedral angle
     A: toggle animation of the dihedral angle
     ENTER, e: edit the sequence
     SPACE: flatten the sequence (temporarily set the dihedral to 0 degress)
     k: edit the sequence repeat count
     n: toggle display of sequence indices
     CTRL + C: render the scene to a high-resolution image file
     CTRL + D: render the scene to a DXF file
     f: toggle display of effects
     w: toggle wireframe rendering
     b: toggle render of blur
     F: edit effects parameters
     */
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
}

/** Key handler.
  Tracks holding and releasing of SPACE, SHIFT and CTRL. */
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

/** Interpolates the displayed dihedral angle, based on the state and elapsed time since the last draw. */
void doDisplayAngleInterpolate() {
  float itrp = ((float) elapsedLastDraw) / interpolationFactorAngle;
  displayAngleDegrees = (displayAngleDegrees*(1-itrp))+((flatten? 0:state.sequenceData.angleDegrees)*itrp);
}

/** Animates the angle between elements, based on the elapsed time.*/
void doAnimateAngle() {
  float itrp = ((float) elapsedLastDraw) / animationFactorAngle;
  displayAngleDegrees = (displayAngleDegrees*(1-itrp))+((displayAngleDegrees+1)*itrp);
  
  if (displayAngleDegrees > 360)
    displayAngleDegrees -= 360;
}

float rx = 0;
float ry = 0;
float rz = 0;
/** Rotates the scene given the mouse position.
  The mouse position is interpolated based on the state and elapsed time since the last draw.*/
void doMouseRotate() {
  //calculate the nominal rotation (adjusting from state units to screen units)
  float rxp = ((state.rotate.x)*0.005);
  float ryp = ((state.rotate.y)*0.005);
  float rzp = ((state.rotate.z)*0.005);

  //the interpolation factor
  float itrp = ((float) elapsedLastDraw) / interpolationFactorMouse;
  
  //interpolate the new display rotation
  rx = (rx*(1-itrp))+(rxp*itrp);
  ry = (ry*(1-itrp))+(ryp*itrp);
  rz = (rz*(1-itrp))+(rzp*itrp);
  
  //and rotate
  rotateZ(rz);
  rotateY(rx);
  rotateX(ry);
}


float panx = 0;
float pany = 0;
float panz = 0;
/** Pans the scene given the mouse position.
  The mouse position is interpolated based on the state and elapsed time since the last draw.*/
void doMousePan() {
  //calculate the nominal pan (adjusting from state units to screen units)
  float panxp = (state.pan.x)*0.02;
  float panyp = (state.pan.y)*0.02;
  float panzp = (state.pan.z)*0.02;

  //the interpolation factor
  float itrp = ((float) elapsedLastDraw) / interpolationFactorMouse;
  
  //interpolate the new display pan
  panx = (panx*(1-itrp))+(panxp*itrp);
  pany = (pany*(1-itrp))+(panyp*itrp);
  panz = (panz*(1-itrp))+(panzp*itrp);

  //pan the transform matrix 
  translate(panx, pany, panz);
}

/** Scales the scene given the mouse position.
  The displayed scale is not interpolated.*/
void doMouseScale() {
  float sceneScale = pow(2, state.scale.factor/12f);
  scale(sceneScale);
}


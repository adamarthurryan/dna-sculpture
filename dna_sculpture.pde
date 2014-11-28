 import processing.opengl.*; 

/**
 * DNA Sculpture
 */

import java.io.*;
import javax.swing.JFileChooser;

/** The program state captures details of camera position, render parameters and target sequence.
  * Identical states produce identically rendered images. */
State state;

/** Program entry point - basic setup */
void setup() {
  //Initialize the window with the maximum possible screen size
  size(displayHeight, displayHeight, P3D); 
  if (frame != null) {
    frame.setResizable(true);
  }

  //initialize the program state
  //the state records all the display and data parameters
  setupState();

  //setup the user interface
  //the ui tracks input and renders output
  setupUI();

  //initialize the shape objects: triangle, square, pentagon, etc.
  setupShapes();

  //initialize the random color generating facility
  //this is no longer used, I think
  setupColors();

  //setup the camera for capturing / rendering to image files
  setupCapture();
  
}

/** Returns true to indicate this sketch can / should run in full screen mode. */
boolean sketchFullScreen() {
  return true;
}


/** Initialize the program state by reading defaults from a configuration file.*/ 
void setupState() {
  try {
    readDefaultState();
  }
  catch (Exception ex) {
    println("Couldn't read default state");
    ex.printStackTrace();
    state = new State();
  }
}
  
/** Select and open a configuration file to set the program state.*/
void readState() {
  JFileChooser chooser = new JFileChooser();
  chooser.setFileFilter(chooser.getAcceptAllFileFilter());
  int returnVal = chooser.showOpenDialog(this);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    state = State.fromXMLFile(this, chooser.getSelectedFile().getPath());
  }
}

/** Save the program state to a configuration file (selected by the user).*/
void writeState() {
  JFileChooser chooser = new JFileChooser();
  chooser.setFileFilter(chooser.getAcceptAllFileFilter());
  int returnVal = chooser.showSaveDialog(this);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    state.toXMLFile(this, chooser.getSelectedFile().getPath());
  }
}

/** Writes the program state to the configuration file "default-state.xml".*/
void writeDefaultState() {
  state.toXMLFile(this, "default-state.xml");
}

/** Reads the program state from the configuration file "default-state.xml".*/
void readDefaultState() {
  state = State.fromXMLFile(this, "default-state.xml");
}

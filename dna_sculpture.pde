 import processing.opengl.*; 

/**
 * DNA Sculpture
 *
 * todo:
 */

import java.io.*;
import javax.swing.JFileChooser;

State state;

void setup() {
  size(displayHeight, displayHeight, P3D); 
  if (frame != null) {
    frame.setResizable(true);
  }

  setupState();
  setupUI();
  setupShapes();

  setupColors();
  setupCapture();
  
}

boolean sketchFullScreen() {
  return true;
}


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
  

void readState() {
  JFileChooser chooser = new JFileChooser();
  chooser.setFileFilter(chooser.getAcceptAllFileFilter());
  int returnVal = chooser.showOpenDialog(this);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    state = State.fromXMLFile(this, chooser.getSelectedFile().getPath());
  }
}
void writeState() {
  JFileChooser chooser = new JFileChooser();
  chooser.setFileFilter(chooser.getAcceptAllFileFilter());
  int returnVal = chooser.showSaveDialog(this);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    state.toXMLFile(this, chooser.getSelectedFile().getPath());
  }
}

void writeDefaultState() {
  state.toXMLFile(this, "default-state.xml");
}

void readDefaultState() {
  state = State.fromXMLFile(this, "default-state.xml");
}

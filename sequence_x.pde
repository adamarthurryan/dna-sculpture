
/** Translates and rotates the matrix so that the given convex shape
    - of which it is assumed that side 0 is on the (0,1) vector, with the shape above the x-axis
    - is rotated such that the given side is on the (0,1) vector, 
    with the shape below the x-axis.*/
void moveToEdge(PShape shape, int edge) {
  int n = shape.getVertexCount();
  if (edge > n)
    throw new RuntimeException("Edge index out of bounds");
   
  PVector va = shape.getVertex((edge+1) % n);
  PVector vb = shape.getVertex(edge);
  PVector vbsubva = PVector.sub(vb,va);
  PVector v0 = new PVector(1,0);
  
  translate(va.x, va.y);
  
  float theta = PVector.angleBetween(v0, vbsubva);
  PVector rotated = vbsubva;
  rotated.rotate(theta);
    
  //how to detect when theta is inverted?
  //if vb-va rotated is not near v0, then try inverting theta
  if (PVector.sub(rotated, v0).magSq() > 0.01)
    theta = 0-theta;
    
  rotate(-theta); 
}

/** Plots the given sequence of shapes and connecting sides. 
    The sequence is interpreted as follows:
      each even element 2n specifies a shape in the shapes array
      each odd element 2n+1 specifies a connecting side between element 2n and 2n+2.
     If the sequence has even length, the last element has no effect. 
     Each shape will be further rotated by the given angle along its shared edge.*/
void plotSequence(PShape [] shapes, int [] sequence, float angle) {
  pushMatrix();
  //restart the random color sequence
  goFirstColor();
 
  for (int k=0;k<state.sequenceData.repeatCount;k++) {
    for (int i=0; i<sequence.length; i+=2) {
      //fill(192,192,255);//random(192, 255),random(192,255),random(192,255));
      
      
      beginShape();
      
      strokeWeight(0);
      color cFill = nextColor();
      fill(cFill, cAlpha);
      
      
      for (int j=0;j<shapes[sequence[i]].getVertexCount();j++) {
        PVector v = shapes[sequence[i]].getVertex(j);
        vertex(v.x, v.y, v.z);
      }
    
      endShape();

      if (plotNumbers || (editMode && i/2 == editIndex)) {
        pushMatrix();
        scale(0.01);
        textSize(50);
        if (editMode && i/2 == editIndex) 
          fill(192,64,64);
        else
          fill(64,64,192);
        text(i/2+1, 30, 50, 0.1);
        text(i/2+1, 30, 50, -0.1);
        popMatrix();
      }
    
    
      if (editMode && hideAfterEditIndex && i/2 == editIndex)
        break;
    
      if (i+1<sequence.length) {
        moveToEdge(shapes[sequence[i]], sequence[i+1]);
        rotateX(angle);
      }
    }
  }
  popMatrix();
}

/** Prints the sequence to the console. */
void printSequence(int [] sequence) {
  println(Sequence.toString(sequence));
}








PShape [] polyShapes;

static {
    Sequence.codeToIndex.put('t', 0);
    Sequence.codeToIndex.put('s', 1);
    Sequence.codeToIndex.put('p', 2);
    Sequence.codeToIndex.put('h', 3);
    
    Sequence.indexToCode.put(0, 't');
    Sequence.indexToCode.put(1, 's');
    Sequence.indexToCode.put(2, 'p');
    Sequence.indexToCode.put(3, 'h');
    
    Sequence.numSides = new int [] {3,4,5,6};
    Sequence.probShapes = new float[] {1,0.7,0.4,0.3};
}

/*
public class Shape extends ArrayList {
  public Shape () {
  }
  public void vertex(float x, float y) {
    PVector vector = new PVector(x,y);
    this.add(vector);
  }
  public PVector getVertex(int i) {
    return (PVector) get(i);
  }
  public int getVertexCount () {
    return size();
  }
}
*/

void plotShape (PShape shape) {
  shape(shape);
}

/** Returns an equalateral triangle. */
PShape calcTriangleShape() {
  float a=sin(PI/3);

  PShape shape = createShape();
  shape.beginShape();
  shape.disableStyle();
  
  shape.vertex(0,  0);
  shape.vertex(1,  0);
  shape.vertex(.5, a);

  shape.endShape();
  
  return shape;
}

/** Returns a square. */
PShape calcSquareShape() {
  PShape shape = createShape();
  shape.beginShape();
  shape.disableStyle();
  
  shape.vertex(0,0);
  shape.vertex(1,0);
  shape.vertex(1,1);
  shape.vertex(0,1);
  shape.endShape();
  
  return shape;
}

/** Returns a regular pentagon. */
PShape calcPentagonShape() {
  float a=cos(2*PI/5);
  float b=sin(2*PI/5);
  float bc=tan(2*PI/5)*0.5;

  PShape shape = createShape();
  shape.beginShape();
  shape.disableStyle();
  
  shape.vertex(0,    0);
  shape.vertex(1,    0);
  shape.vertex(1+a,  b);
  shape.vertex(0.5,  bc);
  shape.vertex(-a,   b);
  shape.endShape();
  
  return shape;
}

/** Returns a regular hexagon. */
PShape calcHexagonShape() {
  float a=sin(PI/3);

  PShape shape = createShape();
  shape.beginShape();
  shape.disableStyle();
  
  shape.vertex(0,    0);
  shape.vertex(1,    0);
  shape.vertex(1.5,  a);
  shape.vertex(1,    2*a);
  shape.vertex(0,    2*a);
  shape.vertex(-0.5, a);
  shape.endShape();
    
  return shape;
}

/** Convenience methods for the regular polygon shapes.*/
PShape triangle, square, pentagon, hexagon;

/** Sets up shapes for the regular polygons.*/
void setupShapes () {
    polyShapes = new PShape[4];
    polyShapes[0] = calcTriangleShape();
    polyShapes[1] = calcSquareShape();
    polyShapes[2] = calcPentagonShape();
    polyShapes[3] = calcHexagonShape();
    
    triangle=polyShapes[0];
    square=polyShapes[1];
    pentagon=polyShapes[2];
    hexagon=polyShapes[3];
    
}


import java.util.*;

/** Methods for manipulating sequences of shapes and connected edges.
  Also has methods for parsing a sequence from a string, 
  encoding a sequence as a string, and generating random sequences.
  
  Sequences are represented as int arrays - this is kind of janky.*/
public class Sequence {

  /** Maps indexes of shapes to letter codes.*/
  public static HashMap codeToIndex = new HashMap();
  /** Maps letter codes to indexes of shapes.*/
  public static HashMap indexToCode = new HashMap();
  public static int [] numSides;
  
  /** Shapes for each of the regular polygons.*/ 
  public static float [] probShapes;
 
  /** Renders the sequence as a string of letters (shapes) and numbers (connecting edges).*/
  public static String toString(int [] sequence) {
    //a buffer for the string
    StringBuffer buffer=new StringBuffer();
    //for each shape in the sequence
    for (int i=0;i<sequence.length;i+=2) {
      //add its letter code 
      buffer.append(Sequence.indexToCode.get(sequence[i]));
      //and if its not the last, add the edge connection to the next shape
      if (i+1<sequence.length) {
        buffer.append(sequence[i+1]);
      }
    }
    return buffer.toString();
  }

  /** Parses the given string of letters (shapes) and numbers (connecting edges) into a sequence.*/
  public static int [] parse(String string) {
    //ignore dashes, spaces and commas
    string = string.replaceAll("-", "");
    string = string.replaceAll(" ", "");
    string = string.replaceAll(",", "");
    
    //create a new sequence  
    int [] sequence = new int[string.length()];
    
    // for each even-indexed letter in the string
    for (int i=0;i<string.length();i+=2) {
      //look up the shape that is represented by that letter and add it to the sequence
      char code = string.charAt(i);
      sequence[i] = ((Integer) (Sequence.codeToIndex.get(code))).intValue();
      
      //and add the connecting edge to the sequence
      if (i+1 < string.length()) {
        sequence[i+1] = Integer.parseInt(string.substring(i+1,i+2));
      }
    }
    return sequence;
  }
  
  /** Returns a random sequence with the given seed and number of shapes.*/
  public static int [] calcRandomSequence(int seed, int n) {
    Random random=new Random(seed);
    
    //make a new sequence
    int [] sequence = new int[n*2-1];
    //for each shape in the sequence
    for (int i=0; i<sequence.length; i+=2) {
      //choose a shape
      sequence[i] = chooseRandomShape(random);
      //and choose a connecting edge
      if (i+1<sequence.length)
        sequence[i+1] = random.nextInt(Sequence.numSides[sequence[i]]-1)+1;
        
    }
    
    return sequence;
  }


/** Returns a random shape given the probability distribution in probShapes.*/
  public static int chooseRandomShape(Random random) {
    float probSum = 0;

    //figure out the total weighted probabilty
    for (int i=0;i<Sequence.probShapes.length;i++)
      probSum += Sequence.probShapes[i];
     
    //get a random number
    float s = random.nextFloat()*probSum;

    //assign the random number to a shape
    for (int i=0;i<Sequence.probShapes.length;i++) {
      s-=probShapes[i]; 
      if (s<=0)
        return i;
    }
    
    //should never happen!
    return Sequence.probShapes.length-1;
  }
}

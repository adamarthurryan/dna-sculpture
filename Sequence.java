import java.util.*;

public class Sequence {
  public static HashMap codeToIndex = new HashMap();
  public static HashMap indexToCode = new HashMap();
  public static int [] numSides;
  
  /** Shapes for each of the regular pentagons.*/ 
  public static float [] probShapes;
 
  public static String toString(int [] sequence) {
    StringBuffer buffer=new StringBuffer();
    for (int i=0;i<sequence.length;i+=2) {
      buffer.append(Sequence.indexToCode.get(sequence[i]));
      if (i+1<sequence.length) {
        //buffer.append("-"+sequence[i+1]);
        buffer.append(sequence[i+1]);
        //if (i+2<sequence.length)
          //buffer.append("-");
      }
    }
    return buffer.toString();
  }

  public static int [] parse(String string) {
    //ignore dashes, spaces and commas
    string = string.replaceAll("-", "");
    string = string.replaceAll(" ", "");
    string = string.replaceAll(",", "");
    
    int [] sequence = new int[string.length()];
    
    for (int i=0;i<string.length();i+=2) {
      char code = string.charAt(i);
      sequence[i] = ((Integer) (Sequence.codeToIndex.get(code))).intValue();
      
      if (i+1 < string.length()) {
        sequence[i+1] = Integer.parseInt(string.substring(i+1,i+2));
      }
    }
    return sequence;
  }
  
  /** Returns a random sequence with the given number of shapes. The shapes are drawn from the given array.*/
  public static int [] calcRandomSequence(int seed, int n) {
    Random random=new Random(seed);
    
    int [] sequence = new int[n*2-1];
    for (int i=0; i<sequence.length; i+=2) {
      sequence[i] = chooseRandomShape(random);
      if (i+1<sequence.length)
        sequence[i+1] = random.nextInt(Sequence.numSides[sequence[i]]-1)+1;
        
    }
    
    //reset the random seed to the system clock
    
    return sequence;
  }


/** Returns a random shape given the probability distribution in probShapes.*/
  public static int chooseRandomShape(Random random) {
    float probSum = 0;
    for (int i=0;i<Sequence.probShapes.length;i++)
      probSum += Sequence.probShapes[i];
     
    float s = random.nextFloat()*probSum;
    for (int i=0;i<Sequence.probShapes.length;i++) {
      s-=probShapes[i]; 
      if (s<=0)
        return i;
    }
    //should never happen!
    return Sequence.probShapes.length-1;
  }
}

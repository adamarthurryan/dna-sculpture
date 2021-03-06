import processing.core.*;
import java.io.File;
import java.util.*;
import javax.xml.bind.*;
import javax.xml.bind.annotation.*;
 
/** The program state captures details of camera position, render parameters and target sequence.
  Identical states produce identically rendered images. 

  The State class is able to act as an XML root element. 
  This is enabled with the @XMLRootElement annotation.
  The name parameter is only needed since
  our XML element name is different from the class name:
  <state> vs. State */
@XmlRootElement(name="view") public class State {
    
  // Some general JAXB guidance:
    // now we simply annotate the different variables
    // depending if they are XML elements/nodes or node attributes
    // the mapping to the actual data type is done automatically
    //    @XmlAttribute(name="timestamp") long timestamp;
      
    // one of the best things in JAXB is the ability to map entire
    // class hierarchies and collections of data
    // in this case each <url> element will be added to this list
    // the actual MyURL class is defined in its own tab in the Processing PDE
    //    @XmlElement(name="url") List<MyURL> urls=new ArrayList<MyURL>();
    
  public State() {} 
  
  /** Parameters for the fog effects.*/
  static class Fog {
    @XmlAttribute float offset = 0.0f; 
    @XmlAttribute float scale = 1.0f; 
  }
  
  /** The x, y, and z position (translation or pan) of the camera.*/
  static class Point3 {
    @XmlAttribute float x = 0;
    @XmlAttribute float y = 0;
    @XmlAttribute float z = 0;
  }
  
  /** The data of the current sequence. Presently only saves random sequences, not user input sequences*/
  static class SequenceData {
    //each of these sequence parameters maps to a xml attribute
    @XmlAttribute(name="repeat") int repeatCount = 1;
    @XmlAttribute(name="angle") float angleDegrees = 30;
    @XmlAttribute(name="seed") int seed = 0;
    @XmlAttribute(name="length") int lengthRandom = 1;
 
 
 //   int [] sequence = new int[] {0};
    Sequence sequence = Sequence.EMPTY_SEQUENCE;
  }
  
  /** The camera zoom / scene scale.*/
  static class Scale {
    @XmlAttribute float factor = 1f;
  }
  
  /** The various render colors: background, light and shadow.*/
  static class Color {
    int background;
    int light;
    int shadow;
    @XmlAttribute(name="background") String strBackground ="ffffff";
    @XmlAttribute(name="shadow") String strShadow ="efefef";
    @XmlAttribute(name="light") String strLight ="101010";
  }
  
  // each of the state inner classes map to an xml element 
  @XmlElement(name="sequence") SequenceData sequenceData = new SequenceData();
  @XmlElement(name="rotation") Point3 rotate = new Point3();
  @XmlElement(name="center") Point3 pan = new Point3();
  @XmlElement Scale scale = new Scale();
  @XmlElement Fog fog = new Fog();
  @XmlElement(name="color") Color colorData = new Color();
    
    
  
  /** Returns a State object for the given xml file path.*/
  public static State fromXMLFile(PApplet papplet, String path) {
    State state = new State();
    
    // the following 2 lines of code will load the config.xml file and map its contents
    // to the nested object hierarchy defined in the AppConfig class (see below)
    try {
      // setup object mapper using the AppConfig class
      JAXBContext context = JAXBContext.newInstance(State.class);
      // parse the XML and return an instance of the AppConfig class
      state = (State) context.createUnmarshaller().unmarshal(papplet.createInput(path));
    } catch(JAXBException e) {
      // if things went wrong...
      papplet.println("error parsing xml: ");
      e.printStackTrace();
      throw new RuntimeException("error parsing state xml");
    }
    
    //this is probably not the best JAXB way to do this, but whatever...
    state.colorData.background = Integer.parseInt(state.colorData.strBackground, 16);
    state.colorData.light = Integer.parseInt(state.colorData.strLight, 16);
    state.colorData.shadow = Integer.parseInt(state.colorData.strShadow, 16);

    state.sequenceData.sequence = Sequence.calcRandomSequence(state.sequenceData.seed, state.sequenceData.lengthRandom);
    return state;
  }
  
  /** Outputs the State object to the given xml file path.*/
  public void toXMLFile (PApplet papplet, String path) {
    
    this.colorData.strBackground = Integer.toHexString(this.colorData.background);
    this.colorData.strLight = Integer.toHexString(this.colorData.light);
    this.colorData.strShadow = Integer.toHexString(this.colorData.shadow);


    try {
      JAXBContext jc = JAXBContext.newInstance( State.class );
      Marshaller m = jc.createMarshaller();
      
      //set this property to true to omit the xml boilerplate
      //m.setProperty(Marshaller.JAXB_FRAGMENT, Boolean.TRUE);
      
      //set this property to true to pretty print the xml
      m.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);
      m.marshal(this, papplet.createOutput(path) );
    } catch( JAXBException e ){
      System.out.println("error writing xml: ");
      e.printStackTrace();
    }

  }
}

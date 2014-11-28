import processing.core.*;
import java.io.File;
import java.util.*;
import javax.xml.bind.*;
import javax.xml.bind.annotation.*;
 
/** The State class is able to act as
 an XML root element. This is enabled with the @XMLRootElement annotation.
The name parameter is only needed since
 our XML element name is different from the class name:
 <config> vs. Configuration */
@XmlRootElement(name="config")
  public class Configuration {
    
  public Configuration() {} 
    

  // now we simply annotate the different variables
  // depending if they are XML elements/nodes or node attributes
  // the mapping to the actual data type is done automatically
  @XmlAttribute(name="version")
    float versionID;
    
  
  // one of the best things in JAXB is the ability to map entire
  // class hierarchies and collections of data
  // in this case each <url> element will be added to this list
  // the actual MyURL class is defined in its own tab in the Processing PDE
  //@XmlElement(name="url")
  //  List<MyURL> urls=new ArrayList<MyURL>();
    
    
  
  /** Returns a Configuration object for the given xml file path.*/
  public static Configuration fromXMLFile(PApplet papplet, String path) {
    Configuration config = new Configuration();
    
    // the following 2 lines of code will load the config.xml file and map its contents
    // to the nested object hierarchy defined in the AppConfig class (see below)
    try {
      // setup object mapper using the AppConfig class
      JAXBContext context = JAXBContext.newInstance(Configuration.class);
      // parse the XML and return an instance of the AppConfig class
      config = (Configuration) context.createUnmarshaller().unmarshal(papplet.createInput(path));
    } catch(JAXBException e) {
      // if things went wrong...
      papplet.println("error parsing xml: ");
      e.printStackTrace();
      throw new RuntimeException("error parsing config xml");
    }
    
    return config;
  }
  
  /** Outputs the Configuration object to the given xml file path.*/
  public void toXMLFile (PApplet papplet, String path) {
    
    try {
      //create an instance of teh JAXBContext for the Configuration class
      JAXBContext jc = JAXBContext.newInstance(Configuration.class );

      //create a marshaller for this context
      Marshaller m = jc.createMarshaller();

      //create the xml  for this marshaller
      //the xml is written to an output stream initialized to the given path
      m.marshal(this, papplet.createOutput(path) );
      
    } catch( JAXBException e ){
      System.out.println("error writing xml: ");
      e.printStackTrace();
    }

  }
}


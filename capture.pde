/** Set the initial field of view.
  At 39.5 degrees this should be something like a 50mm lens - no fisheye effect. */ 
float FOV = 39.5;

/** The camera depth.*/  
float cameraZ;

/** The number of window-sized tiles that will be stitched together to make the captured image
int NUM_TILES = 3;


import java.util.*;

//this must be called once on program setup
void setupCapture() {
  cameraZ = (height/2.0) / tan(PI * FOV / 360.0); 
}

/** Ensures that the capture view and live render view are the same.
  This must be called before rendering by draw.*/ 
void initializeCaptureCamera() {
  camera(width/2.0, height/2.0, cameraZ, width/2.0, height/2.0, 0, 0, 1, 0); 
  frustum(-width/2, width/2, -height/2, height/2, cameraZ, 100000); 
}


/** Capture a higher-res version of the current scene.
  Simply increases the number of tiles set in the NUM_TILES parameter.*/
void captureSceneHiRes() {
  NUM_TILES=6;
  captureScene();
  NUM_TILES=3;
}



/** Captures the scene and renders it to a high-res images.
 It expects that there is a renderScene() function defined elsewhere, to do the scene rendering.
 Image capture is basically done by zooming in the camera and then moving it along a virtual camera rack.
 Instead of a single zoomed-out image, we have a number of zoomed-in images that stitch seamlessly together.

 The image will be saved with the filename "capture-<timestamp>.tga" and the state will be saved with the extension ".xml".*/
void captureScene() {
  //create a tiemstamp for the filename
  Date d = new Date();
  long current = d.getTime()/1000;

  //the capture filename is simply "capture-<timestamp>.tga"
  String filename = "capture-"+current;
  
  //indices to the current image component cell
  int x=0,y=0,index=0;

  //and cell dimensions
  float left,right,bottom,top;
  
  //create a new image to record the scene
  PImage img = createImage(width*NUM_TILES,height*NUM_TILES,RGB); 

  //for each row and column of hte composite image
  for (y = 0; y < NUM_TILES;y++) {
    for (x = 0; x < NUM_TILES;x++) {
  
      //a little status to the command line
      println("rendering "+x+"-" + y+"...");

      //calculate the dimensions of the current cell
      int invY=NUM_TILES-y-1;
      left = (float)(-width/2) + (float)x*width/NUM_TILES;
      right = (float)(-width/2) + (float)((x+1)*width)/NUM_TILES;
      bottom = (float)(-height/2) + (float)(invY*height)/NUM_TILES;
      top = (float)(-height/2) + (float)((invY+1)*height)/NUM_TILES;
 
      //update the camera so the current cell fills the view
      //(and will stitch with all the other cells)
      camera(width/2.0, height/2.0, cameraZ, width/2.0, height/2.0, 0, 0, 1, 0);    
      frustum(left, right, bottom, top, cameraZ, 100000);

      // call the rendering function (with its own transformation matrix)
      pushMatrix();
      renderScene();
      popMatrix();

      //load the pixels of the render into memory (the pixels array)
      loadPixels();
 
      // After rendering each tile,  
      // we read the framebuffer contents into our bitmap.
      for (int i=0; i < height;i++) {
     
        //Shift to the correct scanline
        index = (((y)*height)*(width*NUM_TILES) + (width*x) + i*(width*NUM_TILES));

        // Read a line from the framebuffer and copy it to the image file
        for(int j=0; j < width;j++) {
          img.pixels[index+j] = pixels[i*width+j];
        }
      }
    }
  }

  //save the xml file with the state 
  state.toXMLFile(this, filename+".xml");

  //save the image
  img.save(filename+".tga");
  println("render saved");
}

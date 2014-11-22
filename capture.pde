// Set the initial field of view
  // at 39.5 degrees this should be something like a 50mm lens - no fisheye effect
float FOV = 39.5;  
float cameraZ;
int NUM_TILES = 3;


import java.util.*;

//this must be called once on program setup
void setupCapture() {
  cameraZ = (height/2.0) / tan(PI * FOV / 360.0); 
}

//this must be called before rendering by draw - it will ensure that the capture view and live render view are the same
void initializeCaptureCamera() {
  camera(width/2.0, height/2.0, cameraZ, width/2.0, height/2.0, 0, 0, 1, 0); 
  frustum(-width/2, width/2, -height/2, height/2, cameraZ, 100000); 
}


void captureSceneHiRes() {
  NUM_TILES=6;
  captureScene();
  NUM_TILES=3;
}



//this function will capture the scene
//it expects that there is a renderScene() function defined elsewhere, to do the scene rendering
void captureScene() {
  Date d = new Date();
  long current = d.getTime()/1000;
  
  String filename = "capture-"+current;
  
  int x=0,y=0,index=0;
  float left,right,bottom,top;
  PImage img = createImage(width*NUM_TILES,height*NUM_TILES,RGB); 

  for (y = 0; y < NUM_TILES;y++) {
    for (x = 0; x < NUM_TILES;x++) {
  
      println("rendering "+x+"-" + y+"...");

      int invY=NUM_TILES-y-1;
      left = (float)(-width/2) + (float)x*width/NUM_TILES;
      right = (float)(-width/2) + (float)((x+1)*width)/NUM_TILES;
      bottom = (float)(-height/2) + (float)(invY*height)/NUM_TILES;
      top = (float)(-height/2) + (float)((invY+1)*height)/NUM_TILES;
 
   
      camera(width/2.0, height/2.0, cameraZ, width/2.0, height/2.0, 0, 0, 1, 0);    
      frustum(left, right, bottom, top, cameraZ, 100000);

      // Call the rendering function
      pushMatrix();
      renderScene();
      popMatrix();
      loadPixels();
 
      // After rendering each tile,  
      // we read the framebuffer contents into our bitmap.
 
      for (int i=0; i < height;i++) {
     
        //Shift to the correct scanline
        index = (((y)*height)*(width*NUM_TILES) + (width*x) + i*(width*NUM_TILES));

        // Read a line from the framebuffer
        for(int j=0; j < width;j++) {
          img.pixels[index+j] = pixels[i*width+j];
        }
      }
    }
  }

  state.toXMLFile(this, filename+".xml");
  img.save(filename+".tga");
  println("render saved");
}

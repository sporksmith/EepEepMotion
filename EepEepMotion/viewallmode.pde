/*
class ViewAllMode extends Mode {
  void enterMode() {
    cam = new PeasyCam(applet, width/2, height/2, 0, 625);
    cam.setMinimumDistance(1);
    cam.setMaximumDistance(40000); 
  }
  void leaveMode() {
  }  
  void draw() {
    perspective();
    background(0);
    lights();
    stroke(204, 102, 0);
    line(0, 0, 0, width, 0, 0); // x axis
    line(0, 0, 0, 0, height, 0); // y axis
    sphereDetail(6);
    fill(128, 128, 128);
    stroke(0);
    Iterator i = mps.iterator();

    while (i.hasNext()) {
     
      MonkeyPic mp = (MonkeyPic)i.next();
      float xfactor = maxx / float(mp.width);
      float yfactor = maxy / float(mp.height); 
      float scale_factor = min(xfactor,  yfactor);
      Monkey m = mp.monkey;
      pushMatrix();
      float monkey_scale_factor = m.size*scale_factor/100.0;
      float mx = ((m.x*scale_factor)-width/2)/monkey_scale_factor + width/2;
      float my = ((m.y*scale_factor)-height/2)/monkey_scale_factor + height/2;
      float z = 625.0 - 625.0/monkey_scale_factor;
//      print("m.size: " + m.size + " scale factor:" + scale_factor + " z: " + z + "\n");
      translate(mx, my, z);
//      translate(m.x*scale_factor, m.y*scale_factor, z);
      int realsize = m.size;
      m.size = 10;
   //   m.draw();
      m.size = realsize;
      box(10);
      popMatrix();      
      //m.draw();
 //     print("drawing at " + m.x + ", " + m.y + "\n");
    }
    
//    print("camera z: " + cam.getPosition()[2] + "\n");
//    m.move_to();
//    m.draw();  
  }
  void keyPressed() {
  }
  void keyReleased() {
  }
 
}
*/

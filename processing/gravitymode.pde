/* this was an early attempt at a procedural animation. Each monkey from each photo is plotted into three-dimensional space,
 * and Mr. Monkey is gravitationally attracted to the unused photos. The idea was to create an animation where Mr. Monkey
 * wanders around semi-randomly, but tends to gravitate to areas of the screen where there are still a lot of unused pictures
 * that would make good matches.
 * In practice, it doesn't work so well. But, maybe it could with some tweaking.
 */

class GravityMode extends Mode {
  HashMap mps3d;
  MonkeyPic3d mp3d;
  PVector velocity = new PVector(0, 0, 0);
  MovieMaker mm;
  
  void enterMode() {
    // make a set of all unused monkeypics
    loop();
    frameRate(target_rate);
    this.mps3d = new HashMap();
    for(Iterator i = mps.iterator(); i.hasNext();) {
      MonkeyPic mp = (MonkeyPic)i.next();
      mps3d.put(mp.filename, new MonkeyPic3d(mp));
    }
    m.x = width/4;
    m.size = 60;
    this.mp3d = new MonkeyPic3d(m);
    
    // set movie file
    /*
    JFileChooser chooser;
    if (mps.dir != null) {
      chooser = new JFileChooser(mps.dir);
    } else {
      chooser = new JFileChooser();
    }
    chooser.setFileFilter(chooser.getAcceptAllFileFilter());
    int returnVal = chooser.showSaveDialog(null); 
    if (returnVal == JFileChooser.APPROVE_OPTION) { 
    */ 
    File moviefile;
    String filename = selectOutput("Select movie file to save");
    if (filename != null) {    
      moviefile = new File(filename);
      mm = new MovieMaker(applet, maxx, maxy, moviefile.getPath(),
                  target_rate, MovieMaker.ANIMATION, MovieMaker.BEST);
    }
    
  }
  void leaveMode() {
    // delete set of unused monkeypics
    
    //noLoop();
  }    
  void draw() {
    background(0);
    if (this.mps3d == null) {
      print ("null mps3d\n");
      return;
    }
    
    if(mps3d.size() <= 0) {
      println("done");
      mm.finish();
      noLoop();
      return;
    }

    perspective();
    lights();
    fill(128);
    stroke(128);

    // monkey is gravitationally attracted to unused monkey heads
    PVector force = new PVector(0, 0, 0);
    Iterator i = mps3d.values().iterator();
    while(i.hasNext()) {
      MonkeyPic3d other = (MonkeyPic3d)i.next();
      PVector this_force = mp3d.forceTo(other);
      force.add(this_force);
//      pushMatrix();
//      translate(other.x, other.y, other.z);
//      box(10);
//      popMatrix();
    }

    /* constant magnitude vforce */
    force.normalize();
    force.mult(10);
    
    // fix or cap magnitude of velocity?
    PVector acceleration = force;
    this.velocity.add(acceleration);
    if(velocity.mag() > 50) { // max v of 20
      velocity.normalize();
      velocity.mult(50);
    }

    mp3d.x += velocity.x;
    mp3d.y += velocity.y;
    mp3d.z += velocity.z;
    
    // rotate to align z axis to velocity
    
    PVector perpin = velocity.cross(mp3d.z_axis);
    perpin.normalize();
    float angle = -PVector.angleBetween(velocity, mp3d.z_axis);
    // FIXME: might have to flip sign of angle?
    mp3d.x_axis = rotatePointAroundVector(mp3d.x_axis, perpin, angle);
    mp3d.x_axis.normalize();
    mp3d.y_axis = rotatePointAroundVector(mp3d.y_axis, perpin, angle);
    mp3d.y_axis.normalize();
    mp3d.z_axis = rotatePointAroundVector(mp3d.z_axis, perpin, angle);
    mp3d.z_axis.normalize();
    print("should be zero: " + PVector.angleBetween(velocity, mp3d.z_axis) + "\n");
   
    // rotate abt monkey's z axis to keep him pointed up
    float inc = radians(5);
    float do_rot_z = 0;
    if (rotatePointAroundVector(mp3d.y_axis, mp3d.z_axis, inc).y > mp3d.y_axis.y) {
      do_rot_z = inc;
    } else if (rotatePointAroundVector(mp3d.y_axis, mp3d.z_axis, -inc).y > mp3d.y_axis.y) {
      do_rot_z = -inc;
    }
    if (do_rot_z != 0) {
      mp3d.x_axis = rotatePointAroundVector(mp3d.x_axis, mp3d.z_axis, do_rot_z);
      mp3d.x_axis.normalize();
      mp3d.y_axis = rotatePointAroundVector(mp3d.y_axis, mp3d.z_axis, do_rot_z);
      mp3d.y_axis.normalize();
      println("rotated abt z " + do_rot_z);
    }
    
    
    print("from " + monkey_to_string(m));
    m = mp3d.toMonkey();
    print(" to " + monkey_to_string(m) + "\n");
    println("3dm is at " + mp3d.x + " " + mp3d.y + " " + mp3d.z);

    // check whether we've wandered out of frame
    if (m.x < 0) {
      m.x = 0;
      velocity.x = 0;
    }
    if (m.x > width) {
      m.x = width;
      velocity.x = 0;
    }
    if (m.y < 0) {
      m.y = 0;
      velocity.y = 0;
    }
    if (m.y > height) {
      m.y = height;
      velocity.y = 0;
    }
    if (m.size > 300) {
      m.size = 300;
      velocity.z = 0;
    }
    if (m.size < 20) {
      m.size = 20;
      velocity.z = 0;
    }
    this.mp3d = new MonkeyPic3d(m);


    // match to picture
    mps.set_best_match();
    
    // meet picture half-way for rot abt z
    /*
    mp3d.x_axis = rotatePointAroundVector(mp3d.x_axis, new PVector(0, 0, 1), -mp.rz);
    mp3d.x_axis.normalize();
    mp3d.y_axis = rotatePointAroundVector(mp3d.y_axis, new PVector(0, 0, 1), -mp.rz);
    mp3d.y_axis.normalize();
    */
    
    // remove this monkeypic 
    this.mps3d.remove(mp.filename);
    mps.mps_hm.remove(mp.filename);

    // draw
    
    ortho(-width/2, width/2, -height/2, height/2, -10, 10);

    if(mp != null) {
      mp.draw();
    }
    mm.addFrame();
    mm.addFrame();
    mm.addFrame();
    m.move_to();
    m.draw();
  }
  void keyPressed() {
    redraw();
  }
  void keyReleased() {
  }
 
}

class MonkeyPic3d {
  float x, y, z;
  PVector x_axis, y_axis, z_axis;
  MonkeyPic mp;
  
  float scale_factor;
  
  MonkeyPic3d(MonkeyPic mp) {
    this.mp = mp;
    Monkey m = new Monkey(mp.monkey);
    float xfactor = maxx / float(mp.width);
    float yfactor = maxy / float(mp.height); 
    this.scale_factor = min(xfactor,  yfactor);
    float monkey_scale_factor = m.size*scale_factor/100.0;
    
    // center it
    m.x += (width - mp.width*scale_factor)/2.0;
    m.y += (height - mp.height*scale_factor)/2.0;
    
    this.x = ((m.x*scale_factor)-width/2)/monkey_scale_factor + width/2;
    this.y = ((m.y*scale_factor)-height/2)/monkey_scale_factor + height/2;
    this.z = 625.0 - 625.0/monkey_scale_factor;
    this.x_axis = m.x_axis.get();
    this.y_axis = m.y_axis.get();
    this.z_axis = m.z_axis.get();
  }
  MonkeyPic3d(Monkey m) {
    float monkey_scale_factor = m.size/100.0;
    this.scale_factor = 1;
    
    this.x = ((m.x*scale_factor)-width/2)/monkey_scale_factor + width/2;
    this.y = ((m.y*scale_factor)-height/2)/monkey_scale_factor + height/2;
    this.z = 625.0 - 625.0/monkey_scale_factor;
    this.x_axis = m.x_axis.get();
    this.y_axis = m.y_axis.get();
    this.z_axis = m.z_axis.get();  
  }
  Monkey toMonkey() {
    Monkey m = new Monkey();

    float monkey_scale_factor = 625.0/(625.0-this.z);
    m.size = (int)(100*monkey_scale_factor);    
    m.x = int(((this.x - width/2)*monkey_scale_factor + width/2) / scale_factor);
    m.y = int(((this.y - height/2)*monkey_scale_factor + height/2) / scale_factor);
    m.x_axis = this.x_axis.get();
    m.y_axis = this.y_axis.get();
    m.z_axis = this.z_axis.get();
    return m;
  }
  
  
  PVector forceTo(MonkeyPic3d mp3d) {
    float G = 1000.0;
    PVector rv = new PVector(0, 0, 0);
    rv.x = mp3d.x - this.x;
    rv.y = mp3d.y - this.y;
    rv.z = mp3d.z - this.z;
    rv.normalize();

    float m = 1.0; 
 /*   
    if (dist(mp3d.x, mp3d.y, mp3d.z, this.x, this.y, this.z) < 1.0) {
      m = G;
    } else {
      m = G / sq(dist(mp3d.x, mp3d.y, mp3d.z, this.x, this.y, this.z));
    }
    */
    
    // scale the whole thing by alignment;
    // more attracted to aligned heads.
    /*
    m *= this.x_axis.dot(mp3d.x_axis);
    m *= this.y_axis.dot(mp3d.y_axis);
    m *= this.z_axis.dot(mp3d.z_axis);
    */
    
    // more attracted to where we're already facing
//    println(this.z_axis.dot(rv));
//    m *= this.z_axis.dot(rv);
    
//    print("force: " + rv);                         
    rv.mult(abs(m));
//    print(" -> " + rv + "\n");
    return rv;
  }
}

import java.util.StringTokenizer;

class KeyFrameKeeper {
  
  HashMap dq_schedule = new HashMap(); // schedule of when to dq which images
  HashMap deadzone = new HashMap(); // using it as a set. set of frames where we won't render
  int hold_frames;
  int dq_frames;

  KeyFrameKeeper(int hold_frames, int dq_frames) {
    this.hold_frames = hold_frames;
    this.dq_frames = dq_frames;
  }
 
  void put(int frame, String filename) {
    filename = eepEepConfig.getPicturesPath() + filename;
    
    //technically should be using a multiset here.
    //clunky workaround...
    int sched_frame = max(2, frame-this.dq_frames);
    while(this.dq_schedule.containsKey(sched_frame)) {
      sched_frame++;
    }      
    dq_schedule.put(sched_frame, filename);
    
    for(int i=frame; i<frame+this.hold_frames; i++) {
      deadzone.put(i, i);
    }
  }
  
  void add_deadzone(int start, int end) {
    for(int i=start; i<= end; i++) {
      deadzone.put(i, i);
    }
  }
  
  boolean in_deadzone(int cur_frame) {
    return deadzone.containsKey(cur_frame);
  }
  
  void disqualify_pic(String filename, int until_frame) {
      MonkeyPic mp = (MonkeyPic)mps.mps_hm.get(filename); 
      
      if(mp == null) {
        println("cant find file to dq: " + filename);
      }
      
      // if we get a null ref here, perhaps mis-entered filename?
      mp.disqualify_until_frame = until_frame;    
  }
  
  void do_disqualify(int cur_frame) {
    if (dq_schedule.containsKey(cur_frame)) {
      String dq_name = (String)dq_schedule.get(cur_frame);
      this.disqualify_pic(dq_name, cur_frame + hold_frames + 2*this.dq_frames);
    }    
  }
   
}

class RenderFromFramesMode extends Mode{
  int hold_frames = 7; // how long each key frame is frozen
  KeyFrameKeeper key_frames = new KeyFrameKeeper(hold_frames, (int)(.5*eepEepConfig.getTargetRate()));
  int frame=0;
  int start_frame=-1;
  ArrayList monkey_frames = new ArrayList(); 
  
  void draw() { // ugh. have to return from draw to actually draw anything. makes following code to preview while rendering a bit awkward.
    File out_file;
    File mask_file;
    File imask_file;
    while(true) {
      // are we out of frames to render?
      if((this.frame-this.start_frame) >= monkey_frames.size()) {
        println("done!\n");
        noLoop();
        return;
      }

      key_frames.do_disqualify(this.frame);
      
      // figure out output filename
      m = (Monkey)monkey_frames.get(this.frame-this.start_frame);
      String filename = "" + this.frame;
      int to_append = 4-filename.length();
      for(int i=0; i<to_append; i++) {
        filename = "0" + filename;
      }
      out_file = new File(eepEepConfig.getFramesOutputPath() + filename + ".jpg");
      mask_file = new File(eepEepConfig.getFramesOutputPath() + "m" + filename + ".jpg");
      imask_file = new File(eepEepConfig.getFramesOutputPath() + "im" + filename + ".jpg");
      
      if(!out_file.exists()) {
        break;
      } else {
        this.frame++;
      }
    }

    ortho(-width/2, width/2, -height/2, height/2, -10, 10);

    // create and save mask based on monkey
    pushMatrix();
    background(0xffffffff);
    m.move_to();
    m.draw_color(0xff000000, 0xff000000);
    saveFrame(mask_file.getPath());
    popMatrix();
    
    
    // create and save green/white mask based on monkey
    pushMatrix();
    background(0xff00ff00);
    m.move_to();
    m.draw_color(0xff000000, 0xff000000);
    saveFrame(imask_file.getPath());
    popMatrix();

    // draw
    background(0);

    // get matching monkeypic
    // unless we're in a deadzone (covered by a keyframe)    
    if(!key_frames.in_deadzone(this.frame)) {
      mps.set_best_match(this.frame); 
      
      // blargh. need to fetch the original mp object in case we're using a flipped copy
      //mp.disqualify_until_frame = frame + (int)(eepEepConfig.getTargetRate()*5); 
      ((MonkeyPic)(mps.mps_hm.get(mp.filename))).disqualify_until_frame = frame + (int)(eepEepConfig.getTargetRate()*0.5);
      
      mp.draw();
    }
    saveFrame(out_file.getPath());
        
    // draw monkey for debugging
    lights();
    m.move_to();
    m.draw();
    
    
    this.frame++;
  }
  void keyPressed() {
  }
  void keyReleased() {
  }
  
  void enterMode() {
   
    // choose file from which to read frame info
    readFrames();
    
    if(true) {
      // hard coded key frame info.
      // ideally this would be in an input file,
      // but I can't be buggered.
      key_frames.put(26, "Pittsburgh/IMG_4210.JPG"); //coffee
      key_frames.put(55, "Laconia, New Hampshire/Code Monkey 001.jpg"); //job
      key_frames.put(103, "Washington DC area #2 (Gina)/P1010036.JPG"); //meeting
      key_frames.put(126, "Oregon/SUC50028.JPG"); //rob
      key_frames.put(174, "Lawton, Oklahoma/Code Monkey06 MGP Lawton Ok.JPG"); //diligent
      key_frames.put(197, "Dallas, TX/CIMG2043.JPG"); //outputstink
      key_frames.put(246, "Laconia, New Hampshire/Code Monkey 023.jpg"); // elegant
      key_frames.put(269, "Pittsburgh/IMG_4262.JPG"); // think
      key_frames.put(344, "Pittsburgh/IMG_4174.JPG"); // login page himself
      key_frames.put(379, "Los Angeles, Dec 2007/DSC02013.JPG"); // 
      key_frames.put(416, "Washington DC Area #3 (Jinx)/01-sitting.jpg"); // 
      key_frames.put(439, "Los Angeles Area, #2/Munchies.JPG"); // 
      key_frames.put(482, "Dallas, TX/CIMG2027.JPG"); // 
      key_frames.put(513, "Lawton, Oklahoma/Code Monkey63  Meers Lawton Ok.JPG"); // 
      key_frames.put(548, "Wichita, Kansas/IMG_1001.JPG"); // 
      key_frames.put(747, "Dallas, TX/CIMG2037.JPG");
      key_frames.put(771, "Washington DC area #2 (Gina)/P1010313.JPG");
      key_frames.put(816, "Dallas, TX/CIMG2027.JPG");
      //key_frames.put(834, "Lawton, Oklahoma/Code Monkey23 Waynes Drive In Lawton Ok.JPG");
      key_frames.put(845, "Washington DC area #2 (Gina)/P1010096.JPG");
      key_frames.put(896, "Oregon/SUC50025.JPG");
      key_frames.put(916, "Washington DC Area #3 (Jinx)/20-MrHungry.jpg");
      key_frames.put(965, "Lawton, Oklahoma/Code Monkey30 Radio Lawton OK.JPG");
      key_frames.put(987, "San Francisco/IMG_2309.JPG");
      //key_frames.put(1027, "Washington DC area #2 (Gina)/P1010255.JPG");
      key_frames.put(1059, "Springfield, Missouri/CodeMonkey 1.jpg");
      key_frames.put(1096, "Laconia, New Hampshire/Code Monkey 020.jpg");
      key_frames.put(1132, "Scarborough Faire/TrollRhianna.JPG");
      key_frames.put(1563, "Pittsburgh/IMG_4217.JPG"); // out this place
//      key_frames.put(1637, "Scarborough Faire/LadyMary.JPG"); // pretty face
      key_frames.put(1637, "Pittsburgh/IMG_4328.JPG"); // pretty face
      key_frames.put(1684, "Lawton, Oklahoma/Code Monkey32 Cake Lawton Ok.JPG"); // cake
//      key_frames.put(1709, "Lawton, Oklahoma/Code Monkey32 Cake Lawton Ok.JPG"); // nap
      key_frames.put(1709, "Washington DC area #2 (Gina)/P1010272.JPG"); // nap
      key_frames.put(1757, "Pittsburgh/IMG_4320.JPG"); // creative way
      key_frames.put(1778, "Springfield, Missouri/CodeMonkey 6.jpg"); // load of crap
      key_frames.put(1819, "Washington DC area #2 (Gina)/P1010178.JPG"); // have everything
      key_frames.put(1853, "Oregon/SUC50017.JPG"); // pretty girl like you

      // dont render the choruses
      key_frames.add_deadzone(424, 720);
      key_frames.add_deadzone(1140, 1512);
    }

    // these are too dark and jarring (fireworks)
    key_frames.disqualify_pic(eepEepConfig.getPicturesPath() + "Laconia, New Hampshire/Code Monkey 038edited.jpg", 99999);
    key_frames.disqualify_pic(eepEepConfig.getPicturesPath() + "Laconia, New Hampshire/Code Monkey 036.jpg", 99999);
    key_frames.disqualify_pic(eepEepConfig.getPicturesPath() + "Laconia, New Hampshire/Code Monkey 035.jpg", 99999);
    key_frames.disqualify_pic(eepEepConfig.getPicturesPath() + "Laconia, New Hampshire/Code Monkey 034.jpg", 99999);
    
    // too dark, and repeats
    key_frames.disqualify_pic(eepEepConfig.getPicturesPath() + "JoCoPaSto UK Tour/IMG_5842.JPG", 99999);
    key_frames.disqualify_pic(eepEepConfig.getPicturesPath() + "JoCoPaSto UK Tour/IMG_5846.JPG", 99999);
    key_frames.disqualify_pic(eepEepConfig.getPicturesPath() + "JoCoPaSto UK Tour/IMG_5846-1.JPG", 99999);
    key_frames.disqualify_pic(eepEepConfig.getPicturesPath() + "JoCoPaSto UK Tour/IMG_5848.JPG", 99999);
    
    // hidden / out of frame
    key_frames.disqualify_pic(eepEepConfig.getPicturesPath() + "Pittsburgh/IMG_4285.JPG", 99999);
    
    // blurry, dupe
    key_frames.disqualify_pic(eepEepConfig.getPicturesPath() + "Laconia, New Hampshire/Code Monkey 046.jpg", 99999);

    // choose movie file to save
    /*
    JFileChooser chooser;
    if (mps.dir != null) {
      chooser = new JFileChooser(mps.dir);
    } else {
      chooser = new JFileChooser();
    }
    chooser.setFileFilter(chooser.getAcceptAllFileFilter());   
    File moviefile;
    int returnVal = chooser.showSaveDialog(null);
    if (returnVal == JFileChooser.APPROVE_OPTION) {
      moviefile = chooser.getSelectedFile();
      mm = new MovieMaker(applet, maxx, maxy, moviefile.getPath(),
                  eepEepConfig.getTargetRate(), MovieMaker.ANIMATION, MovieMaker.BEST);
    }
    */
    /*
    File moviefile = new File(movie_output_path);
    mm = new MovieMaker(applet, maxx, maxy, moviefile.getPath(),
                  eepEepConfig.getTargetRate(), MovieMaker.ANIMATION, MovieMaker.BEST);
                  */
  }
  void leaveMode() {
  }
  
  // read from frames file, populate monkey_frames
  void readFrames() {
    /*
    JFileChooser chooser;
    if (mps.dir != null) {
      chooser = new JFileChooser(mps.dir);
    } else {
      chooser = new JFileChooser();
    }
    chooser.setFileFilter(chooser.getAcceptAllFileFilter());   
    File framesfile = null;
    int returnVal = chooser.showOpenDialog(null);
    if (returnVal == JFileChooser.APPROVE_OPTION) {
      framesfile = chooser.getSelectedFile();
    } else {
      return;
    } */
    File framesfile = new File(eepEepConfig.getFramesPath());
    
    String lines[] = loadStrings(framesfile);
    for (int i=0; i < lines.length; i++) {
      StringTokenizer st = new StringTokenizer(lines[i]);
      float x,y,z;
      float rx,ry,rz;
      float scale_factor;
      int frame_num;
      
      frame_num = int(st.nextToken());
      x = float(st.nextToken()) * 2 + 320;// * width / 640;
      y = float(st.nextToken()) * 2 + 240;// * height / 480;
      z = float(st.nextToken());
      rx = float(st.nextToken());
      ry = float(st.nextToken());
      rz = float(st.nextToken());
      scale_factor = float(st.nextToken()) * 2;// / 36.571;
      
      Monkey m = new Monkey();
      m.x = (int)x;
      m.y = (int)y;
      m.size *= scale_factor;
//      m.rotate(new PVector(0, 0, 1), rz);
//      m.rotate(new PVector(0, 1, 0), ry);
//      m.rotate(new PVector(1, 0, 0), rx);
      m.rotate(m.z_axis, rz);
      m.rotate(m.y_axis, ry);
      m.rotate(m.x_axis, rx);

      println("" + frame_num + " " + m.x + " " +  m.y);
     /* 
      while(monkey_frames.size() < frame_num) {
        println("adding dummy frame at " + monkey_frames.size());
        monkey_frames.add(m); // XXX quick ugly hack. blender frames start at 1. java doesn't like skipping elements when building array.
      }
      */
      if (this.start_frame < 0) { // sentinel -1 for first pass
        this.start_frame = frame_num;
        this.frame=start_frame;
      }
      monkey_frames.add(frame_num-this.start_frame, m);
    }
  }
}

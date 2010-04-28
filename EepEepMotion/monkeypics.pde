// collection of MonkeyPics
public class MonkeyPics {
  ObjectOutputStream os = null;
  String dir = null;

  SortedMap mps_hm = new TreeMap();
  
  ListIterator listIterator() {
    ArrayList l = new ArrayList();
    l.addAll(mps_hm.values());
    return l.listIterator();
  }
  
  ListIterator sortedListIterator(Comparator c) {
    ArrayList l = new ArrayList();
    l.addAll(mps_hm.values());
    Collections.sort(l, c);
    return l.listIterator();    
  }
  
  Iterator iterator() {
    return mps_hm.values().iterator();
  }
  
  void load() {
    /* re-enable this if you want to pick index in UI instead of using
       hard coded path */
    /*
    JFileChooser chooser;
    if (this.dir != null) {
      chooser = new JFileChooser(dir);
    } else {
      chooser = new JFileChooser();
    }
    chooser.setFileFilter(chooser.getAcceptAllFileFilter());
    
    File monkey_index;
    int returnVal = chooser.showOpenDialog(null);
    if (returnVal == JFileChooser.APPROVE_OPTION) {
      monkey_index = chooser.getSelectedFile();
      this.dir = monkey_index.getParentFile().getPath();
    } else {
      return;
    }
    */
    File monkey_index = new File(Globals.eepEepConfig.getIndexPath());
    this.dir = monkey_index.getParentFile().getPath();
    
    FileInputStream fis = null;
    ObjectInputStream in = null;
    try
    {
      fis = new FileInputStream(monkey_index);
      in = new ObjectInputStream(fis);
      while(in.available() > 0) {
        MonkeyPic loaded = new MonkeyPic(in, this.dir);
        loaded.reflect(); // XXX TEMP TEST
        mps_hm.put(loaded.filename, loaded);
        println("added #" + mps_hm.size() + ": " + loaded.filename);
      }
    }
    catch(IOException ex)
    {
      ex.printStackTrace();
    }
    
  }
  
  void export() {
    if (this.os != null) {
      try {
        this.os.close();
      } catch (IOException x) {
        print("couldn't close old outputstream");
      }
      this.os = null;
    }
    
    JFileChooser chooser;
    if (this.dir != null) {
      chooser = new JFileChooser(dir);
    } else {
      chooser = new JFileChooser();
    }
    chooser.setFileFilter(chooser.getAcceptAllFileFilter());

    File monkey_index;
    int returnVal = chooser.showSaveDialog(null);
    if (returnVal == JFileChooser.APPROVE_OPTION) {
      monkey_index = chooser.getSelectedFile();
      this.dir = monkey_index.getParentFile().getPath();
    } else {
      return;
    }
      
    FileOutputStream fos = null;
    try
    {
      fos = new FileOutputStream(monkey_index);
      this.os = new ObjectOutputStream(fos);
      Iterator i = this.iterator();
      while(i.hasNext()) {
        ((MonkeyPic)i.next()).save(this.os, dir);
      }
      this.os.flush();  
    }
    catch(IOException ex) {
      ex.printStackTrace();
    } catch(Exception ex) {
      ex.printStackTrace();
    }    
  }
  
  void save(MonkeyPic mp) {
    // save this monkey info
    mp.add_monkey(Globals.m);
    mp.clear_cache(); // unload image to save mem
    mps_hm.put(mp.filename, mp);
    if(this.os != null) {
      try {
        mp.save(this.os, dir);
        this.os.flush();
        print("saved\n");
      } catch (Exception ex) {
        print("WARNING couldn't append to index\n");
      }
    } else {
      print ("WARNING, no export file set.\n");
    }
    mps_hm.put(mp.filename, mp);
    print ("labeled: " + mps_hm.size() + "\n");
  }
  
  void set_best_match(int frame) {
    if (Globals.mp != null) {
      Globals.mp.clear_cache();
    }
    Globals.mp = best_match(Globals.m, frame);
    Globals.mp.match_to_monkey(Globals.m);
    match_score(Globals.mp, Globals.m); // just to print scoring
  }

  void set_best_match() {
    this.set_best_match(frameCount);
  }
  
  // generate a score for how well Mr. Monkey in the picture
  // matches the given Mr. Monkey. Assumes you already called
  // match_mp_to_m to transform the picture to make it match.
  // lower scores are better matches.
  float match_score(MonkeyPic mp, Monkey m) {
     mp.match_to_monkey(m);
     float score = 0;
     float frac_in_frame = 0;
     float frac_frame_used = 0;
      
      // XXX: ignoring rot abt z, which will change how much
      // is in and out of frame. so far hasn't been worth the trouble,
      // since usually the rotation will be relatively small.
     int ul_x = max(0, int(-mp.x*mp.scale_factor));
     int ul_y = max(0, int(-mp.y*mp.scale_factor));
     int lr_x = min(width, int((-mp.x + mp.width)*mp.scale_factor));
     int lr_y = min(height, int((-mp.y + mp.height)*mp.scale_factor));
     float width_in_frame = lr_x - ul_x;
     float height_in_frame = lr_y - ul_y;
     
     frac_frame_used = width_in_frame*height_in_frame / (width*height);
     frac_in_frame = width_in_frame/mp.scale_factor * height_in_frame/mp.scale_factor / mp.width / mp.height;
      
     Monkey mp_monkey = new Monkey(mp.monkey);
     mp_monkey.rotate(new PVector(0, 0, 1), mp.rz);
     float rx_diff = norm(PVector.angleBetween(mp_monkey.x_axis, m.x_axis), 0, PI);
     float ry_diff = norm(PVector.angleBetween(mp_monkey.y_axis, m.y_axis), 0, PI);
     float rz_diff = norm(PVector.angleBetween(mp_monkey.z_axis, m.z_axis), 0, PI);
     
     // scaling > 1 will be ugly.
     float scale_penalty = 0;
     if (mp.scale_factor > 1) {
       scale_penalty = mp.scale_factor;
     }
     
     // if most of the frame is used, just round it up
     // so as not to compete with other parameters
     if (frac_frame_used >= .7) {
       frac_frame_used = 1;
     }
     
     // put it all together to a total score.
     // the weights here are decided largely by trial and error.
     // different weights can make more sense depending what sort of animation you are making,
     // and aesthetic taste (e.g., what's worse? unused frame or scaling?)
     // XXX consider making weights a configuration parameter instead of hard coded here.
     //     also not clear whether a linear function is really the best approach. just the simplest :)
     score = rx_diff + ry_diff + rz_diff + 0.1*(1.0 - frac_in_frame) + 1*(1.0 - frac_frame_used) + 0.5*scale_penalty; //+ abs(Globals.mp.rz);     
     // alternative weights for small clips focused on monkey
     //score = rx_diff + ry_diff + rz_diff + 0*(1.0 - frac_in_frame) + 1*(1.0 - frac_frame_used) + 0.2*scale_penalty; //+ abs(Globals.mp.rz);
     
     println(mp.filename);
     println ("scoring:" 
            + " rx:" + rx_diff 
            + " ry:" + ry_diff 
            + " rz:" + rz_diff 
            + " oof:" + (1.0-frac_in_frame) 
            + " fnu:" + (1.0-frac_frame_used)
            + " scale:" + scale_penalty
            + " -> " + score);
     
     return score;
  }
  
  // set the global mp to the best matching pic.
  // frame_num is 'current' frame_num, used to check
  // for disqualified pics
  MonkeyPic best_match(Monkey m, int frame_num)
  {
    MonkeyPic res = null;
    float low_score = 0;
    Iterator i = this.iterator();
    while(i.hasNext()) {
      Globals.mp = (MonkeyPic)i.next(); // changing the *global* here
      if (Globals.mp.disqualify_until_frame > frame_num) { continue; }
      
      float score = match_score(Globals.mp, m);
      
      if (res == null || score < low_score) {
        low_score = score;
        res = Globals.mp;
      } 
      
      MonkeyPic reflected_mp = new MonkeyPic(Globals.mp);
      reflected_mp.reflect();
      score = match_score(reflected_mp, m);
      if (res == null || score < low_score) {
        low_score = score;
        res = reflected_mp;
      }
      
    }
    return res;
  }

  MonkeyPic best_match(Monkey m) {
    return this.best_match(m, frameCount);
  }

}

/* used to sort by match score */
class MatchComparator implements Comparator {
  int compare(Object o1, Object o2) {
    MonkeyPic mp1 = (MonkeyPic)o1;
    MonkeyPic mp2 = (MonkeyPic)o2;
    
    float ms1 = Globals.mps.match_score(mp1, Globals.m);
    float ms2 = Globals.mps.match_score(mp2, Globals.m);

    if (ms1 < ms2)
      return -1;
    else if (ms1 > ms2)
      return 1;
    else
      return 0;
  }
  boolean equals(Object obj) {
    return (obj == this);
  }
}

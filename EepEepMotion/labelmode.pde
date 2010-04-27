/* this is the mode to label Mr. Monkey's position in photos.
 * the photos themselves are not modified - each labeled photo is added to an index file.
 */

class LabelMode extends Mode {
  void draw() {
    background(0);

    if(mp != null) {
      mp.draw();
    }
    lights();
    ortho(-width/2, width/2, -height/2, height/2, -10, 10);
    m.move_to();
    m.draw(); 
  }
  void keyPressed() {
    if (key == CODED) {
    } else {    
      if (key == 's') {
        int x,y,z;
        int rx, ry, rz;
        float mscale;
        x=m.x / 2 - 320;
        y=(-m.y / 2) - 240;
        z=0;
        rx = 0;//- degrees(m.rx);
        ry = 0;//- degrees(-m.ry);
        rz = 0;//- degrees(m.rz);
        mscale = m.size / 100;
        
        mps.save(mp);
        
        // reset
        mp = null;
        m = new Monkey();
        m.x = width/2;
        m.y = height/2;    
  
        redraw();
      } else if (key == '+' || key == '=') {
        mp.set_scale(mp.scale_factor*1.5, m.x, m.y);
        m.size *= 1.5;
        m.x = width/2;
        m.y = height/2;
        redraw();
      } else if (key == '-' || key == '_') {
        mp.set_scale(mp.scale_factor/1.5, m.x, m.y);
        m.size /= 1.5;
        m.x = width/2;
        m.y = height/2;
        redraw();
      } else if (key == '[' || key == ']') {
        if (mp != null) {
          mp.clear_cache();
        }
        if (i == null) {
          i = mps.listIterator();
        }
        if (key == '[' && i.hasPrevious()) {
          mp = (MonkeyPic)(i.previous());
        } else if (key == ']' && i.hasNext()) {
          mp = (MonkeyPic)(i.next());
        }
        match_mp_to_m(mp, m);
        mps.match_score(mp, m); // just to print scoring
        
        /*
        print ("loading " + mp.filename + "\n");
        match_mp_to_screen(mp);
        m = new Monkey(mp.monkey);
        m.x *= mp.scale_factor;
        m.y *= mp.scale_factor;
        m.size *= mp.scale_factor; */
        redraw();
      } else if (key == 'e') {
        mps.export();
      } else if (key == 'i') {
        mps.load();
      } else if (key == 'f' || key == 'F') {
        if (currentDir == null) {
          currentDir = new File(eepEepConfig.getRootPath());
        }
        
        // this worked before, but now hangs. why?
        /*
        JFileChooser chooser = new JFileChooser(currentDir);
        chooser.addChoosableFileFilter(new UntaggedFilter());
        int returnVal = chooser.showOpenDialog(null);
        if (returnVal == JFileChooser.APPROVE_OPTION)
        { 
          currentDir = chooser.getCurrentDirectory();
          mp = new MonkeyPic(chooser.getSelectedFile().getAbsolutePath());
          match_mp_to_screen(mp);          
          // draw
          redraw();
        } else {
          println("Jfilechooser not happy");
        }        
        */
        
        // work-around for now. bummer is no file filter to hide already-labeled pics
        String filename = selectInput("Select image to label");
        
        if (filename != null)
        { 
          File f = new File(filename);
          mp = new MonkeyPic(f.getAbsolutePath());
          match_mp_to_screen(mp);          
          // draw
          redraw();
        }
      } else if (key == 'm') {
        i = mps.sortedListIterator(new MatchComparator());
        mp = (MonkeyPic)(i.next());
        match_mp_to_m(mp, m);
        mps.match_score(mp, m); // just to print scoring
        redraw();
      }
    }    
  }
  void keyReleased() {
  }  
}

/* can use this in file dialog to only show images that haven't been labeled yet */
class UntaggedFilter extends javax.swing.filechooser.FileFilter {
    public boolean accept(File f) {
        return !mps.mps_hm.containsKey(f.getAbsolutePath());
    }
    
    public String getDescription() {
        return "untagged files";
    }
}

void match_mp_to_screen(MonkeyPic mp) {
  // scale image to max window size
  float xfactor = width / float(mp.width);
  float yfactor = height / float(mp.height); 
  mp.set_scale(min(xfactor, yfactor), width/2, height/2);
  mp.x = 0;
  mp.y = 0;  
}


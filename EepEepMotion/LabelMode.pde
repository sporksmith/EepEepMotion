/* this is the mode to label Mr. Monkey's position in photos.
 * the photos themselves are not modified - each labeled photo is added to an index file.
 */

class LabelMode extends Mode {
  void draw() {
    background(0);

    if(Globals.mp != null) {
      Globals.mp.draw();
    }
    lights();
    ortho(-width/2, width/2, -height/2, height/2, -10, 10);
    Globals.m.move_to();
    Globals.m.draw(); 
  }
  void keyPressed() {
    if (key == CODED) {
    } else {    
      if (key == 's') {
        int x,y,z;
        int rx, ry, rz;
        float mscale;
        x=Globals.m.x / 2 - 320;
        y=(-Globals.m.y / 2) - 240;
        z=0;
        rx = 0;//- degrees(m.rx);
        ry = 0;//- degrees(-m.ry);
        rz = 0;//- degrees(m.rz);
        mscale = Globals.m.size / 100;
        
        Globals.mps.save(Globals.mp);
        
        // reset
        Globals.mp = null;
        Globals.m = new Monkey();
        Globals.m.x = width/2;
        Globals.m.y = height/2;    
  
        redraw();
      } else if (key == '+' || key == '=') {
        Globals.mp.set_scale(Globals.mp.scale_factor*1.5, Globals.m.x, Globals.m.y);
        Globals.m.size *= 1.5;
        Globals.m.x = width/2;
        Globals.m.y = height/2;
        redraw();
      } else if (key == '-' || key == '_') {
        Globals.mp.set_scale(Globals.mp.scale_factor/1.5, Globals.m.x, Globals.m.y);
        Globals.m.size /= 1.5;
        Globals.m.x = width/2;
        Globals.m.y = height/2;
        redraw();
      } else if (key == '[' || key == ']') {
        if (Globals.mp != null) {
          Globals.mp.clear_cache();
        }
        if (Globals.i == null) {
          Globals.i = Globals.mps.listIterator();
        }
        if (key == '[' && Globals.i.hasPrevious()) {
          Globals.mp = (MonkeyPic)(Globals.i.previous());
        } else if (key == ']' && Globals.i.hasNext()) {
          Globals.mp = (MonkeyPic)(Globals.i.next());
        }
        Globals.mp.match_to_monkey(Globals.m);
        Globals.mps.match_score(Globals.mp, Globals.m); // just to print scoring
        
        /*
        print ("loading " + Globals.mp.filename + "\n");
        match_mp_to_screen(mp);
        m = new Monkey(Globals.mp.monkey);
        Globals.m.x *= Globals.mp.scale_factor;
        Globals.m.y *= Globals.mp.scale_factor;
        Globals.m.size *= Globals.mp.scale_factor; */
        redraw();
      } else if (key == 'e') {
        Globals.mps.export();
      } else if (key == 'i') {
        Globals.mps.load();
      } else if (key == 'f' || key == 'F') {
        if (Globals.currentDir == null) {
          Globals.currentDir = new File(Globals.eepEepConfig.getRootPath());
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
          Globals.mp = new MonkeyPic(f.getAbsolutePath());
          Globals.mp.set_scale_max(width, height);          
          // draw
          redraw();
        }
      } else if (key == 'm') {
        Globals.i = Globals.mps.sortedListIterator(new MatchComparator());
        Globals.mp = (MonkeyPic)(Globals.i.next());
        Globals.mp.match_to_monkey(Globals.m);
        Globals.mps.match_score(Globals.mp, Globals.m); // just to print scoring
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
        return !Globals.mps.mps_hm.containsKey(f.getAbsolutePath());
    }
    
    public String getDescription() {
        return "untagged files";
    }
}


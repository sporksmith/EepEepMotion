import javax.swing.JFileChooser;
import java.io.Serializable;
import java.io.ObjectOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Iterator;
import java.util.Arrays;
import java.util.Comparator;

import processing.video.*;

// hard coded path names for convenience
String project_root_path = "/FIXME/EepEepMotion/Travels"; /* other paths will be relative to this one */
String pic_index_path = project_root_path + "pictures/index";
String frames_path = project_root_path + "blender/verses.txt";
String movie_output_path = project_root_path + "output/movie.mpg";
String frames_output_path = frames_path + "_frames/";

/* each mode specifies its own setup routine, draw routine, and key bindings. 
 * this allows this code to use the core logic for different applications; e.g., labeling, rendering, animating.
 * a cleaner way to do this would be to have a UI to switch modes dynamically. I started to do this with controlP5, but there were some conflicts.
 * another cleaner way to do this would be to separate the core logic into a library and have distinct applications linking to that library.
 */
ArrayList modes = new ArrayList();
Mode mode;

/* resolution for the screen, AND for output images\video */
int maxx = 640, maxy = 480;

/* keep track of current directory so that file dialogs open at the current directory */
File currentDir = null;

/* these should probably be moved into the mode classes rather than being at the global scope. */
MonkeyPics mps = new MonkeyPics();
ListIterator i; /* points to next pic in MonkeyPics */
MonkeyPic mp; /* current displayed mp */
Monkey m; /* current displayed monkey */

EepEepMotion applet; /* this applet. sometimes needs to be passed into Java APIs */

// keeps track of whether corresponding command key is held down
boolean do_rotate = false;
boolean do_turn = false;
boolean do_zoom = false;

// target frame rate. for rendering this should be cranked up as
// high enough that we're not idling.
// FIXME: in some places when rendering directly to a movie, this is also used
//        as the movie playback framerate. should really be a separate setting.
int target_rate = 30;

/* global key bindings. modes can add more (and\or override these) */
void keyPressed() {
  mode.keyPressed();

  // global bindings
  if (key == CODED) {
  } else {
    if (key == 'h') {
      m.hide = !m.hide;
      redraw();
    } else if (key == 'z') {
      do_zoom = true;
    } else if (key == 'r') {
      do_rotate = true;
    } else if (key == 't') {
      do_turn = true;
    }
  }
}

void keyReleased() {
  mode.keyReleased();
  
  // global key bindings
  if (key == CODED) {
  } else {
    if (key == 'r') {
      do_rotate = false;
    } else if (key == 'z') {
      do_zoom = false;
    } else if (key == 't') {
      do_turn = false;
    }
  }     
}

void setup() {
  applet = this;
  size(maxx, maxy, P3D);
  m = new Monkey();
  m.x = width/2;
  m.y = height/2;
  
  /* load the tag index file */
  mps.load();
  
  //mode = new AnimateMode();
  mode = new LabelMode();
  //mode = new RenderFromFramesMode();
  mode.enterMode();

  //mode = (Mode)modes.get(0);
}

void mouseDragged() {
  int dx = mouseX - pmouseX;
  int dy = mouseY - pmouseY;
  
  if (do_rotate) {
      m.rotate_y(radians(dx));
      m.rotate_x(radians(-dy));
  } else if (do_zoom) {
    m.size += dx - dy;
    if (m.size < 1) {
      m.size = 1;
    }
  } else if (do_turn) {
    m.rotate_z(radians(dx));
  } else {
    m.x += (int)(dx);
    m.y += (int)(dy);
  }
  redraw();
}

void draw() {
  pushMatrix();
  mode.draw();
  popMatrix();
}

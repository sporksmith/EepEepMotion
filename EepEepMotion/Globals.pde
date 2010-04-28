/* will change this to be a class called Globals with all fields static.
   can't do it now; doesn't seem to play well with processing's rewriting.
   */
class GlobalsC {
  EepEepConfig eepEepConfig = new EepEepConfig();

  /* each mode specifies its own setup routine, draw routine, and key bindings. 
   * this allows this code to use the core logic for different applications; e.g., labeling, rendering, animating.
   * a cleaner way to do this would be to have a UI to switch modes dynamically. I started to do this with controlP5, but there were some conflicts.
   * another cleaner way to do this would be to separate the core logic into a library and have distinct applications linking to that library.
   */
  ArrayList modes = new ArrayList();
  Mode mode;

  /* keep track of current directory so that file dialogs open at the current directory */
  File currentDir = null;

  /* these should probably be moved into the mode classes rather than being at the global scope. */
  MonkeyPics mps = new MonkeyPics();
  ListIterator i; /* points to next pic in MonkeyPics */
  MonkeyPic mp; /* current displayed mp */
  Monkey m; /* current displayed monkey */

  EepEepMotion applet; /* this applet. sometimes needs to be passed into Java APIs */
}
GlobalsC Globals = new GlobalsC();

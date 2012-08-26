package net.sporksmith.eepeepmotion;

import java.io.File;
import java.util.ArrayList;
import java.util.ListIterator;

class Globals {
	static EepEepConfig eepEepConfig = new EepEepConfig();

	/* each mode specifies its own setup routine, draw routine, and key bindings. 
	 * this allows this code to use the core logic for different applications; e.g., labeling, rendering, animating.
	 * a cleaner way to do this would be to have a UI to switch modes dynamically. I started to do this with controlP5, but there were some conflicts.
	 * another cleaner way to do this would be to separate the core logic into a library and have distinct applications linking to that library.
	 */
	static ArrayList modes = new ArrayList();
	static Mode mode;

	/* keep track of current directory so that file dialogs open at the current directory */
	static File currentDir = null;

	/* these should probably be moved into the mode classes rather than being at the global scope. */
	static MonkeyPics mps = new MonkeyPics();
	static ListIterator i; /* points to next pic in MonkeyPics */
	static MonkeyPic mp; /* current displayed mp */
	static Monkey m; /* current displayed monkey */

	static EepEepMotion applet; /* this applet. sometimes needs to be passed into Java APIs */
}


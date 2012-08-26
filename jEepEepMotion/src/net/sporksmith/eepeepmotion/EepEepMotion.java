package net.sporksmith.eepeepmotion;
import processing.core.*;

import javax.swing.JFileChooser;
import java.io.Serializable;
import java.io.ObjectOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Iterator;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Properties;

import java.util.prefs.*;

public class EepEepMotion extends PApplet {
	/* global key bindings. modes can add more (and\or override these) */
	public void keyPressed() {
		Globals.mode.keyPressed();

		// global bindings
		if (key == CODED) {
		} else {
			if (key == 'h') {
				Globals.m.hide = !Globals.m.hide;
				redraw();
			}
		}
	}

	public void keyReleased() {
		Globals.mode.keyReleased();
	}

	public void setup() {
		Globals.applet = this;
		size(Globals.eepEepConfig.getWidth(), Globals.eepEepConfig.getHeight(), P3D);
		Globals.m = new Monkey();
		Globals.m.x = width/2;
		Globals.m.y = height/2;

		/* load the tag index file */
		Globals.mps.load();

		//mode = new AnimateMode();
		Globals.mode = new LabelMode();
		//mode = new RenderFromFramesMode();
		Globals.mode.enterMode();

		//mode = (Mode)modes.get(0);
	}

	boolean doRotate() {
		return keyPressed && (key == 'r' || key == 'R');
	}
	boolean doZoom() {
		return keyPressed && (key == 'z' || key == 'Z');
	}
	boolean doTurn() {
		return keyPressed && (key == 't' || key == 'T');
	}
	public void mouseDragged() {
		int dx = mouseX - pmouseX;
		int dy = mouseY - pmouseY;

		if (doRotate()) {
			Globals.m.rotate_y(radians(dx));
			Globals.m.rotate_x(radians(-dy));
		} else if (doZoom()) {
			Globals.m.size += dx - dy;
			if (Globals.m.size < 1) {
				Globals.m.size = 1;
			}
		} else if (doTurn()) {
			Globals.m.rotate_z(radians(dx));
		} else {
			Globals.m.x += (int)(dx);
			Globals.m.y += (int)(dy);
		}
		redraw();
	}

	public void draw() {
		pushMatrix();
		Globals.mode.draw();
		popMatrix();
	}
}

class EepEepConfig {
	private String rootPath, indexPath, framesPath, movieOutputPath, framesOutputPath;
	private String picturesPath;

	private int width, height;
	private int targetRate;

	EepEepConfig() {
		this.rootPath = System.getProperty("user.home") + "/EepEepMotion/Travels/";

		this.picturesPath = "pictures/";
		this.indexPath = "index";

		this.framesPath = "blender/verses.txt";
		this.movieOutputPath = "output/movie.mpg";
		this.framesOutputPath = this.framesPath + "_frames/";

		this.width = 640;
		this.height = 480;

		this.targetRate = 30;
	}

	String getRootPath() {
		return this.rootPath;
	}
	String getPicturesPath() {
		return getRootPath() + this.picturesPath;
	}
	String getIndexPath() {
		return getPicturesPath() + this.indexPath;
	}
	String getFramesPath() {
		return getRootPath() + this.framesPath;
	}
	String getFramesOutputPath() {
		return getRootPath() + this.framesOutputPath;
	}

	/* resolution for the screen, AND for output images\video */
	int getWidth() {
		return this.width;
	}
	int getHeight() {
		return this.height;
	}

	// target frame rate. for rendering this should be cranked up as
	// high enough that we're not idling.
	// FIXME: in some places when rendering directly to a movie, this is also used
	//        as the movie playback framerate. should really be a separate setting.
	int getTargetRate() {
		return this.targetRate;
	}
}

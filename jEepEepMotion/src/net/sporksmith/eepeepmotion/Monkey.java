package net.sporksmith.eepeepmotion;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import processing.core.*;


public class Monkey {  
	int x=0, y=0;
	int size = 100; 
	boolean hide = false;

	/* originally stored orientation as radians rx, ry, and rz.
	     this way is more convenient for the matching calculations,
	     though.
	 */
	PVector x_axis = new PVector(1, 0, 0);
	PVector y_axis = new PVector(0, 1, 0);
	PVector z_axis = new PVector(0, 0, 1);

	void rotate_x(float a) {
		this.rotate(this.x_axis, a);
	}

	void rotate_y(float a) {
		this.rotate(this.y_axis, a);
	}

	void rotate_z(float a) {
		this.rotate(this.z_axis, a);
	}

	void rotate(PVector axis, float a) {
		x_axis = Util.rotatePointAroundVector(x_axis, axis, a);
		x_axis.normalize();
		y_axis = Util.rotatePointAroundVector(y_axis, axis, a);
		y_axis.normalize();
		z_axis = Util.rotatePointAroundVector(z_axis, axis, a);
		z_axis.normalize();
	}

	// translate pv from monkey axes to screen axes
	PVector apply_rotations(PVector pv) {
		return this.apply_rotations(pv.x, pv.y, pv.z);
	}

	// translate (x,y,z) from monkey axes to screen axes
	PVector apply_rotations(float x, float y, float z) {
		PVector res = new PVector(0, 0, 0);

		res.add(PVector.mult(x_axis, x));
		res.add(PVector.mult(y_axis, y));
		res.add(PVector.mult(z_axis, z));

		return res;
	}

	// translate relative to orientation.
	// mostly useful for drawing the individual monkey features
	void translate_relative(float x, float y, float z) {
		PVector p = this.apply_rotations(x, y, z);
		Globals.applet.translate(p.x, p.y, p.z);
	}

	public Monkey () {
	}

	public Monkey (Monkey src) {
		x = src.x;
		y = src.y;
		x_axis = src.x_axis.get();
		y_axis = src.y_axis.get();
		z_axis = src.z_axis.get();
		size = src.size;
		hide = src.hide;
	}

	public Monkey (ObjectInputStream in) throws IOException {
		this.load(in);    
	}

	// move to Mr. Monkey's position. do this before calling draw
	void move_to() {
		Globals.applet.translate(x, y, 0);
	}

	// move back from Mr. Monkey's position. 
	// (alternatively use pushMatrix and popMatrix) 
	void move_from() {
		Globals.applet.translate(-x, -y, 0);
	}

	void save(ObjectOutputStream out) throws IOException {
		out.writeInt(x);
		out.writeInt(y);
		out.writeFloat(x_axis.x);
		out.writeFloat(x_axis.y);
		out.writeFloat(x_axis.z);
		out.writeFloat(y_axis.x);
		out.writeFloat(y_axis.y);
		out.writeFloat(y_axis.z);
		out.writeFloat(z_axis.x);
		out.writeFloat(z_axis.y);
		out.writeFloat(z_axis.z);
		out.writeInt(size);
	}

	void load(ObjectInputStream in) throws IOException {
		x = in.readInt();
		y = in.readInt();
		x_axis.x = in.readFloat();
		x_axis.y = in.readFloat();
		x_axis.z = in.readFloat();
		y_axis.x = in.readFloat();
		y_axis.y = in.readFloat();
		y_axis.z = in.readFloat(); 
		z_axis.x = in.readFloat();
		z_axis.y = in.readFloat();
		z_axis.z = in.readFloat();
		size = in.readInt();
	}

	void draw_color(int face_color, int eye_color){
		if (hide) {return;}

		// monkey brown fill, no lines
		Globals.applet.fill(face_color);
		Globals.applet.noStroke();

		// cranium
		Globals.applet.sphere(size/2);

		PVector p;

		// muzzle
		Globals.applet.pushMatrix();
		this.translate_relative((float)(0.0), (float)(size*85.0/350), (float)(size*170.0/350));  // z was 85, y was 125
		Globals.applet.sphere((float)(size*100.0/350)); //muzzle (was 90)
		Globals.applet.popMatrix();

		// ears
		Globals.applet.pushMatrix();
		this.translate_relative(0, 0, (float)(-size*75.0/350));
		this.translate_relative(size/2, 0, 0);
		Globals.applet.sphere((float)(size*55.0/350));
		this.translate_relative(-size, 0, 0);
		Globals.applet.sphere((float)(size*55.0/350));
		Globals.applet.popMatrix();

		// eyes
		Globals.applet.fill(eye_color);
		int eye_size = (int)(size*20.0/350);
		float eye_x = (float) (size*85.0/350);
		float eye_z = (float) (.9*size/2);
		float eye_y = (float) (-size*20.0/350);
		Globals.applet.pushMatrix();
		this.translate_relative((float) (eye_x/2.0), eye_y, eye_z);
		Globals.applet.sphere(eye_size);
		this.translate_relative(-eye_x, 0, 0);
		Globals.applet.sphere(eye_size);
		Globals.applet.popMatrix();    
	}
	void draw() {
		this.draw_color(Globals.applet.color(0x8b, 0x45, 0x13, 0xff), Globals.applet.color(0, 0, 0, 0xff));
	}  

	public String toString() {
		return String.format("x:%d y:%d sz:%d\n", x, y, size);
	}
}


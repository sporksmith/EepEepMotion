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
    x_axis = rotatePointAroundVector(x_axis, axis, a);
    x_axis.normalize();
    y_axis = rotatePointAroundVector(y_axis, axis, a);
    y_axis.normalize();
    z_axis = rotatePointAroundVector(z_axis, axis, a);
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
    translate(p.x, p.y, p.z);
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
    translate(x, y, 0);
  }
   
  // move back from Mr. Monkey's position. 
  // (alternatively use pushMatrix and popMatrix) 
  void move_from() {
    translate(-x, -y, 0);
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

  void draw_color(color face_color, color eye_color){
    if (hide) {return;}
        
    // monkey brown fill, no lines
    fill(face_color);
    noStroke();
    
    // cranium
    sphere(size/2);
    
    PVector p;
    
    // muzzle
    pushMatrix();
    this.translate_relative(0, size*85.0/350, size*170/350);  // z was 85, y was 125
    sphere(int(size*100.0/350)); //muzzle (was 90)
    popMatrix();

    // ears
    pushMatrix();
    this.translate_relative(0, 0, -size*75.0/350);
    this.translate_relative(size/2, 0, 0);
    sphere(int(size*55.0/350));
    this.translate_relative(-size, 0, 0);
    sphere(int(size*55.0/350));
    popMatrix();

    // eyes
    fill(eye_color);
    int eye_size = int(size*20.0/350);
    float eye_x = size*85.0/350;
    float eye_z = .9*size/2;
    float eye_y = -size*20.0/350;
    pushMatrix();
    this.translate_relative(eye_x/2.0, eye_y, eye_z);
    sphere(eye_size);
    this.translate_relative(-eye_x, 0, 0);
    sphere(eye_size);
    popMatrix();    
  }
  void draw() {
    this.draw_color(color(0x8b, 0x45, 0x13, 0xff), color(0, 0, 0, 0xff));
  }  
}

/* should make this a member of Monkey */
String monkey_to_string(Monkey m)
{
//  return "monkey_to_string fixme";
  return "" + m.x + " " + m.y + " " + m.size;// + "\n";//+ m.rx + " " + m.ry + " " + m.rz 
//    + " " + m.size;
}

public class MonkeyPic {
  // static info
  String filename; // this is the *absolute* filename of the image
  int width;
  int height;
  Monkey monkey; // Mr. Monkey's location and orientation in the image
  boolean reflected=false; // Keep track of whether we're working with the mirror image of the original
  
  // mirror the image. 
  // sometimes this can get us a better match.
  void reflect() {
    // reflect monkey's x position over mid-x 
    int mid_x = this.width / 2;
    int x_offset = (this.monkey.x - mid_x);
    this.monkey.x = mid_x - x_offset;
    
    // reflect axes
    this.monkey.x_axis.y = -this.monkey.x_axis.y;
    this.monkey.x_axis.z = -this.monkey.x_axis.z;
    
    this.monkey.y_axis.x = -this.monkey.y_axis.x;
    this.monkey.z_axis.x = -this.monkey.z_axis.x;
    
    this.reflected = !this.reflected;
    this.img = null; // clear image cache
  }
  
  MonkeyPic(MonkeyPic src) {
    this.filename = src.filename;
    this.width = src.width;
    this.height = src.height;
    this.monkey = new Monkey(src.monkey);
    this.reflected = src.reflected;
  }
  
  void save(ObjectOutputStream out, String prefix) throws IOException, Exception {
    String rel_filename;
    
    if (!filename.startsWith(prefix)) {
      throw new Exception("file not in index subtree", null);
    }
    rel_filename = filename.substring(prefix.length());
    if (rel_filename.startsWith("/")) {
      rel_filename = rel_filename.substring(1);
    }

    out.writeUTF(rel_filename);
    out.writeInt(width);
    out.writeInt(height);
    monkey.save(out);
  }
  
  void load(ObjectInputStream in, String dir) throws IOException {
    filename = in.readUTF();
    width = in.readInt();
    height = in.readInt();
    monkey = new Monkey(in);
    
    filename = dir + "/" + filename;   
  }

  // dynamic display stuff
  PImage img; // actual image. caller should call clear_cache to not keep img around in memory when not in use
  float rz = 0; // amt to rotate abt the z axis
  int rz_x=0, rz_y=0; // offset the z axis before rotation, to center around saved screen monkey loc
  int x = 0;
  int y = 0;
  float scale_factor = 1.0;
  int disqualify_until_frame = 0; // use this to prevent this particular pic from being used (again) until at least given frame num
  
  MonkeyPic(String filename) {
    this.filename = filename;
    //img = loadImage(this.filename);
    img = null;
    this.width = img.width;
    this.height = img.height;
  }
  
  MonkeyPic(ObjectInputStream in, String dir) throws IOException {
    this.load(in, dir);  
  }
  
  void clear_cache() {
    img = null;
  }
  
  // save location of Mr. Monkey.
  // needs to translate location, scale, and rotation
  // from screen coordinate system to picture coordinate system
  void add_monkey(Monkey m) {
    monkey = m;
    monkey.size = (int)(monkey.size / scale_factor);
    monkey.x = this.x + (int)(monkey.x / scale_factor);
    monkey.y = this.y + (int)(monkey.y / scale_factor);
    monkey.rotate(new PVector(0, 0, 1), -this.rz);
//    monkey.rz -= this.rz;
    print(monkey.toString() + "\n");
  }
  
  // scale image on screen, keeping Mr. Monkey's location consistent
  // in scaled image
  void set_scale(float s, int c_x, int c_y) {
    // translate c_x, c_y from screen coordinates to image coordinates
    c_x = x + (int)(c_x / scale_factor);
    c_y = y + (int)(c_y / scale_factor);
    
    scale_factor = s;
    x = c_x - (int)(width / scale_factor / 2);
    y = c_y - (int)(height / scale_factor / 2);
  }
  
  void draw() {
    if (img == null) {
      img = loadImage(this.filename);
      if(this.reflected) {
        Util.hflip(img);
      }
    }

    pushMatrix();
    translate(rz_x, rz_y, 0);
    rotateZ(rz);
    translate(-rz_x, -rz_y, 0);
    
    scale(scale_factor);
    translate(0, 0, -1000);
    image(img, -x, -y);
    popMatrix();
  }
}

// adjust the picture to line up as closely to Monkey m as 
// is possible.
void match_mp_to_m(MonkeyPic mp, Monkey m) {
  // rotate the picture about Mr. Monkey's location
  mp.rz_x = m.x;
  mp.rz_y = m.y;
  
  mp.scale_factor = (float)m.size / (float)mp.monkey.size;
  
  // use rotation abt z to align whichever axis has greatest
  // magnitude when projected onto the xy plane.
  // there could be a better way to decide how to rotate picture.
  PVector monkey_axis, mp_monkey_axis;
  PVector x_axis_proj, y_axis_proj, z_axis_proj;
  x_axis_proj = m.x_axis.get();
  x_axis_proj.z = 0;
  y_axis_proj = m.y_axis.get();
  y_axis_proj.z = 0;
  z_axis_proj = m.z_axis.get();
  z_axis_proj.z = 0;
  monkey_axis = m.x_axis;
  mp_monkey_axis = mp.monkey.x_axis;

  // pick max(x_axis_proj.mag(), y_axis_proj.mag(), z_axis_proj.mag()) 
  if(x_axis_proj.mag() > y_axis_proj.mag() && x_axis_proj.mag() > z_axis_proj.mag()) {
    monkey_axis = m.x_axis;
    mp_monkey_axis = mp.monkey.x_axis;
  } else if (y_axis_proj.mag() > z_axis_proj.mag()) {
    monkey_axis = m.y_axis;
    mp_monkey_axis = mp.monkey.y_axis;
  } else {
    monkey_axis = m.z_axis;
    mp_monkey_axis = mp.monkey.z_axis;
  }

  float m_axis_angle = Util.angle_of(monkey_axis.x, monkey_axis.y);
  float mp_axis_angle = Util.angle_of(mp_monkey_axis.x, mp_monkey_axis.y);
  mp.rz = m_axis_angle - mp_axis_angle;
  
  mp.x = mp.monkey.x - (int)(m.x/mp.scale_factor);
  mp.y = mp.monkey.y - (int)(m.y/mp.scale_factor);
}

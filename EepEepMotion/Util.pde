static class Util {
  static LinkedList reversedLinkedList(LinkedList ll) {
    LinkedList rv = new LinkedList();
    for(Iterator i=ll.iterator(); i.hasNext();) {
      rv.addFirst(i.next());
    }
    return rv;
  }
  
  // ;Rotate the point m=(x,y,z) around the vector n=(u,v,w)
  static PVector rotatePointAroundVector(PVector m, PVector n, float a) {
    float x = m.x;
    float y = m.y;
    float z = m.z;
    float u = n.x;
    float v = n.y;
    float w = n.z;
    float ux=u*x;
    float uy=u*y;
    float uz=u*z;
    float vx=v*x;
    float vy=v*y;
    float vz=v*z;
    float wx=w*x;
    float wy=w*y;
    float wz=w*z;
    float sa=sin(a); 
    float ca=cos(a);
    x=u*(ux+vy+wz)+(x*(v*v+w*w)-u*(vy+wz))*ca+(-wy+vz)*sa;
    y=v*(ux+vy+wz)+(y*(u*u+w*w)-v*(ux+wz))*ca+(wx-uz)*sa;
    z=w*(ux+vy+wz)+(z*(u*u+v*v)-w*(ux+vy))*ca+(-vx+uy)*sa;
    return new PVector(x, y, z);
  } 
  
  // temporary, migrating from absolute rotations to vector representation
  /*
  PVector monkey_rotations(Monkey m, PVector v) {
    v = v.get();
    PVector x_axis = new PVector(1, 0, 0);
    PVector y_axis = new PVector(0, 1, 0);
    PVector z_axis = new PVector(0, 0, 1);
  
    //  rotateZ(rz); // important that z is first
    v = rotatePointAroundVector(v, z_axis, m.rz);
    x_axis = rotatePointAroundVector(x_axis, z_axis, m.rz);
    y_axis = rotatePointAroundVector(y_axis, z_axis, m.rz);
  
    //  rotateX(rx);
    v = rotatePointAroundVector(v, x_axis, m.rx);
    y_axis = rotatePointAroundVector(y_axis, x_axis, m.rx);
  
    //  rotateY(ry);
    v = rotatePointAroundVector(v, y_axis, m.ry);
    
    return v;
  }
  */
  
  // put between -pi and pi
  static float normalize_radians(float r) {
    Boolean flip_sign;
    if (r < 0) {
      r = -r;
      flip_sign = true;
    } else {
      flip_sign = false;
    }
    
    // put it between 0 and 2pi first
    int revolutions = int(r / TWO_PI);
    r -= revolutions*TWO_PI;
    
    // if it's over PI, map it to a negative angle
    if (r > PI) {
      r -= TWO_PI;
    }
    
    // flip back sign if necessary
    if (flip_sign) {
      r = -r;
    }
    return r;
  }
  
  static float angle_of(float x, float y) {
    float rv = acos(x / sqrt(x*x+y*y));
    if (y < 0) {
  //    rv += TWO_PI - rv;
      rv = TWO_PI - rv;
    }
    return rv;
  }
  
  static void hflip(PImage src) {
    int mid_x = src.width/2;
    for(int x=0; x<mid_x; x++) {
      for(int y=0; y<src.height; y++) {
        int x2 = src.width-x-1;
        color tmp = src.get(x, y);
        src.set(x, y, src.get(x2, y));
        src.set(x2, y, tmp); 
      }
    }
  }
}


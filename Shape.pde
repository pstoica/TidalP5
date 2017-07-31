import oscP5.*;
import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;

void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

class Shape {
  String shape;
  float x;
  float y;
  float z;
  float r;
  int n;
  float begin;
  float end;
  float dur;
  float opacity;
  float rotate;
  float rotateX;
  float rotateY;
  float strokeWeight;
  String[] colors;
  float c;
  boolean fill;

  Ani aniOpacity;

  Shape(OscMessage m) {
    this.shape = m.get(0).stringValue();
    this.x = m.get(1).floatValue();
    this.y = m.get(2).floatValue();
    this.z = m.get(3).floatValue();
    this.r = m.get(4).floatValue();
    this.n = m.get(5).intValue();
    this.begin = m.get(6).floatValue();
    this.end = m.get(7).floatValue();
    this.dur = m.get(8).floatValue();
    this.opacity = m.get(9).floatValue();
    this.rotate = m.get(10).floatValue();
    this.rotateX = m.get(11).floatValue();
    this.rotateY = m.get(12).floatValue();
    this.strokeWeight = m.get(13).floatValue();
    this.colors = m.get(14).stringValue().toUpperCase().split(":");
    this.c = m.get(15).floatValue();
    this.fill = m.get(16).intValue() > 0;
  }

  void makeAni() {
    this.aniOpacity = Ani.to(this, dur, "opacity", 0, Ani.LINEAR);
    this.aniOpacity.start();
  }

  int getColor() {
    return lerpColor(
      unhex("FF" + colors[floor(c) % colors.length]),
      unhex("FF" + colors[ceil(c) % colors.length]),
      c - floor(c)
    );
  }

  void finish() {
    this.aniOpacity.end();
    this.opacity = 0;
  }

  boolean finished() {
    boolean result = (dur == 0 || opacity <= 0);
    if (result) {
      this.finish();
    }
    return result;
  }

  void display() {
    if (this.aniOpacity == null) {
      this.makeAni();
    }

    pushMatrix();
    translate(x * width, y * height, z);

    stroke(color(0), opacity * 255);
    rotateX(rotateX);
    rotateY(rotateY);
    rotate(rotate * TWO_PI);

    if (this.fill && shape != "point") {
      noStroke();
      fill(this.getColor(), opacity * 255);
    } else {
      noFill();
      stroke(this.getColor(), opacity * 255);
    }

    strokeWeight(strokeWeight * (width / 500));

    switch (shape) {
    case "poly":
    case "polygon":
      polygon(0, 0, r * (width / 2), n);
      break;
    case "arc":
      arc(0, 0, r * (width / 2), r * (width / 2), TWO_PI * this.begin, TWO_PI * this.end);
      break;
    case "circle":
      ellipse(0, 0, r * (height / 2), r * (height / 2));
      break;
    case "point":
      point(0, 0);
      break;
    case "sphere":
      sphere(r * (width / 2));
      break;
    case "box":
      box(r * (width / 2));
      break;
    default:
      polygon(0, 0, r * (width / 2), n);
      break;
    }

    popMatrix();
  }
};

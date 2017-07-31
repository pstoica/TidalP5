import oscP5.*;
import netP5.*;
import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;
import sojamo.animatedgif.*;
import com.hamoid.*;
import java.util.*;
import processing.pdf.*;

VideoExport videoExport;
OscP5 osc;
GifRecorder gif;

PImage lastFrame;
ArrayList<Shape> shapes = new ArrayList();
int backgroundColor = 200;
boolean isClearQueued = false;
boolean isCaptureQueued = false;
boolean isRecording = false;
boolean isGif = false;
boolean isPdf = false;

void setup() {
  Ani.init(this);
  Ani.noAutostart();

  osc = new OscP5(this, 8010);
  videoExport = new VideoExport(this);
  gif = new GifRecorder(this);
  gif.setFramesPerSecond(30);

  noCursor();
  frameRate(30);
  hint(DISABLE_DEPTH_TEST);

  //fullScreen();
  size(1000, 1000, P3D);
  // size(720, 1280, P3D);
  // size(700, 700);
  colorMode(RGB);
  smooth(8);
  strokeJoin(ROUND);
  strokeCap(ROUND);
}

void clear() {
  synchronized(shapes) {
    for (Shape shape : shapes) {
      shape.finish();
    }

    shapes.clear();
  }
}

void draw() {
  if (isPdf && isCaptureQueued) {
    beginRaw(PDF, "exports/######.pdf");
  }

  // lastFrame = get();
  background(backgroundColor);
  // tint(255, 0);
  // image(lastFrame, 0, 0);

  synchronized(shapes) {
    for (Shape shape : shapes) {
      shape.display();
    }

    for (int i = shapes.size() - 1; i >= 0; i--) {
      Shape shape = shapes.get(i);
      if (shape.finished()) {
        shapes.remove(i);
      }
    }


    if (isClearQueued) {
      clear();
      isClearQueued = false;
    }

    if (isCaptureQueued) {
      capture();
      isCaptureQueued = false;
    }

    if (isRecording) {
      if (!isGif) {
        videoExport.saveFrame();
      }
    }
  }
}

void oscEvent(OscMessage m) {
  String[] parts = m.get(0).stringValue().split(":");
  String cmd = parts[0];
  String cmdArg = "";

  if (parts.length > 1) {
    cmdArg = parts[1];
  }

  switch (cmd) {
    case "clear":
      isClearQueued = true;
      break;
    case "record":
      switch (cmdArg) {
        case "start":
        startRecording();
        case "end":
        stopRecording();
        default:
        toggleRecording();
      }
      break;
    case "capture":
      isCaptureQueued = true;
      break;
    default:
      Shape newShape = new Shape(m);

      if (newShape.shape.equals("background")) {
        backgroundColor = newShape.getColor();
      } else {
        synchronized(shapes) {
          shapes.add(newShape);
        }
      }
  }
}

void toggleRecording() {
  if (isRecording) {
    stopRecording();
  } else {
    startRecording();
  }
}

void startRecording() {
  if (isRecording) {
    stopRecording();
  }

  isRecording = true;

  if (isGif) {
    gif.clear();
    gif.record();
  } else {
    Date d = new Date();
    videoExport.setMovieFileName("exports/" + d.getTime() + ".mp4");
    videoExport.startMovie();
  }
}

void stopRecording() {
  if (isRecording) {
    synchronized(shapes) {
      isRecording = false;
      if (isGif) {
        gif.stop();
        gif.save();
      } else {
        videoExport.endMovie();
      }
    }
  }
}

void capture() {
  if (isPdf) {
    endRaw();
  } else {
    saveFrame("exports/######.png");
  }
}

void keyPressed() {
  switch (key) {
    case 'c':
      isClearQueued = true;
      break;
    case 'r':
      toggleRecording();
      break;
    case 's':
      isCaptureQueued = true;
      break;
  }
}

void stop() {
  super.stop();
}

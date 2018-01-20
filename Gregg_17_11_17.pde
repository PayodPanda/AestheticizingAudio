
import processing.sound.*;

SoundFile song;
Amplitude rms;
String[] songs = {
                  "Darkher - Ghost Tears",
                  "Nest - Amroth Brambles",
                  "Nest - Lodge",
                  "Nest - Kyoto",
                  "Nest - Summer Storm",
                  "Nest - Moonbow"
                  };
int songIndex = 0;

float scale=5, 
  smooth_factor=0.5, 
  sum;

float radius, 
  lightRadius, 
  size, 
  stepSize;

float timeOffset = 0, 
  currentTime = 0, 
  bgAlpha = 0;
boolean fade;

void setup() {
  fullScreen(P3D);
  //size(800, 800, P3D);

  song = new SoundFile(this, songs[songIndex]+".wav");
  song.play();
  rms = new Amplitude(this);
  rms.input(song);
  fade = false;
  background(0);
}

void draw() {
  currentTime = (millis()-timeOffset)/1000.0;
  if (currentTime > song.duration()) {
    fade();
  }

  if ((bgAlpha > 0)&&(fade)) {
    bgAlpha -= 0.04;
    fade = true;
    fill(0, bgAlpha);
    rect(0, 0, width, height);
  } else {
    if (fade) {
      fill(0);
      rect(0, 0, width, height);
      println("fadeStop");
      fade = false;
      song = new SoundFile(this, songs[songIndex%songs.length]+".wav");
      song.play();
      rms.input(song);
    }
  }

  sum += (rms.analyze() - sum) * smooth_factor;  // rms.analyze() returns a value between 0 and 1.
  //println(sum);

  radius = 768*width/1920;
  lightRadius = 1000000.0*radius;
  lightRadius = map(sum, 0, 1, 0, 100)*radius;
  size = 240*width/1920;

  stepSize = 2.0 * degrees(size/radius);  // how many degrees should each box on the same circle move wrt the previous one?

  //lights();
  translate(width/2, height/2, 0);
  rotateX(radians(frameCount/15.0));
  rotateY(1 + radians(frameCount/15.0));

  float red = map(sum, 0.15, 0.25, 0, 255);
  float blue = map( currentTime % song.duration(), 0, song.duration(), 0, map(red, 0, 255, map(currentTime % song.duration(), 0, song.duration(), 0, 255), 0));
  ambientLight(red, 0, blue, 0, 0, 0);
  pointLight(255, 0, 0, 0, lightRadius, lightRadius);
  pointLight(0, 255, 0, lightRadius, 0, lightRadius);
  pointLight(0, 0, 255, lightRadius, lightRadius, 0);
  pointLight(255, 255, 0, 0, 0, lightRadius);
  pointLight(0, 255, 255, lightRadius, 0, 0);
  pointLight(255, 0, 255, 0, lightRadius, 0);

  stroke(0, map(sum, 0, 0.3, 32, 0));
  fill(255, map(sum, 0, 1.0, 12, 0));
  noStroke();
  for (float j=-180; j<=180; j+=stepSize) {
    float step = ((degrees(radians(stepSize)/cos(radians(j)))));
    for (float i=-90; i<=90; i+=stepSize) {
      pushMatrix();
      {
        translate(radius * cos(radians(i)) * cos(radians(j)), radius * sin(radians(i)) * cos(radians(j)), radius * sin(radians(j)));
        rotateZ(radians(i+frameCount));
        rotateX(radians(j+frameCount));
        rotateY(radians(j+frameCount));
        box(size + map(sum, 0, 1, -size, size));
      }
      popMatrix();
    }
  }
}

void fade() {
  timeOffset = millis();
  song.stop();
  bgAlpha = 16;
  fade = true;
  println("fadeBegin");
  songIndex++;
}

void keyPressed() {
  if (key == 's') {
    saveFrame("./screens/capture#####.png");
  }

  if (key == 'r') {
    fade();
  }
}
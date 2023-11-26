int numNeedles = 1000;
Needle[] needles; 

void setup() {
  size(800, 800);
  background(255);

  needles = new Needle[numNeedles];
  for (int i = 0; i < numNeedles; i++) {
    needles[i] = new Needle();
  }
}

void draw() {

  for (int i = 0; i < numNeedles; i++) {
    needles[i].move();
    needles[i].display();
  }
}


void drawLineAt(float x1, float y1, float x2, float y2) {
  stroke(0, 50);  // Adjust the alpha value for the lines
  line(x1, y1, x2, y2);
}

class Needle {
  float x, y; // Position of the needle
  float length; // Length of the needle
  float angle; // Angle of the needle
  color needleColor; // Color of the needle

  Needle() {
    x = random(width);
    y = random(height);
    length = 30;
    angle = random(TWO_PI);
    needleColor = color(random(255), random(255), random(255));
  }

  void move() {
    float noiseScale = 0.02;
    float flowFieldScale = 20;
    float noiseValue = noise(x * noiseScale, y * noiseScale);
    float angleOffset = map(noiseValue, 0, 1, -PI, PI);

    angle = noiseValue * TWO_PI + angleOffset;

    x += cos(angle) * 2;
    y += sin(angle) * 2;

    x = (x + width) % width;
    y = (y + height) % height;
  }

  void display() {
    float endX = x + cos(angle) * length;
    float endY = y + sin(angle) * length;

    stroke(needleColor);
    line(x, y, endX, endY);

    noStroke();
    fill(needleColor);
    float circleSize = random(5, 15);
    ellipse(x, y, circleSize, circleSize);
  }
}

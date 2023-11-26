PImage originalImage;

void setup() {
  size(800, 600);
  originalImage = loadImage("last.jpg");  
  originalImage.resize(width, height);
  image(originalImage, 0, 0);
}

void draw() {
  perlinFlowFieldEffect();
}

void perlinFlowFieldEffect() {
  loadPixels();
  originalImage.loadPixels();

  float noiseScale = 0.1;
  float flowFieldScale = 20;
  float colorStrength = 12;

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int loc = x + y * width;

      float noiseValue = noise(x * noiseScale, y * noiseScale);
      float angle = noiseValue * TWO_PI;

      float xOffset = cos(angle) * flowFieldScale;
      float yOffset = sin(angle) * flowFieldScale;

      int newX = constrain(floor(x + xOffset), 0, width - 1);
      int newY = constrain(floor(y + yOffset), 0, height - 1);

      int newLoc = newX + newY * width;
      color pixelColor = originalImage.pixels[newLoc];

      float r = red(pixelColor) + noiseValue * colorStrength;
      float g = green(pixelColor) + noiseValue * colorStrength;
      float b = blue(pixelColor) + noiseValue * colorStrength;

      r = constrain(r, 0, 255);
      g = constrain(g, 0, 255);
      b = constrain(b, 0, 255);

      pixels[loc] = color(r, g, b);
    }
  }

  updatePixels();
}

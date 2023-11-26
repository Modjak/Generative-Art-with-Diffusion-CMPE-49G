class Line {
  PVector pos, vel, acc;
  PVector futV, futP, preP;
  float Vmax, Fmax, ang, r;

  float sradius = 20.0;
  float rand = random(1.0);
  color col;


  Line(PVector pos, color lineColor, float perlinOffset) {
    this.pos = pos;
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);

    r = 4.0;
    float noiseX = pos.x * 0.01;
    float noiseY = pos.y * 0.01;
    Vmax = vmin + map(noise(noiseX, noiseY, perlinOffset), 0, 1, 0, 1) * (vmax - vmin);
    Fmax = fmin + map(noise(noiseX, noiseY, perlinOffset), 0, 1, 0, 1) * (fmax - fmin);

    col = lineColor;
  }


  void update() {
    preP = pos.get();
    vel.add(acc);
    pos.add(vel);
    vel.limit(Vmax);
    acc.mult(0);
    ang = vel.heading();
  }

  void futPos() {
    futV = vel.get();
    futV.normalize();
    futV.mult(2.0);
    futP = PVector.add(futV, pos);
  }

  void follow(Field flow) {
    PVector fo = flow.iter(futP);
    fo.mult(Vmax);
    PVector st = PVector.sub(fo, vel);
    st.limit(Fmax);
    acc.add(st);
  }

  void find(PVector target) {
    PVector fo = PVector.sub(target, pos);
    fo.normalize();
    fo.mult(Vmax);
    PVector st = PVector.sub(fo, vel);
    st.limit(Fmax);
    acc.add(st);
  }

  void spin() {
    PVector futurePos = vel.get();
    futurePos.add(pos);
    float angle = vel.heading() - 0.05;
    PVector spos = new PVector(futurePos.x + cos(angle) * sradius, futurePos.y + sin(angle) * sradius);
    find(spos);
  }

  void edge() {
    if (pos.x < -r) pos.x = width + r;
    if (pos.y < -r) pos.y = height + r;
    if (pos.x > width + r) pos.x = -r;
    if (pos.y > height + r) pos.y = -r;
  }

  void proceed(Field fa, Field fb) {
    futPos();
    follow(fa);
    fb.depo(pos, vel);
    spin();
    update();
    edge();
    stroke(col, 60);
    if (preP.dist(pos) < 30)
      line(preP.x, preP.y, pos.x, pos.y);
  }
}

class Field {
  PVector[][] ff;
  int cols, rows;
  int index;
    
  Field(int r, float perlinOffset) {
    index = r;
    cols = width / index;
    rows = height / index;
    ff = new PVector[cols][rows];
    init(perlinOffset);
  }

  void init(float perlinOffset) {
    for (int i = 0; i < cols; ++i)
      for (int j = 0; j < rows; ++j) {
        float angle = map(noise(i * 0.1, j * 0.1, perlinOffset), 0, 1, 0, TWO_PI);
        ff[i][j] = PVector.fromAngle(angle);
      }
  }

  void depo(PVector loc, PVector ph) {
    int cc = int(constrain(loc.x / index, 0, cols - 1));
    int rr = int(constrain(loc.y / index, 0, rows - 1));
    PVector tmp = ph.get();
    tmp.normalize();
    ff[cc][rr] = tmp;
  }

  PVector iter(PVector iter) {
    int cc = int(constrain(iter.x / index, 0, cols - 1));
    int rr = int(constrain(iter.y / index, 0, rows - 1));
    return ff[cc][rr];
  }
}

Field f, f1;
ArrayList<Line> lines;
ArrayList<Line> lines1;
int num = 30000;
int num1 = 15000;
float vmin = 3;
float vmax = 6;
float fmin = 0.5;
float fmax = 5;

void setup() {
  size(800, 800, P2D);
  float perlinOffset = 0.01;  
  f = new Field(4, perlinOffset);
  f1 = new Field(2, perlinOffset);;
  lines = new ArrayList<Line>();
  lines1 = new ArrayList<Line>();

  for (int i = 0; i < num; i++) {
    PVector pos = new PVector(random(width), random(height));
    Line a = new Line(pos, color(0, 0, 255), perlinOffset); // blue
    lines.add(a);
  }
  for (int i = 0; i < num1; i++) {
    PVector pos1 = new PVector(random(width), random(height));
    Line a1 = new Line(pos1, color(255,238,2),perlinOffset); // yellow
    lines1.add(a1);
  }
  background(0);
}

void draw() {
  noStroke();
  fill(0, 5);
  rect(0, 0, width, height);
  for (Line b : lines1)
    b.proceed(f1, f1);
  for (Line b : lines)
    b.proceed(f1, f);
  for (Line b : lines1)
    b.proceed(f1, f1);
}

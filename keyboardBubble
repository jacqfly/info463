int keySize = 50;
String typedText = "";
String targetText = "THE QUICK BROWN FOX JUMPED OVER THE LAZY DOG";
String[] keys = {
  "QWERTYUIOP",
  "ASDFGHJKL",
  "ZXCVBNM"
};

boolean[][] keyPressed;
boolean timing = false;
long startTime, endTime;
char nextExpectedChar = ' ';
PFont mono;

void setup() {
  size(800, 400);
  mono = createFont("Courier New", 32);
  textFont(mono);
  textAlign(LEFT, BASELINE);

  keyPressed = new boolean[keys.length][];
  for (int i = 0; i < keys.length; i++) {
    keyPressed[i] = new boolean[keys[i].length()];
  }

  noLoop();
  redraw();
}

void draw() {
  background(240);

  // Determine next expected character
  if (typedText.length() < targetText.length()) {
    nextExpectedChar = Character.toUpperCase(targetText.charAt(typedText.length()));
  } else {
    nextExpectedChar = ' ';
  }

  // Draw top text
  fill(100, 0, 0);
  textSize(32);
  text("Target: " + targetText, 50, 40);
  fill(0);
  text("Typed: " + typedText, 50, 80);

  // Draw keys
  textSize(20); // Reset font size for keys
  for (int row = 0; row < keys.length; row++) {
    for (int col = 0; col < keys[row].length(); col++) {
      char keyChar = keys[row].charAt(col);
      int x = 100 + col * keySize + (row * keySize / 2);
      int y = 130 + row * keySize;
      drawKey(keyChar, x, y, keyPressed[row][col], mouseOverKey(x, y));
    }
  }

  // Draw special keys
  drawKey('_', 350, 280, false, mouseOverKey(350, 280)); // Space
  drawKey('<', 400, 280, false, mouseOverKey(400, 280)); // Backspace
  drawKey('⏎', 460, 280, false, mouseOverKey(460, 280)); // Enter
}

void drawKey(char label, int x, int y, boolean isPressed, boolean isHovered) {
  boolean isNext = Character.toUpperCase(label) == nextExpectedChar;
  float scale = isNext ? 1.4 : 1.0;
  int s = int(keySize * scale);
  int offset = (s - keySize) / 2;

  // Background color
  if (isPressed) {
    fill(140);
  } else if (isHovered || isNext) {
    fill(180);
  } else {
    fill(200);
  }

  rect(x - offset, y - offset, s, s, 5);

  fill(0);
  textSize(20 * scale);
  textAlign(CENTER, CENTER);
  text(label, x + keySize / 2, y + keySize / 2);
}

void mouseMoved() {
  redraw();
}

void mousePressed() {
  boolean didPress = false;

  for (int row = 0; row < keys.length; row++) {
    for (int col = 0; col < keys[row].length(); col++) {
      int x = 100 + col * keySize + (row * keySize / 2);
      int y = 130 + row * keySize;

      if (mouseOverKey(x, y)) {
        keyPressed[row][col] = true;
        typedText += keys[row].charAt(col);
        if (!timing) {
          startTime = millis();
          timing = true;
        }
        didPress = true;
      }
    }
  }

  if (mouseOverKey(350, 280)) {
    typedText += " ";
    didPress = true;
  }

  if (mouseOverKey(400, 280) && typedText.length() > 0) {
    typedText = typedText.substring(0, typedText.length() - 1);
    didPress = true;
  }

  if (mouseOverKey(460, 280)) {
    endTime = millis();
    timing = false;
    evaluatePerformance();
    typedText = "";
    didPress = true;
  }

  if (didPress) redraw();
}

void mouseReleased() {
  for (int row = 0; row < keyPressed.length; row++) {
    for (int col = 0; col < keyPressed[row].length; col++) {
      keyPressed[row][col] = false;
    }
  }
  redraw();
}

boolean mouseOverKey(int x, int y) {
  return mouseX >= x && mouseX < x + keySize &&
         mouseY >= y && mouseY < y + keySize;
}

void evaluatePerformance() {
  int timeTaken = (int) ((endTime - startTime) / 1000.0);
  int correctChars = 0;
  int minLen = min(typedText.length(), targetText.length());

  for (int i = 0; i < minLen; i++) {
    if (typedText.charAt(i) == targetText.charAt(i)) {
      correctChars++;
    }
  }

  float accuracy = (correctChars / (float) targetText.length()) * 100;
  println("Time: " + timeTaken + "s, Accuracy: " + accuracy + "%");
}

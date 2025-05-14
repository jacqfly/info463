HashMap<Character, Character> nextLetterMap = new HashMap<Character, Character>();

int keySize = 50;
String typedText = "";
String targetText = "THE QUICK BROWN FOX JUMPED OVER THE LAZY DOG";
String[] keys = {
  "QWERTYUIOP",
  "ASDFGHJKL",
  "ZXCVBNM"
};
PVector[][] animatedPositions;
float easing = 0.1;

boolean[][] keyPressed;
boolean timing = false;
long startTime, endTime;
char nextExpectedChar = ' ';
PFont mono;

void setup() {
  size(800, 400);
  mono = createFont("Courier New", 32, true);
  textFont(mono);
  textAlign(LEFT, BASELINE);

  populateBigramModel();

  keyPressed = new boolean[keys.length][];
  animatedPositions = new PVector[keys.length][];

  for (int i = 0; i < keys.length; i++) {
    keyPressed[i] = new boolean[keys[i].length()];
    animatedPositions[i] = new PVector[keys[i].length()];
    for (int j = 0; j < keys[i].length(); j++) {
      int x = 100 + j * keySize + (i * keySize / 2);
      int y = 130 + i * keySize;
      animatedPositions[i][j] = new PVector(x, y);
    }
  }
  // Add this near the end of setup()
  animatedPositions = new PVector[keys.length + 1][]; // Extra row for special keys
  
  for (int i = 0; i < keys.length; i++) {
    animatedPositions[i] = new PVector[keys[i].length()];
    for (int j = 0; j < keys[i].length(); j++) {
      int x = 100 + j * keySize + (i * keySize / 2);
      int y = 130 + i * keySize;
      animatedPositions[i][j] = new PVector(x, y);
    }
  }
  
  // Row for special keys (index: keys.length)
  animatedPositions[keys.length] = new PVector[3];
  animatedPositions[keys.length][0] = new PVector(300, 280); // Space
  animatedPositions[keys.length][1] = new PVector(400, 280); // Backspace
  animatedPositions[keys.length][2] = new PVector(450, 280); // Enter

}


void draw() {
  background(241, 245, 248);

  // Determine next expected character
  nextExpectedChar = ' ';
  if (typedText.length() > 0) {
    char lastChar = Character.toUpperCase(typedText.charAt(typedText.length() - 1));
    if (nextLetterMap.containsKey(lastChar)) {
      nextExpectedChar = Character.toUpperCase(nextLetterMap.get(lastChar));
    }
  }

  fill(49, 76, 97);
  textSize(23);
  textAlign(LEFT, BASELINE);
  text("Target: " + targetText, 50, 40);
  fill(0);
  text("Typed: " + typedText, 50, 80);

  // Coordinates of the next expected key
  PVector nextPos = null;

  // First find the position of the next expected key
  for (int row = 0; row < keys.length; row++) {
    for (int col = 0; col < keys[row].length(); col++) {
      char keyChar = keys[row].charAt(col);
      if (Character.toUpperCase(keyChar) == nextExpectedChar) {
        int x = 100 + col * keySize + (row * keySize / 2);
        int y = 130 + row * keySize;
        nextPos = new PVector(x + keySize / 2, y + keySize / 2);
      }
    }
  }

  // Update and draw keys with animation
  for (int row = 0; row < keys.length; row++) {
    for (int col = 0; col < keys[row].length(); col++) {
      char keyChar = keys[row].charAt(col);
      int baseX = 100 + col * keySize + (row * keySize / 2);
      int baseY = 130 + row * keySize;

      PVector target = new PVector(baseX, baseY);

      if (nextPos != null && Character.toUpperCase(keyChar) != nextExpectedChar) {
        PVector current = new PVector(baseX + keySize / 2, baseY + keySize / 2);
        PVector push = PVector.sub(current, nextPos);
        float dist = push.mag();

        if (dist < 200) {
          push.normalize();
          push.mult((200 - dist) / 10);
          target.add(push);
        }
      }

      // Animate current position toward target
      PVector currentPos = animatedPositions[row][col];
      currentPos.lerp(target, easing);

      drawKey(keyChar, int(currentPos.x), int(currentPos.y), keyPressed[row][col], mouseOverKey(int(currentPos.x), int(currentPos.y)));
    }
  }

  // Draw special keys (not animated)
  drawKey('_', 300, 280, false, mouseOverKey(300, 280));
  drawKey('␡', 400, 280, false, mouseOverKey(400, 280));
  drawKey('⏎', 450, 280, false, mouseOverKey(450, 280));
}


void drawKey(char label, int x, int y, boolean isPressed, boolean isHovered) {
  boolean isNext = Character.toUpperCase(label) == nextExpectedChar;
  float scale = isNext ? 1.4 : 1.0;
  int s = int(keySize * scale);
  int offset = (s - keySize) / 2;

  stroke (46, 67, 88);
  
  // Background color
  if (isPressed) {
    fill(140);
  } else if (isHovered || isNext) {
    fill(180);
  } else {
    fill(200);
  }
  
  color normalColor = color(175, 194, 213);  // Light blue for normal state
  color hoverColor = color(125, 156, 187);   // Lighter blue when hovered
  color pressedColor = color(81, 118, 155); // Even lighter blue when pressed
  
  // Change color based on the state (pressed, hovered, or normal)
  fill(isPressed ? pressedColor : (isHovered ? hoverColor : normalColor));

  rect(x - offset, y - offset, s, s, 50); //5

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
      PVector pos = animatedPositions[row][col];
      if (mouseOverKey((int)pos.x, (int)pos.y)) {
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
  
  // Check animated positions of special keys
  if (mouseOverKey((int)animatedPositions[keys.length][0].x, (int)animatedPositions[keys.length][0].y)) {
    typedText += " ";
    didPress = true;
  }
  
  if (mouseOverKey((int)animatedPositions[keys.length][1].x, (int)animatedPositions[keys.length][1].y) && typedText.length() > 0) {
    typedText = typedText.substring(0, typedText.length() - 1);
    didPress = true;
  }
  
  if (mouseOverKey((int)animatedPositions[keys.length][2].x, (int)animatedPositions[keys.length][2].y)) {
    endTime = millis();
    timing = false;
    evaluatePerformance();
    typedText = "";
    didPress = true;
  }
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

void populateBigramModel() {
  nextLetterMap.put('A', 'N');  // "AN", "AT"
  nextLetterMap.put('B', 'E');  // "BE", "BA"
  nextLetterMap.put('C', 'H');  // "CH", "CO"
  nextLetterMap.put('D', 'E');  // "DE", "DO"
  nextLetterMap.put('E', 'R');  // "ER", "EN"
  nextLetterMap.put('F', 'O');  // "FO", "FR"
  nextLetterMap.put('G', 'H');  // "GH", "GE"
  nextLetterMap.put('H', 'E');  // "HE", "HI"
  nextLetterMap.put('I', 'N');  // "IN", "IS"
  nextLetterMap.put('J', 'U');  // "JU"
  nextLetterMap.put('K', 'E');  // "KE"
  nextLetterMap.put('L', 'E');  // "LE", "LY"
  nextLetterMap.put('M', 'E');  // "ME", "MO"
  nextLetterMap.put('N', 'T');  // "NT", "NE"
  nextLetterMap.put('O', 'N');  // "ON", "OU"
  nextLetterMap.put('P', 'R');  // "PR", "PE"
  nextLetterMap.put('Q', 'U');  // "QU"
  nextLetterMap.put('R', 'E');  // "RE", "RI"
  nextLetterMap.put('S', 'T');  // "ST", "SE"
  nextLetterMap.put('T', 'H');  // "TH", "TI"
  nextLetterMap.put('U', 'R');  // "UR", "UN"
  nextLetterMap.put('V', 'E');  // "VE"
  nextLetterMap.put('W', 'A');  // "WA", "WH"
  nextLetterMap.put('X', 'T');  // "XT"
  nextLetterMap.put('Y', 'O');  // "YO", "YE"
  nextLetterMap.put('Z', 'E');  // "ZE"

  nextLetterMap.put(' ', 'T');  // Start of a sentence — common to start with "The"
}

/*
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "Arduino.h"
#include "Wire.h"

#include <cstdint>
#include <vector>

namespace {
constexpr int kTargetAddress = 0x42;
constexpr int kTransferSize = 16;
std::vector<uint8_t> buffer(kTransferSize, 0);
}

void requestEvent() {
  Wire.write(buffer.data(), kTransferSize);
}

void receiveEvent(int count) {
  for (int i = 0; i < count && i < kTransferSize; ++i) {
    buffer[i] = Wire.read();
    Serial.print(buffer[i]);
  }
  Serial.println();
}

void setup() {
  Serial.begin(115200);
  // Turn on Status LED to show the board is on.
  pinMode(PIN_LED_STATUS, OUTPUT);
  digitalWrite(PIN_LED_STATUS, HIGH);
  Serial.println("Arduino I2C Target Example!");

  Wire.begin(kTargetAddress);
  Wire.onReceive(receiveEvent);
  Wire.onRequest(requestEvent);
}

void loop() {}
// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <cstdio>

#include "libs/base/gpio.h"
#include "libs/camera/camera.h"
#include "libs/rpc/rpc_http_server.h"
#include "libs/testlib/test_lib.h"
#include "third_party/freertos_kernel/include/FreeRTOS.h"
#include "third_party/freertos_kernel/include/task.h"

// A simple example that captures an image and served over the
// 'get_captured_image' rpc call when the User Button is clicked. Note: the rpc
// call will fail if the image was never captured.

namespace coralmicro {
void get_captured_image(struct jsonrpc_request* request) {
  int width = coralmicro::CameraTask::kWidth;
  int height = coralmicro::CameraTask::kHeight;
  if (!testlib::JsonRpcGetIntegerParam(request, "width", &width)) {
    return;
  }
  if (!testlib::JsonRpcGetIntegerParam(request, "height", &height)) {
    return;
  }
  coralmicro::camera::Format format = coralmicro::camera::Format::kRgb;
  std::vector<uint8_t> image(width * height *
                             coralmicro::CameraTask::FormatToBPP(format));
  coralmicro::camera::FrameFormat fmt{
      /*fmt=*/format,
      /*filter=*/coralmicro::camera::FilterMethod::kBilinear,
      /*rotation=*/coralmicro::camera::Rotation::k0,
      /*width=*/width,
      /*height=*/height,
      /*preserve_ratio=*/false,
      /*buffer=*/image.data(),
      /*white_balance=*/true};
  if (!coralmicro::CameraTask::GetSingleton()->GetFrame({fmt})) {
    jsonrpc_return_error(request, -1, "Failed to get image from camera.",
                         nullptr);
    return;
  }

  jsonrpc_return_success(request, "{%Q: %d, %Q: %d, %Q: %V}", "width", width,
                         "height", height, "base64_data", image.size(),
                         image.data());
}

[[noreturn]] void Main() {
  // Starting Camera in triggered mode.
  coralmicro::CameraTask::GetSingleton()->SetPower(true);
  coralmicro::CameraTask::GetSingleton()->Enable(
      coralmicro::camera::Mode::kTrigger);

  // Set up an RPC server that serves the latest image.
  jsonrpc_export("get_captured_image", coralmicro::get_captured_image);
  coralmicro::UseHttpServer(new coralmicro::JsonRpcHttpServer);

  // Get main task handle.
  auto main_task_handle = xTaskGetCurrentTaskHandle();

  // Register callback for the user button.
  printf("Press the user button to take a picture.\r\n");
  coralmicro::GpioRegisterIrqHandler(
      coralmicro::Gpio::kUserButton,
      [&main_task_handle]() { xTaskResumeFromISR(main_task_handle); });
  while (true) {
    vTaskSuspend(nullptr);
    coralmicro::CameraTask::GetSingleton()->Trigger();
    printf("Picture taken\r\n");
  }
}

}  // namespace coralmicro

extern "C" void app_main(void* param) {
  (void)param;
  coralmicro::Main();
  vTaskSuspend(nullptr);
}
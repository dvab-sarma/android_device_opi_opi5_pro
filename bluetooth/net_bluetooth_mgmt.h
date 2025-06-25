/*
 * Copyright (C) 2022 The Android Open Source Project
 * Copyright (C) 2024 KonstaKANG
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#pragma once

#include <unistd.h>

namespace aidl::android::hardware::bluetooth::impl {

class NetBluetoothMgmt {
 public:
  NetBluetoothMgmt() {}
  ~NetBluetoothMgmt() {
    ::close(bt_fd_);
  }

  int openHci(int hci_interface = 0);
  void closeHci();

 private:
  int waitHciDev(int hci_interface);
  int findRfKill();
  int rfKill(int block);
  char *rfkill_state_;

  // File descriptor opened to the bluetooth user channel.
  int bt_fd_{-1};
};

}  // namespace aidl::android::hardware::bluetooth::impl

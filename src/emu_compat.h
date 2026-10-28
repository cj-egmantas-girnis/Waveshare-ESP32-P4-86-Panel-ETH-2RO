#pragma once
// Host-build shims for ESP-IDF calls used in lambdas (emulator only).
#include "esphome/core/helpers.h"
static inline uint32_t esp_random() { return esphome::random_uint32(); }

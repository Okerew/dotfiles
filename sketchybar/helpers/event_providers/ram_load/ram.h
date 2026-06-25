#ifndef RAM_H
#define RAM_H

#include <mach/mach.h>
#include <mach/mach_host.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/sysctl.h>
#include <unistd.h>

struct ram {
  double usage_percent;
};

static inline uint64_t get_total_memory() {
  uint64_t total_memory;
  size_t size = sizeof(total_memory);
  if (sysctlbyname("hw.memsize", &total_memory, &size, NULL, 0) != 0) {
    return 0;
  }
  return total_memory;
}

static inline void ram_init(struct ram *ram) { ram->usage_percent = 0.0; }

static inline void ram_update(struct ram *ram) {
  vm_statistics64_data_t vm_stat;
  natural_t count = HOST_VM_INFO64_COUNT;
  host_t host = mach_host_self();

  if (host_statistics64(host, HOST_VM_INFO64, (host_info64_t)&vm_stat,
                        &count) != KERN_SUCCESS) {
    return;
  }

  vm_size_t page_size;
  if (host_page_size(host, &page_size) != KERN_SUCCESS) {
    page_size = 4096;
  }

  uint64_t used_pages =
      vm_stat.active_count + vm_stat.wire_count + vm_stat.compressor_page_count;
  uint64_t used_memory = used_pages * page_size;

  uint64_t total_memory = get_total_memory();
  if (total_memory == 0) {
    return;
  }

  ram->usage_percent = ((double)used_memory / (double)total_memory) * 100.0;
}

#endif

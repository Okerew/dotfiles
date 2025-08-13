#include <mach/mach.h>
#include <mach/mach_host.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/sysctl.h>
#include <unistd.h>

uint64_t get_total_memory() {
  uint64_t total_memory;
  size_t size = sizeof(total_memory);
  if (sysctlbyname("hw.memsize", &total_memory, &size, NULL, 0) != 0) {
    return 0;
  }
  return total_memory;
}

int get_memory_usage(double *usage_percent) {
  vm_statistics64_data_t vm_stat;
  natural_t count = HOST_VM_INFO64_COUNT;
  host_t host = mach_host_self();

  if (host_statistics64(host, HOST_VM_INFO64, (host_info64_t)&vm_stat,
                        &count) != KERN_SUCCESS) {
    return -1;
  }

  // Get page size
  vm_size_t page_size;
  if (host_page_size(host, &page_size) != KERN_SUCCESS) {
    page_size = 4096; // Default page size
  }

  // Calculate memory usage to match Activity Monitor
  // Used memory = Active + Wired + Compressed (excluding inactive)
  uint64_t used_pages =
      vm_stat.active_count + vm_stat.wire_count + vm_stat.compressor_page_count;
  uint64_t used_memory = used_pages * page_size;

  // Get total memory
  uint64_t total_memory = get_total_memory();
  if (total_memory == 0) {
    return -1;
  }

  // Calculate usage percentage
  *usage_percent = ((double)used_memory / (double)total_memory) * 100.0;

  return 0;
}

int main(int argc, char *argv[]) {
  if (argc != 3) {
    fprintf(stderr, "Usage: %s <event_name> <interval_seconds>\n", argv[0]);
    return 1;
  }

  char *event_name = argv[1];
  double interval = atof(argv[2]);

  if (interval <= 0) {
    fprintf(stderr, "Error: Interval must be positive\n");
    return 1;
  }

  printf("Starting RAM monitor with event '%s' every %.1f seconds\n",
         event_name, interval);

  while (1) {
    double usage_percent;
    if (get_memory_usage(&usage_percent) == 0) {
      // Send the event to sketchybar
      char command[256];
      snprintf(command, sizeof(command),
               "sketchybar --trigger %s ram_usage=%.1f", event_name,
               usage_percent);
      system(command);
    } else {
      fprintf(stderr, "Error getting memory usage\n");
    }

    sleep((int)interval);
    usleep((int)((interval - (int)interval) * 1000000));
  }

  return 0;
}

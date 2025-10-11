#include "../sketchybar.h"
#include "ram.h"

int main(int argc, char **argv) {
  float update_freq;
  if (argc < 3 || (sscanf(argv[2], "%f", &update_freq) != 1)) {
    printf("Usage: %s \"<event-name>\" \"<event_freq>\"\n", argv[0]);
    exit(1);
  }

  alarm(0);
  struct ram ram;
  ram_init(&ram);

  char event_message[512];
  snprintf(event_message, 512, "--add event '%s'", argv[1]);
  sketchybar(event_message);

  char trigger_message[512];
  for (;;) {
    ram_update(&ram);

    snprintf(trigger_message, 512, "--trigger '%s' ram_usage='%.1f'", argv[1],
             ram.usage_percent);

    sketchybar(trigger_message);
    usleep(update_freq * 1000000);
  }
  return 0;
}

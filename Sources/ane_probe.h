#ifndef ANE_PROBE_H
#define ANE_PROBE_H
#include <stdint.h>
typedef void (*ane_log_fn)(const char *msg);
int ane_probe_services(ane_log_fn log);
int ane_probe_service_name(const char *name, ane_log_fn log);
#endif

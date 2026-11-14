#include "ane_probe.h"
#include <stdio.h>
#include <stdarg.h>
#include <IOKit/IOKitLib.h>
#include <mach/mach.h>

static void logf_ane(ane_log_fn log, const char *fmt, ...) {
    if (!log) return;
    char buf[512];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);
    log(buf);
}

int ane_probe_service_name(const char *name, ane_log_fn log) {
    logf_ane(log, "[ANE] probing service: %s", name);
    io_service_t svc = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(name));
    if (svc == IO_OBJECT_NULL) {
        logf_ane(log, "[ANE]   service not found");
        return -1;
    }

    logf_ane(log, "[ANE]   service found");
    const int types[] = {0, 1, 2, 3, 4, 5, 6, 7, 8};
    int first_ok = -1;

    for (unsigned i = 0; i < sizeof(types) / sizeof(types[0]); i++) {
        io_connect_t conn = IO_OBJECT_NULL;
        kern_return_t kr = IOServiceOpen(svc, mach_task_self(), types[i], &conn);
        if (kr == KERN_SUCCESS && conn != IO_OBJECT_NULL) {
            logf_ane(log, "[ANE]   client type=%d opened", types[i]);
            IOServiceClose(conn);
            if (first_ok < 0) first_ok = types[i];
        } else {
            logf_ane(log, "[ANE]   client type=%d failed (kr=0x%x)", types[i], kr);
        }
    }

    IOObjectRelease(svc);
    return first_ok;
}

int ane_probe_services(ane_log_fn log) {
    static const char *names[] = {
        "H11ANEIn", "H13ANEIn", "H14ANEIn", "H15ANEIn", "H16ANEIn",
        "AppleH11ANEIn", "AppleH13ANEIn", "AppleH14ANEIn", "AppleH15ANEIn",
        "AppleH16ANEIn", "ANECompilerService", "AppleNeuralEngine"
    };
    int mask = 0;
    logf_ane(log, "[ANE] === service reachability probe ===");
    for (unsigned i = 0; i < sizeof(names) / sizeof(names[0]); i++) {
        int type = ane_probe_service_name(names[i], log);
        if (type >= 0) {
            mask |= (1 << i);
            logf_ane(log, "[ANE] %s: at least one client type opened (first=%d)", names[i], type);
        }
    }
    logf_ane(log, "[ANE] === result mask: 0x%x ===", mask);
    logf_ane(log, "[ANE] Reachability is not evidence of a vulnerability or exploitability.");
    return mask;
}

proc procpsHertzGet*(): clong {.
  importc: "procps_hertz_get", header: "<libproc2/misc.h>"
.}

proc procpsPidLength*(): cuint {.
  importc: "procps_pid_length", header: "<libproc2/misc.h>"
.}

template linux_Version*(x, y, z: untyped): untyped =
  (0x10000 * ((x) and 0x7fff) + 0x100 * ((y) and 0xff) + ((z) and 0xff))

template linux_Version_Major*(x: untyped): untyped =
  (((x) shr 16) and 0xFF)

template linux_Version_Minor*(x: untyped): untyped =
  (((x) shr 8) and 0xFF)

template linux_Version_Patch*(x: untyped): untyped =
  ((x) and 0xFF)

proc procpsLinuxVersion*(): cint {.
  importc: "procps_linux_version", header: "<libproc2/misc.h>"
.}

proc procpsLoadavg*(
  av1: ptr cdouble, av5: ptr cdouble, av15: ptr cdouble
): cint {.importc: "procps_loadavg", header: "<libproc2/misc.h>".}

proc procpsUptime*(
  uptimeSecs: ptr cdouble, idleSecs: ptr cdouble
): cint {.importc: "procps_uptime", header: "<libproc2/misc.h>".}

proc procpsUsers*(): cint {.importc: "procps_users", header: "<libproc2/misc.h>".}

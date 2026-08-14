{.passC: staticExec("pkg-config --cflags gio-2.0 glib-2.0").}
{.passL: staticExec("pkg-config --libs gio-2.0 glib-2.0").}

import std/options
import std/strutils

type
  GMainLoop {.importc: "GMainLoop", header: "<glib.h>".} = object
  GDBusConnection {.importc: "GDBusConnection", header: "<gio/gio.h>".} = object
  GVariant {.importc: "GVariant", header: "<glib.h>".} = object
  GVariantIter {.importc: "GVariantIter", header: "<glib.h>".} = object
  ConstCString {.importc: "const char*", header: "<glib.h>".} = cstring

  GBusType = enum
    G_BUS_TYPE_STARTER = -1
    G_BUS_TYPE_NONE = 0
    G_BUS_TYPE_SYSTEM = 1
    G_BUS_TYPE_SESSION = 2

  GDBusSignalFlags = enum
    G_DBUS_SIGNAL_FLAGS_NONE = 0

  GDBusCallFlags = enum
    G_DBUS_CALL_FLAGS_NONE = 0

type GDBusSignalCallback = proc(
  connection: ptr GDBusConnection,
  senderName: ConstCString,
  objectPath: ConstCString,
  interfaceName: ConstCString,
  signalName: ConstCString,
  parameters: ptr GVariant,
  userData: pointer,
) {.cdecl.}

proc g_main_loop_new(
  context: pointer, isRunning: bool
): ptr GMainLoop {.importc, header: "<glib.h>".}

proc g_main_loop_run(loop: ptr GMainLoop) {.importc, header: "<glib.h>".}
proc g_bus_get_sync(
  busType: GBusType, cancellable: pointer, error: pointer
): ptr GDBusConnection {.importc, header: "<gio/gio.h>".}

proc g_dbus_connection_signal_subscribe(
  connection: ptr GDBusConnection,
  sender: cstring,
  interfaceName: cstring,
  member: cstring,
  objectPath: cstring,
  arg0: cstring,
  flags: GDBusSignalFlags,
  callback: GDBusSignalCallback,
  userData: pointer,
  userDataDestroyNotify: pointer,
): cuint {.importc, header: "<gio/gio.h>".}

proc g_dbus_connection_call_sync(
  connection: ptr GDBusConnection,
  busName: cstring,
  objectPath: cstring,
  interfaceName: cstring,
  methodName: cstring,
  parameters: ptr GVariant,
  replyType: pointer,
  flags: GDBusCallFlags,
  timeoutMsec: cint,
  cancellable: pointer,
  error: pointer,
): ptr GVariant {.importc, header: "<gio/gio.h>".}

proc g_variant_new(
  format: cstring
): ptr GVariant {.varargs, importc, header: "<glib.h>".}

proc g_variant_get(
  v: ptr GVariant, format: cstring
) {.varargs, importc, header: "<glib.h>".}

proc g_variant_iter_init(
  iter: ptr GVariantIter, value: ptr GVariant
): csize_t {.importc, header: "<glib.h>".}

proc g_variant_iter_loop(
  iter: ptr GVariantIter, format: cstring
): bool {.varargs, importc, header: "<glib.h>".}

proc g_variant_unref(v: ptr GVariant) {.importc, header: "<glib.h>".}

proc checkOwnerMatch(
    conn: ptr GDBusConnection, name: cstring, targetSender: ConstCString
): bool =
  let ownerRes = g_dbus_connection_call_sync(
    conn,
    "org.freedesktop.DBus",
    "/org/freedesktop/DBus",
    "org.freedesktop.DBus",
    "GetNameOwner",
    g_variant_new("(s)", name),
    nil,
    G_DBUS_CALL_FLAGS_NONE,
    1000,
    nil,
    nil,
  )
  if ownerRes == nil:
    return false
  defer:
    g_variant_unref(ownerRes)

  var ownerVal: cstring
  g_variant_get(ownerRes, "(s)", addr ownerVal)
  return $ownerVal == $targetSender

proc getFirstMprisName(conn: ptr GDBusConnection): Option[string] =
  let namesRes = g_dbus_connection_call_sync(
    conn, "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus",
    "ListNames", nil, nil, G_DBUS_CALL_FLAGS_NONE, 1000, nil, nil,
  )
  if namesRes == nil:
    return none(string)
  defer:
    g_variant_unref(namesRes)

  var arrayVar: ptr GVariant
  g_variant_get(namesRes, "(@as)", addr arrayVar)
  if arrayVar == nil:
    return none(string)
  defer:
    g_variant_unref(arrayVar)

  var iter: GVariantIter
  discard g_variant_iter_init(addr iter, arrayVar)

  var nameStr: cstring
  while g_variant_iter_loop(addr iter, "s", addr nameStr):
    let sName = $nameStr
    if sName.startsWith("org.mpris.MediaPlayer2."):
      return some(sName)

  return none(string)

proc getMprisNameFromSender(
    conn: ptr GDBusConnection, senderName: ConstCString
): Option[string] =
  let namesRes = g_dbus_connection_call_sync(
    conn, "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus",
    "ListNames", nil, nil, G_DBUS_CALL_FLAGS_NONE, 1000, nil, nil,
  )
  if namesRes == nil:
    return none(string)
  defer:
    g_variant_unref(namesRes)

  var arrayVar: ptr GVariant
  g_variant_get(namesRes, "(@as)", addr arrayVar)
  if arrayVar == nil:
    return none(string)
  defer:
    g_variant_unref(arrayVar)

  var iter: GVariantIter
  discard g_variant_iter_init(addr iter, arrayVar)

  var nameStr: cstring
  while g_variant_iter_loop(addr iter, "s", addr nameStr):
    let sName = $nameStr
    if sName.startsWith("org.mpris.MediaPlayer2."):
      if checkOwnerMatch(conn, nameStr, senderName):
        return some(sName)

  return none(string)

proc onPropertiesChanged(
    connection: ptr GDBusConnection,
    senderName: ConstCString,
    objectPath: ConstCString,
    interfaceName: ConstCString,
    signalName: ConstCString,
    parameters: ptr GVariant,
    userData: pointer,
) {.cdecl.} =
  if parameters == nil:
    return

  var
    ifaceName: cstring
    changedProps: ptr GVariant

  g_variant_get(parameters, "(&s@a{sv}*)", addr ifaceName, addr changedProps)
  if changedProps == nil:
    return

  defer:
    g_variant_unref(changedProps)

  if $ifaceName != "org.mpris.MediaPlayer2.Player":
    return

  let mprisName = getMprisNameFromSender(connection, senderName)
  if mprisName.isSome():
    echo mprisName.get()

proc main() =
  let conn = g_bus_get_sync(G_BUS_TYPE_SESSION, nil, nil)
  if conn == nil:
    quit(1)

  let firstBusName = conn.getFirstMprisName()
  if firstBusName.isSome():
    echo firstBusName.get()

  discard g_dbus_connection_signal_subscribe(
    conn, nil, "org.freedesktop.DBus.Properties", "PropertiesChanged",
    "/org/mpris/MediaPlayer2", nil, G_DBUS_SIGNAL_FLAGS_NONE, onPropertiesChanged, nil,
    nil,
  )

  let loop = g_main_loop_new(nil, false)
  g_main_loop_run(loop)

main()

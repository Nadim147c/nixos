import std/[os, posix, strutils]

const uwsmBin {.strdefine: "uwsmBin".} = getEnv("UWSM_BIN", "uwsm")

type GlibcOption {.importc: "struct option", header: "<getopt.h>".} = object
  name: cstring
  has_arg: cint
  flag: ptr cint
  val: cint

const
  no_argument: cint = 0
  required_argument: cint = 1

var optind {.importc: "optind", header: "<getopt.h>".}: cint
var optarg {.importc: "optarg", header: "<getopt.h>".}: cstring

proc getopt_long(
  argc: cint,
  argv: cstringArray,
  optstring: cstring,
  longopts: ptr GlibcOption,
  longindex: ptr cint,
): cint {.importc: "getopt_long", header: "<getopt.h>".}

proc printUsage() =
  stderr.writeLine("Usage: control [options] <program> [args...]")
  stderr.writeLine("  -c, --cpu <limit>      CPU limit (e.g., 50% or 2)")
  stderr.writeLine("  -m, --memory <limit>   Memory limit (e.g., 512M or 1G)")
  stderr.writeLine("  -s, --scope            Run in scope mode (foreground)")
  stderr.writeLine("  -h, --help             Show this help message")
  stderr.writeLine("")
  stderr.writeLine("Embedded uwsm binary: " & uwsmBin)

proc main() =
  var
    cpu = ""
    mem = ""
    scope = false

  var longOpts = [
    GlibcOption(name: "cpu", has_arg: required_argument, flag: nil, val: cint('c')),
    GlibcOption(name: "memory", has_arg: required_argument, flag: nil, val: cint('m')),
    GlibcOption(name: "scope", has_arg: no_argument, flag: nil, val: cint('s')),
    GlibcOption(name: "help", has_arg: no_argument, flag: nil, val: cint('h')),
    GlibcOption(name: nil, has_arg: 0, flag: nil, val: 0),
  ]

  let argc = cint(paramCount() + 1)
  var rawArgs = newSeq[string](argc.int)
  rawArgs[0] = getAppFilename()
  for i in 1 .. paramCount():
    rawArgs[i] = paramStr(i)

  let cargv = allocCStringArray(rawArgs)
  defer:
    deallocCStringArray(cargv)

  var longIdx: cint = 0
  while true:
    let ch = getopt_long(argc, cargv, "+c:m:sh", addr longOpts[0], addr longIdx)
    if ch == -1:
      break
    case char(ch)
    of 'c':
      cpu = $optarg
    of 'm':
      mem = $optarg
    of 's':
      scope = true
    of 'h':
      printUsage()
      quit(0)
    else:
      printUsage()
      quit(1)

  if optind >= argc:
    printUsage()
    quit(1)

  var targetArgs: seq[string] = @[]
  for i in optind.int ..< argc.int:
    targetArgs.add($cargv[i])

  var uwsmArgs = @["app"]

  if cpu.len > 0:
    uwsmArgs.add(["-p", "CPUQuota=" & cpu])
  if mem.len > 0:
    uwsmArgs.add(["-p", "MemoryMax=" & mem])

  if scope:
    uwsmArgs.add(["-t", "scope"])
  else:
    uwsmArgs.add(["-t", "service"])

  uwsmArgs.add("--")
  uwsmArgs.add(targetArgs)

  stdout.writeLine("Running: " & uwsmBin & " " & uwsmArgs.join(" "))
  stdout.flushFile()

  let execArgv = allocCStringArray(@[uwsmBin] & uwsmArgs)
  defer:
    deallocCStringArray(execArgv)

  discard execvp(uwsmBin, execArgv)
  stderr.writeLine("Execution failed: " & osErrorMsg(osLastError()))
  quit(1)

when isMainModule:
  main()

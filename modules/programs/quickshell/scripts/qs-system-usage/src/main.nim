import std/[json, times, os, tables, strutils, posix]

import ./meminfo
import ./misc

const
  AF_NETLINK = 16.cint
  NETLINK_ROUTE = 0.cint
  RTM_GETLINK = 18.uint16
  RTM_NEWLINK = 16.uint16
  NLM_F_REQUEST = 1.uint16
  NLM_F_DUMP = 0x300.uint16
  NLMSG_DONE = 0x3.uint16
  IFLA_IFNAME = 3.uint16
  IFLA_STATS64 = 23.uint16
  SC_NPROCESSORS_ONLN = 84.cint

type
  nlmsghdr = object
    nlmsg_len: uint32
    nlmsg_type: uint16
    nlmsg_flags: uint16
    nlmsg_seq: uint32
    nlmsg_pid: uint32

  ifinfomsg = object
    ifi_family: uint8
    ifi_type: uint16
    ifi_index: cint
    ifi_flags: uint32
    ifi_change: uint32

  rtattr = object
    rta_len: uint16
    rta_type: uint16

  rtnl_link_stats64 = object
    rx_packets*: uint64
    tx_packets*: uint64
    rx_bytes*: uint64
    tx_bytes*: uint64
    rx_errors*: uint64
    tx_errors*: uint64
    rx_dropped*: uint64
    tx_dropped*: uint64
    multicast*: uint64
    collisions*: uint64
    rx_length_errors*: uint64
    rx_over_errors*: uint64
    rx_crc_errors*: uint64
    rx_frame_errors*: uint64
    rx_fifo_errors*: uint64
    rx_missed_errors*: uint64
    tx_aborted_errors*: uint64
    tx_carrier_errors*: uint64
    tx_fifo_errors*: uint64
    tx_heartbeat_errors*: uint64
    tx_window_errors*: uint64
    rx_compressed*: uint64
    tx_compressed*: uint64

type
  NetInterfaceStats = object
    name: string
    totalUp: uint64
    totalDown: uint64
    up: uint64
    down: uint64
    total: uint64

  NetSpeedCalculator = object
    interfaces: Table[string, NetInterfaceStats]
    current: NetInterfaceStats
    lastTime: times.Time

proc readUintFast(path: string): uint64 =
  var f: File
  if open(f, path):
    var buf: array[64, char]
    let bytesRead = readBuffer(f, addr buf[0], 64)
    close(f)
    var val: uint64 = 0
    for i in 0 ..< bytesRead:
      let c = buf[i]
      if c >= '0' and c <= '9':
        val = val * 10 + uint64(ord(c) - ord('0'))
      elif c == '\n' or c == '\r':
        break
    return val
  return 0

proc formatBytes(bytesCount: uint64): string =
  const
    kib = 1024'f64
    mib = 1024'f64 * kib
    gib = 1024'f64 * mib

  let bytesFloat = bytesCount.float64
  if bytesFloat >= gib:
    return (bytesFloat / gib).formatFloat(ffDecimal, 2) & " GiB"
  elif bytesFloat >= mib:
    return (bytesFloat / mib).formatFloat(ffDecimal, 2) & " MiB"
  elif bytesFloat >= kib:
    return (bytesFloat / kib).formatFloat(ffDecimal, 2) & " KiB"
  else:
    return $bytesCount & " B"

proc formatSpeed(bytesPerSec: uint64): string =
  bytesPerSec.formatBytes() & "/s"

var lastUptime, lastIdle: cdouble

proc getCPUState(outMap: var Table[string, JsonNode]) =
  let numCores {.global.} = sysconf(SC_NPROCESSORS_ONLN)
  var uptime, idle: cdouble

  if procpsUptime(addr uptime, addr idle) != -1 and numCores > 0 and uptime > 0:
    let totalCpuTime = uptime * cdouble(numCores)
    defer:
      lastUptime = totalCpuTime
      lastIdle = idle

    let uptimeDelta = totalCpuTime - lastUptime
    let idleDelta = idle - lastIdle

    var normalizedUtil = 1.0 - (idleDelta / uptimeDelta)

    if normalizedUtil < 0.0:
      normalizedUtil = 0.0
    elif normalizedUtil > 1.0:
      normalizedUtil = 1.0
    outMap["cpuUtilization"] = %normalizedUtil
  else:
    outMap["cpuUtilization"] = %0.0

  var totalFreq: uint64 = 0
  var freqCount = 0
  for i in 0 .. 128:
    let val =
      readUintFast("/sys/devices/system/cpu/cpu" & $i & "/cpufreq/scaling_cur_freq")
    if val == 0:
      break
    totalFreq += val
    freqCount += 1

  var totalTemp: float64 = 0.0
  var tempCount = 0
  for i in 0 .. 16:
    let val = readUintFast("/sys/class/thermal/thermal_zone" & $i & "/temp")
    if val == 0:
      break
    totalTemp += val.float64 / 1000.0
    tempCount += 1

  let avgFreq =
    if freqCount > 0:
      totalFreq div freqCount.uint64
    else:
      0
  outMap["cpuFrequency"] = %avgFreq

  let freqKhz = avgFreq.float64
  let freqStr =
    if freqKhz >= 1_000_000.0:
      (freqKhz / 1_000_000.0).formatFloat(ffDecimal, 2) & " GHz"
    elif freqKhz >= 1_000.0:
      (freqKhz / 1_000.0).formatFloat(ffDecimal, 0) & " MHz"
    else:
      $avgFreq & " kHz"

  outMap["cpuFrequencyString"] = %freqStr

  let avgTemp =
    if tempCount > 0:
      totalTemp / tempCount.float64
    else:
      0.0
  outMap["cpuTemperature"] = %avgTemp
  outMap["cpuTemperatureString"] = %(avgTemp.formatFloat(ffDecimal, 2) & " °C")

proc updateNetStatsDirect(sc: var NetSpeedCalculator, intervalSec: float64) =
  let fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE)
  if fd.int < 0:
    return

  type Request = object
    hdr: nlmsghdr
    msg: ifinfomsg

  var req: Request
  req.hdr.nlmsg_len = uint32(sizeof(Request))
  req.hdr.nlmsg_type = RTM_GETLINK
  req.hdr.nlmsg_flags = uint16(NLM_F_REQUEST or NLM_F_DUMP)
  req.msg.ifi_family = AF_UNSPEC.uint8

  if send(fd, addr req, sizeof(Request), 0) < 0:
    discard close(fd)
    return

  var buf: array[8192, char]
  var maxSpeed: uint64 = 0

  while true:
    let len = recv(fd, addr buf[0], sizeof(buf), 0)
    if len <= 0:
      break

    var h = cast[ptr nlmsghdr](addr buf[0])
    var status = len

    while status >= sizeof(nlmsghdr) and h.nlmsg_len >= uint32(sizeof(nlmsghdr)):
      if h.nlmsg_type == NLMSG_DONE:
        discard close(fd)
        return

      if h.nlmsg_type == RTM_NEWLINK:
        let ifi = cast[ptr ifinfomsg](cast[uint](h) + uint(sizeof(nlmsghdr)))
        var rta = cast[ptr rtattr](cast[uint](ifi) + uint(sizeof(ifinfomsg)))
        var rta_len = int(h.nlmsg_len) - sizeof(nlmsghdr) - sizeof(ifinfomsg)

        var ifName = ""
        var rxBytes: uint64 = 0
        var txBytes: uint64 = 0
        var hasStats = false

        while rta_len >= sizeof(rtattr) and rta.rta_len >= uint16(sizeof(rtattr)):
          let dataPtr = cast[uint](rta) + uint(sizeof(rtattr))
          if rta.rta_type == IFLA_IFNAME:
            ifName = $cast[cstring](dataPtr)
          elif rta.rta_type == IFLA_STATS64:
            let stats = cast[ptr rtnl_link_stats64](dataPtr)
            rxBytes = stats.rx_bytes
            txBytes = stats.tx_bytes
            hasStats = true

          let alignRta = (int(rta.rta_len) + 3) and not 3
          rta_len -= alignRta
          rta = cast[ptr rtattr](cast[uint](rta) + uint(alignRta))

        if ifName.len > 0 and hasStats and ifName != "lo":
          if not sc.interfaces.hasKey(ifName):
            sc.interfaces[ifName] =
              NetInterfaceStats(name: ifName, totalUp: txBytes, totalDown: rxBytes)
          else:
            var s = sc.interfaces[ifName]
            let dd =
              if rxBytes >= s.totalDown:
                rxBytes - s.totalDown
              else:
                0
            let du =
              if txBytes >= s.totalUp:
                txBytes - s.totalUp
              else:
                0

            s.down = uint64(dd.float64 / intervalSec)
            s.up = uint64(du.float64 / intervalSec)
            s.totalUp = txBytes
            s.totalDown = rxBytes
            s.total = s.down + s.up

            if s.total >= maxSpeed:
              maxSpeed = s.total
              sc.current = s

            sc.interfaces[ifName] = s

      let alignHdr = (int(h.nlmsg_len) + 3) and not 3
      status -= alignHdr
      h = cast[ptr nlmsghdr](cast[uint](h) + uint(alignHdr))

  discard close(fd)

proc getMemVal(info: ptr MeminfoInfo, item: MeminfoItem): uint64 =
  let res = procps_meminfo_get(info, item)
  if res != nil:
    result = res.result.ul_int.uint64 * 1024

proc getMemState(outMap: var Table[string, JsonNode]) =
  var info: ptr MeminfoInfo
  if procps_meminfo_new(addr info) < 0:
    return

  defer:
    discard procps_meminfo_unref(addr info)

  let memTotal = getMemVal(info, MeminfoItem.MEMINFO_MEM_TOTAL)
  let memAvailable = getMemVal(info, MeminfoItem.MEMINFO_MEM_AVAILABLE)
  let memUsed = getMemVal(info, MeminfoItem.MEMINFO_MEM_USED)
  let swapTotal = getMemVal(info, MeminfoItem.MEMINFO_SWAP_TOTAL)
  let swapFree = getMemVal(info, MeminfoItem.MEMINFO_SWAP_FREE)

  outMap["memTotal"] = %memTotal
  outMap["memTotalString"] = %formatBytes(memTotal)
  outMap["memAvailable"] = %memAvailable
  outMap["memAvailableString"] = %formatBytes(memAvailable)
  outMap["memUsed"] = %memUsed
  outMap["memUsedString"] = %formatBytes(memUsed)
  outMap["memSwapTotal"] = %swapTotal
  outMap["memSwapTotalString"] = %formatBytes(swapTotal)
  outMap["memSwapFree"] = %swapFree
  outMap["memSwapFreeString"] = %formatBytes(swapFree)

proc main() =
  var netSpeed = NetSpeedCalculator(
    interfaces: initTable[string, NetInterfaceStats](), lastTime: getTime()
  )

  var statsMap = initTable[string, JsonNode](64)

  while true:
    statsMap.clear()

    let now = getTime()
    let intervalSec = (now - netSpeed.lastTime).inMicroseconds.float64 / 1_000_000.0
    netSpeed.lastTime = now

    let validInterval = if intervalSec <= 0.001: 0.25 else: intervalSec
    updateNetStatsDirect(netSpeed, validInterval)

    let cur = netSpeed.current
    statsMap["netName"] = %cur.name
    statsMap["netTotalUp"] = %cur.totalUp
    statsMap["netTotalUpString"] = %formatBytes(cur.totalUp)
    statsMap["netTotalDown"] = %cur.totalDown
    statsMap["netTotalDownString"] = %formatBytes(cur.totalDown)
    statsMap["netUp"] = %cur.up
    statsMap["netUpString"] = %formatSpeed(cur.up)
    statsMap["netDown"] = %cur.down
    statsMap["netDownString"] = %formatSpeed(cur.down)
    statsMap["netTotal"] = %cur.total
    statsMap["netTotalString"] = %formatSpeed(cur.total)

    getMemState(statsMap)
    getCPUState(statsMap)

    var jsonObj = newJObject()
    for k, v in statsMap:
      jsonObj[k] = v

    echo $jsonObj
    flushFile(stdout)

    sleep(250)

when isMainModule:
  main()

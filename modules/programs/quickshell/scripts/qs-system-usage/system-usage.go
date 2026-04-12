package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log"
	"maps"
	"os"
	"path/filepath"
	"reflect"
	"slices"
	"strconv"
	"strings"
	"time"

	"github.com/Nadim147c/real-go"
)

func mapSlice[T any, U any](s []T, t func(T) U) []U {
	res := make([]U, len(s))
	for i, v := range s {
		res[i] = t(v)
	}
	return res
}

type CPUState struct {
	Frequency   uint64           // in kHz
	Temperature real.Temperature // in Kelvin
	Utilization float64          // percentage
}

func ReadAllFiles(paths []string) []string {
	res := make([]string, 0, len(paths))
	for path := range slices.Values(paths) {
		data, err := os.ReadFile(path)
		if err != nil {
			continue
		}
		res = append(res, strings.TrimSpace(string(data)))
	}
	return res
}

var (
	cpuLastTotal uint64
	cpuLastIdled uint64
)

// GetCPUState retrieves basic CPU state, ignoring errors
func GetCPUState() CPUState {
	var state CPUState

	// 1. Get CPU frequency (first CPU)
	cpuFreqFiles, err := filepath.Glob("/sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq")
	if err == nil {
		data := ReadAllFiles(cpuFreqFiles)
		ints := mapSlice(data, func(s string) uint64 {
			return should(strconv.ParseUint(s, 10, 64))
		})
		state.Frequency = average(ints)
	}

	// 2. Get CPU temperature (average of available thermal zones)
	cpuTempFiles, err := filepath.Glob("/sys/class/thermal/thermal_zone*/temp")
	if err == nil {
		data := ReadAllFiles(cpuTempFiles)
		floats := mapSlice(data, func(s string) float64 {
			return should(strconv.ParseFloat(s, 64)) / 1000
		})
		avg := average(floats)
		state.Temperature = real.Celsius(avg)
	}

	// 3. Get CPU utilization (approximate since boot)
	if data, err := os.ReadFile("/proc/stat"); err == nil {
		for line := range strings.SplitSeq(string(data), "\n") {
			after := strings.Fields(line)
			if len(after) == 0 || after[0] != "cpu" {
				continue
			}

			var user, nice, system, idle, iowait, irq, softirq, steal, guest, guestNice uint64

			fmt.Sscanf(strings.Join(after[1:], " "), "%d %d %d %d %d %d %d %d %d %d",
				&user, &nice, &system, &idle, &iowait, &irq, &softirq, &steal, &guest, &guestNice)

			total := user + nice + system + idle + iowait + irq + softirq + steal + guest + guestNice
			idleTotal := idle + iowait

			totalDelta := total - cpuLastTotal
			idleDelta := idleTotal - cpuLastIdled

			state.Utilization = (1 - (float64(idleDelta) / float64(totalDelta))) * 100

			cpuLastTotal = total
			cpuLastIdled = idleTotal
			break
		}
	}

	return state
}

const NetDev = "/proc/net/dev"

type number interface {
	~int | ~int8 | ~int16 | ~int32 | ~int64 |
		~uint | ~uint8 | ~uint16 | ~uint32 | ~uint64 |
		~uintptr | ~float32 | ~float64
}

func average[T number](s []T) T {
	if len(s) == 0 {
		return 0
	}
	var t T
	for elem := range slices.Values(s) {
		t += elem
	}
	return t / T(len(s))
}

type NetTransmitted struct {
	Up, Down real.DataSize
}

type NetStats map[string]NetTransmitted

type NetInterfaceStats struct {
	Name       string
	TotalUp    real.DataSize
	TotalDown  real.DataSize
	Up         real.DataSpeed
	Down       real.DataSpeed
	Total      real.DataSpeed
	UpDeltas   []real.DataSize
	DownDeltas []real.DataSize
}

type NetSpeedCalculator struct {
	Interfaces map[string]*NetInterfaceStats
	Current    *NetInterfaceStats
}

func NewNetSpeedCalculator() *NetSpeedCalculator {
	return &NetSpeedCalculator{
		Interfaces: make(map[string]*NetInterfaceStats),
		Current:    &NetInterfaceStats{},
	}
}

func (sc *NetSpeedCalculator) parseNetDev() (NetStats, error) {
	file, err := os.Open(NetDev)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	currentStats := make(NetStats)
	scanner := bufio.NewScanner(file)

	// Skip the first two header lines
	scanner.Scan()
	scanner.Scan()

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}

		// Split by colon to separate interface name from data
		ifaceName, stats, found := strings.Cut(line, ":")
		if !found {
			continue
		}

		// Parse the data fields (bytes are the first field after interface name)
		dataFields := strings.Fields(stats)
		if len(dataFields) < 1 {
			continue
		}

		Down, err := strconv.Atoi(dataFields[0])
		if err != nil {
			continue
		}

		Up, err := strconv.Atoi(dataFields[8])
		if err != nil {
			continue
		}
		currentStats[ifaceName] = NetTransmitted{
			Down: real.DataSize(Down),
			Up:   real.DataSize(Up),
		}
	}

	return currentStats, nil
}

func (sc *NetSpeedCalculator) updateDeltas(currentStats NetStats) {
	for name := range sc.Interfaces {
		if _, exists := currentStats[name]; !exists {
			delete(sc.Interfaces, name)
		}
	}

	var maxDelta real.DataSpeed
	// Update existing interfaces and add new ones
	for name, transmitted := range currentStats {
		stats, exists := sc.Interfaces[name]
		if !exists {
			sc.Interfaces[name] = &NetInterfaceStats{
				Name:       name,
				TotalUp:    transmitted.Up,
				TotalDown:  transmitted.Down,
				UpDeltas:   make([]real.DataSize, 4), // Buffer for last
				DownDeltas: make([]real.DataSize, 4), // Buffer for last
			}
			continue
		}

		dd := max(transmitted.Down-stats.TotalDown, 0)
		du := max(transmitted.Up-stats.TotalUp, 0)

		stats.Down = real.NewSpeed(average(stats.DownDeltas), UpdateTime)
		stats.DownDeltas = append(stats.DownDeltas[1:], dd)
		stats.Up = real.NewSpeed(average(stats.UpDeltas), UpdateTime)
		stats.UpDeltas = append(stats.UpDeltas[1:], du)

		stats.TotalUp = transmitted.Up
		stats.TotalDown = transmitted.Down

		stats.Total = stats.Up + stats.Down

		delta := stats.Down + stats.Up
		if delta > maxDelta {
			maxDelta = delta
			sc.Current = stats
		}
	}
}

func (c *NetSpeedCalculator) Update() NetInterfaceStats {
	currentStats, err := c.parseNetDev()
	if err != nil {
		log.Fatalf("Error reading net dev: %v", err)
	}

	c.updateDeltas(currentStats)
	return *c.Current
}

type MemState struct {
	Total     real.DataSize
	Free      real.DataSize
	Available real.DataSize
	SwapTotal real.DataSize
	SwapFree  real.DataSize
}

func should[T any](v T, _ error) T {
	return v
}

func GetMemState() MemState {
	var mem MemState

	file, err := os.Open("/proc/meminfo")
	if err != nil {
		return mem
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var found int
	for scanner.Scan() {
		prefix, size, ok := strings.Cut(scanner.Text(), ":")
		if !ok {
			return mem
		}
		switch prefix {
		case "MemTotal":
			found++
			mem.Total = should(real.ParseSize(size))
		case "MemFree":
			found++
			mem.Free = should(real.ParseSize(size))
		case "MemAvailable":
			found++
			mem.Available = should(real.ParseSize(size))
		case "SwapTotal":
			found++
			mem.SwapTotal = should(real.ParseSize(size))
		case "SwapFree":
			found++
			mem.SwapFree = should(real.ParseSize(size))
		default:
		}
		if found == 5 {
			break
		}
	}

	return mem
}

func StructValueStringMap(prefix string, v any) map[string]any {
	rv := reflect.ValueOf(v)
	if rv.Kind() == reflect.Pointer {
		rv = rv.Elem()
	}
	if rv.Kind() != reflect.Struct {
		return nil
	}

	rt := rv.Type()
	out := make(map[string]any, rt.NumField()*2)

	for i := 0; i < rt.NumField(); i++ {
		fieldType := rt.Field(i)
		fieldVal := rv.Field(i)

		// exported fields only
		if !fieldType.IsExported() {
			continue
		}

		// Skip zero-value embedded structs, optional
		if fieldVal.Kind() == reflect.Struct && fieldType.Anonymous {
			continue
		}

		literalTypes := []reflect.Kind{
			reflect.String,
			reflect.Bool,
			reflect.Int,
			reflect.Int8,
			reflect.Int16,
			reflect.Int32,
			reflect.Int64,
			reflect.Uint,
			reflect.Uint8,
			reflect.Uint16,
			reflect.Uint32,
			reflect.Uint64,
			reflect.Float32,
			reflect.Float64,
		}
		if slices.Contains(literalTypes, fieldVal.Kind()) {
			out[prefix+fieldType.Name] = fieldVal.Interface()
		}

		stringMethod := fieldVal.MethodByName("String")

		if !stringMethod.IsValid() {
			if fieldVal.Kind() == reflect.Float64 {
				key := fieldType.Name
				out[prefix+key+"String"] = formatFloat(fieldVal.Float())
			}
			continue // opt-in only
		}

		// Call String()
		stringRes := stringMethod.Call(nil)
		if len(stringRes) != 1 || stringRes[0].Kind() != reflect.String {
			return nil
		}

		key := fieldType.Name
		out[prefix+key+"String"] = stringRes[0].Interface()
	}

	return out
}

func formatFloat(n float64) string {
	s := fmt.Sprintf("%.2f", n)
	s = strings.TrimRight(s, "0")
	s = strings.TrimRight(s, ".")
	return s
}

const UpdateTime = time.Second / 4

func main() {
	netSpeed := NewNetSpeedCalculator()
	ticker := time.NewTicker(UpdateTime)
	defer ticker.Stop()

	encoder := json.NewEncoder(os.Stdout)

	for range ticker.C {
		stats := map[string]any{}

		netState := netSpeed.Update()
		maps.Copy(stats, StructValueStringMap("net", netState))
		memState := GetMemState()
		maps.Copy(stats, StructValueStringMap("mem", memState))
		cpuState := GetCPUState()
		maps.Copy(stats, StructValueStringMap("cpu", cpuState))

		encoder.Encode(stats)
	}
}

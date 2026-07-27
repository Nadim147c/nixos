package real

import (
	"errors"
	"fmt"
	"math"
	"strings"
	"time"
)

// DataSpeed represents a quantity of data transfer in bytes per second.
type DataSpeed uint64

// NewSpeed creates a speed from given amount and time.
// It panics on invalid input.
func NewSpeed(amount DataSize, dur time.Duration) DataSpeed {
	speed, err := NewSpeedE(amount, dur)
	if err != nil {
		panic(err)
	}
	return speed
}

// NewSpeedE creates a speed from given amount and time.
// It returns an error instead of panicking.
func NewSpeedE(amount DataSize, dur time.Duration) (DataSpeed, error) {
	if dur < 0 {
		return 0, fmt.Errorf("negative duration: %d", dur)
	}

	if dur == 0 {
		return 0, nil
	}

	// If negative speeds are not allowed, guard here.
	if amount < 0 {
		return 0, fmt.Errorf("negative amount: %d", amount)
	}

	// overflow check: amount * time.Second
	if amount > DataSize(math.MaxInt64)/DataSize(time.Second) {
		return 0, errors.New("speed overflows int64")
	}

	bytesPerSecond := (amount * DataSize(time.Second)) / DataSize(dur)
	return DataSpeed(bytesPerSecond), nil
}

var timeTable = map[string]time.Duration{
	"ns": time.Nanosecond,
	"µs": time.Nanosecond,
	"ms": time.Millisecond,
	"s":  time.Second,
	"m":  time.Minute,
	"h":  time.Hour,
}

// ParseSpeed parses a dataspeed to Speed
func ParseSpeed(s string) (DataSpeed, error) {
	trimmed := strings.TrimSpace(s)
	perIndex := strings.LastIndexAny(trimmed, "p/")
	if perIndex < 0 {
		return 0, fmt.Errorf("invalid dataspeed format: %q", s)
	}
	sizeStr, durStr := trimmed[:perIndex], trimmed[perIndex+1:]

	dur, ok := timeTable[strings.TrimSpace(durStr)]
	if !ok {
		return 0, fmt.Errorf("invalid duration for dataspeed: %q", durStr)
	}

	size, err := ParseSize(sizeStr)
	if err != nil {
		return 0, fmt.Errorf("invalid size for dataspeed: %w", err)
	}
	return NewSpeedE(size, dur)
}

// Size returns the speed as a Size (bytes per second)
func (s DataSpeed) Size() DataSize {
	return DataSize(s)
}

// FormatUnitString formats the Speed using the specified unit and precision.
//
// Supported units include all units supported by Size.FormatUnitString,
// with "/s" appended for per-second notation.
func (s DataSpeed) FormatUnitString(unit string, precision ...int) string {
	if s == 0 {
		return "0 " + unit + "/s"
	}

	// Convert to Size and use its FormatUnitString, then append "/s"
	size := s.Size()
	formatted := size.FormatUnitString(unit, precision...)

	// Append "/s" to the formatted string
	// The formatted string is in format "value unit" or "value.fraction unit"
	// We need to insert "/s" before the space or at the end
	return formatted + "/s"
}

// Format implements fmt.Formatter. Supported verbs:
//   - %B for binary byte units per second (KiB/s, MiB/s, ...)
//   - %b for binary bit units per second (Kib/s, Mib/s, ...)
//   - %M for metric byte units per second (kB/s, MB/s, ...)
//   - %m for metric bit units per second (Kb/s, Mb/s, ...)
//   - %d for the raw uint64 value
//   - %s for a string representation similar to %B but ignoring precision
func (s DataSpeed) Format(f fmt.State, verb rune) {
	s.Size().Format(f, verb)
	fmt.Fprint(f, "/s")
}

// String returns the default string representation of the Speed.
//
// It uses binary byte units per second and prints with two decimal places,
// except for raw bytes per second, which are printed as integers.
func (s DataSpeed) String() string {
	return s.Size().String() + "/s"
}

// BytesPerSecond returns the speed in bytes per second as a uint64
func (s DataSpeed) BytesPerSecond() uint64 {
	return uint64(s)
}

// KilobitsPerSecond returns the speed in kilobits per second (metric)
func (s DataSpeed) KilobitsPerSecond() float64 {
	if s == 0 {
		return 0
	}
	size := s.Size()
	return float64(size) / float64(Kb)
}

// MegabitsPerSecond returns the speed in megabits per second (metric)
func (s DataSpeed) MegabitsPerSecond() float64 {
	if s == 0 {
		return 0
	}
	size := s.Size()
	return float64(size) / float64(Mb)
}

// KilobytesPerSecond returns the speed in kilobytes per second (metric)
func (s DataSpeed) KilobytesPerSecond() float64 {
	if s == 0 {
		return 0
	}
	size := s.Size()
	return float64(size) / float64(KB)
}

// MegabytesPerSecond returns the speed in megabytes per second (metric)
func (s DataSpeed) MegabytesPerSecond() float64 {
	if s == 0 {
		return 0
	}
	size := s.Size()
	return float64(size) / float64(MB)
}

// KibibitsPerSecond returns the speed in kibibits per second (binary)
func (s DataSpeed) KibibitsPerSecond() float64 {
	if s == 0 {
		return 0
	}
	size := s.Size()
	return float64(size) / float64(Kib)
}

// MebibitsPerSecond returns the speed in mebibits per second (binary)
func (s DataSpeed) MebibitsPerSecond() float64 {
	if s == 0 {
		return 0
	}
	size := s.Size()
	return float64(size) / float64(Mib)
}

// KibibytesPerSecond returns the speed in kibibytes per second (binary)
func (s DataSpeed) KibibytesPerSecond() float64 {
	if s == 0 {
		return 0
	}
	size := s.Size()
	return float64(size) / float64(KiB)
}

// MebibytesPerSecond returns the speed in mebibytes per second (binary)
func (s DataSpeed) MebibytesPerSecond() float64 {
	if s == 0 {
		return 0
	}
	size := s.Size()
	return float64(size) / float64(MiB)
}

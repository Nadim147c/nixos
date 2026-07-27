package real

import (
	"fmt"
	"math"
	"math/big"
	"strconv"
	"strings"
	"unicode"

	islices "github.com/Nadim147c/real-go/internal/slices"
)

// DataFormatUnit describes a family of units used for formatting data sizes.
type DataFormatUnit int

const (
	// DataFormatBinaryByte represents binary byte units (KiB, MiB, GiB, ...).
	DataFormatBinaryByte DataFormatUnit = iota
	// DataFormatMetricByte represents metric byte units (kB, MB, GB, ...).
	DataFormatMetricByte
	// DataFormatBinaryBit represents binary bit units (Kib, Mib, Gib, ...).
	DataFormatBinaryBit
	// DataFormatMetricBit represents metric bit units (Kb, Mb, Gb, ...).
	DataFormatMetricBit
)

// DataSize represents a quantity of data in bytes.
//
// It is defined as an int64 and can represent both byte- and bit-based
// quantities through conversion.
type DataSize int64

// revive:disable exported

const (
	// Zero represents a data size of zero bytes.
	Zero DataSize = 0

	// Byte represents a single byte.
	Byte DataSize = 1

	// Metric byte units.
	KB DataSize = 1000 * Byte
	MB DataSize = 1000 * KB
	GB DataSize = 1000 * MB
	TB DataSize = 1000 * GB
	PB DataSize = 1000 * TB
	EB DataSize = 1000 * PB

	// Binary byte units.
	KiB DataSize = 1024 * Byte
	MiB DataSize = 1024 * KiB
	GiB DataSize = 1024 * MiB
	TiB DataSize = 1024 * GiB
	PiB DataSize = 1024 * TiB
	EiB DataSize = 1024 * PiB

	// Metric bit units.
	Kb DataSize = KB / 8
	Mb DataSize = MB / 8
	Gb DataSize = GB / 8
	Tb DataSize = TB / 8
	Pb DataSize = PB / 8
	Eb DataSize = EB / 8

	// Binary bit units.
	Kib DataSize = KiB / 8
	Mib DataSize = MiB / 8
	Gib DataSize = GiB / 8
	Tib DataSize = TiB / 8
	Pib DataSize = PiB / 8
)

// revive:enable exported

// ParseSize parses a datasize to Size
func ParseSize(s string) (DataSize, error) {
	trimmed := strings.TrimSpace(s)
	numEnd := strings.LastIndexFunc(trimmed, unicode.IsDigit) + 1
	if numEnd <= 0 {
		return 0, fmt.Errorf("invalid size format: %q", s)
	}
	num, inputUnit := trimmed[:numEnd], trimmed[numEnd:]
	size, err := strconv.ParseInt(num, 10, 64)
	if err != nil {
		return 0, err
	}

	unit := strings.TrimSpace(inputUnit)
	if unit == "" {
		unit = "B" // default unit is byte
	}

	// we want convert mib or tib but not weird mIb
	if all(unit, unicode.IsLower) {
		unit = strings.Map(func(r rune) rune {
			if r == 'i' {
				return r
			}
			return unicode.ToUpper(r)
		}, unit)
	}

	mul, ok := UnitTable[unit]
	if !ok {
		return 0, fmt.Errorf("invalid input unit: %q", inputUnit)
	}

	if size > 0 && size > math.MaxInt64/int64(mul) {
		return 0, fmt.Errorf("size overflows int64: %q", s)
	}
	if size < 0 && size < math.MinInt64/int64(mul) {
		return 0, fmt.Errorf("size overflows int64: %q", s)
	}

	return DataSize(size) * mul, nil
}

func all(s string, f func(rune) bool) bool {
	for _, r := range s {
		if !f(r) {
			return false
		}
	}
	return true
}

// quotient returns d divided by u as a floating-point value. If u is zero,
// return NaN.
func (d DataSize) quotient(u DataSize) float64 {
	if u == 0 {
		return math.NaN()
	}
	abs := d / u
	mod := d % u
	return float64(abs) + float64(mod)/float64(u)
}

// Value returns the underlying int64 value
func (d DataSize) Value() int64 {
	return int64(d)
}

// UnitTable maps supported unit strings to their corresponding Size values.
var UnitTable = map[string]DataSize{
	"B":  Byte,
	"kB": KB, "KB": KB, "MB": MB, "GB": GB, "TB": TB, "PB": PB, "EB": EB,
	"kiB": KiB, "KiB": KiB, "MiB": MiB, "GiB": GiB, "TiB": TiB, "PiB": PiB, "EiB": EiB,
	"kb": Kb, "Kb": Kb, "Mb": Mb, "Gb": Gb, "Tb": Tb, "Pb": Pb, "Eb": Eb,
	"kib": Kib, "Kib": Kib, "Mib": Mib, "Gib": Gib, "Tib": Tib, "Pib": Pib,
}

// FormatUnitString formats the Size using the specified unit and precision.
//
// Supported units include:
//   - b, B
//   - kB, KB, MB, GB, TB, PB, EB
//   - kiB, KiB, MiB, GiB, TiB, PiB, EiB
//   - kb, Kb, Mb, Gb, Tb, Pb, Eb
//   - kib, Kib, Mib, Gib, Tib, Pib, Eib
//
// A precision of zero prints an integer value. For bits and bytes, precision
// greater than zero appends a fractional part of zeros.
func (d DataSize) FormatUnitString(unit string, precision ...int) string {
	if d == 0 {
		return "0 " + unit
	}

	prec := islices.OptionalValue(0, precision)

	// Handle bytes.
	if unit == "B" {
		if prec == 0 {
			return fmt.Sprintf("%d %s", int64(d), unit)
		}
		return fmt.Sprintf("%d.%0*d %s", int64(d), prec, 0, unit)
	}

	// Handle bits.
	if unit == "b" {
		bits := big.NewInt(int64(d))
		bits.Mul(bits, big.NewInt(8))

		if prec == 0 {
			return fmt.Sprintf("%s %s", bits, unit)
		}
		return fmt.Sprintf("%s.%0*d %s", bits, prec, 0, unit)
	}

	u, ok := UnitTable[unit]
	if !ok {
		panic("illegal diskspace unit")
	}

	format := fmt.Sprintf("%%.%df %s", prec, unit)
	return fmt.Sprintf(format, d.quotient(u))
}

// Format implements fmt.Formatter. Supported verbs:
//   - %B for binary byte units (KiB, MiB, ...)
//   - %b for binary bit units (Kib, Mib, ...)
//   - %M for metric byte units (KB, MB, ...)
//   - %m for metric bit units (Kb, Mb, ...)
//   - %d for the raw int64 value
//   - %s for a string representation similar to %B but ignoring precision
func (d DataSize) Format(f fmt.State, verb rune) {
	precision, fixed := f.Precision()
	var unit string

	switch verb {
	case 'B':
		unit = d.bestUnit(DataFormatBinaryByte)
	case 'b':
		unit = d.bestUnit(DataFormatBinaryBit)
	case 'M':
		unit = d.bestUnit(DataFormatMetricByte)
	case 'm':
		unit = d.bestUnit(DataFormatMetricBit)
	case 'd':
		fmt.Fprint(f, int64(d))
		return
	default:
		fmt.Fprint(f, d.String())
		return
	}

	if fixed {
		fmt.Fprint(f, d.FormatUnitString(unit, precision))
		return
	}

	if unit == "B" || unit == "b" {
		fmt.Fprint(f, d.FormatUnitString(unit))
		return
	}

	fmt.Fprint(f, d.FormatUnitString(unit, 2))
}

// String returns the default string representation of the Size.
//
// It uses binary byte units and prints with two decimal places, except for raw
// bytes, which are printed as integers.
func (d DataSize) String() string {
	unit := d.bestUnit(DataFormatBinaryByte)
	switch unit {
	case "b", "B":
		return d.FormatUnitString(unit)
	default:
		return d.FormatUnitString(unit, 2)
	}
}

type pair struct {
	name  string
	value DataSize
}

var (
	metricBytes = []pair{
		{"B", Byte},
		{"kB", KB},
		{"MB", MB},
		{"GB", GB},
		{"TB", TB},
		{"PB", PB},
		{"EB", EB},
	}
	metricBits = []pair{
		{"b", 0},
		{"kb", Kb},
		{"Mb", Mb},
		{"Gb", Gb},
		{"Tb", Tb},
		{"Pb", Pb},
		{"Eb", Eb},
	}
	binaryBytes = []pair{
		{"B", Byte},
		{"kiB", KiB},
		{"MiB", MiB},
		{"GiB", GiB},
		{"TiB", TiB},
		{"PiB", PiB},
		{"EiB", EiB},
	}
	binaryBits = []pair{
		{"b", 0},
		{"kib", Kib},
		{"Mib", Mib},
		{"Gib", Gib},
		{"Tib", Tib},
		{"Pib", Pib},
	}
)

// bestUnit returns the most appropriate unit name for the Size within the given
// unit family.
//
// The returned unit is chosen such that the formatted value is less than the
// next larger unit.
func (d DataSize) bestUnit(u DataFormatUnit) string {
	var unitList []pair

	switch u {
	case DataFormatBinaryByte:
		unitList = binaryBytes
	case DataFormatMetricByte:
		unitList = metricBytes
	case DataFormatBinaryBit:
		unitList = binaryBits
	case DataFormatMetricBit:
		unitList = metricBits
	default:
		panic("invalid unit kind")
	}

	p := islices.LastItemFunc(unitList, func(a pair) bool {
		return a.value <= d
	})

	return p.name
}

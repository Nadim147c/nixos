package real

import (
	"fmt"
	"math"
)

// Temperature is a real-life temperature stored in kelvin.
type Temperature float64

// TempUnit represents a temperature unit.
type TempUnit int

// TempUnitFunc converts a float64 in that unit to Temperature.
type TempUnitFunc func(float64) Temperature

// revive:disable exported
const (
	TempUnitKelvin TempUnit = iota
	TempUnitCelsius
	TempUnitFahrenheit
)

func Kelvin(t float64) Temperature     { return Temperature(t) }
func Celsius(t float64) Temperature    { return Temperature(t) + TempFreezing }
func Fahrenheit(t float64) Temperature { return Temperature((t-32)*5/9) + TempFreezing }

// revive:enable exported

// Physical constants.
const (
	// TempAbsoluteZero is the absolute zero temperature.
	TempAbsoluteZero Temperature = 0
	// TempFreezing is the freezing point of water (0°C).
	TempFreezing Temperature = 273.15
	// TempBoiling is the boiling point of water (100°C).
	TempBoiling Temperature = 373.15
)

// In converts temperature to the requested unit.
func (t Temperature) In(u TempUnit) float64 {
	switch u {
	case TempUnitKelvin:
		return float64(t)
	case TempUnitCelsius:
		return float64(t - TempFreezing)
	case TempUnitFahrenheit:
		return float64(t-TempFreezing)*9/5 + 32
	default:
		panic("invalid temperature unit")
	}
}

// String returns a human-friendly representation (°C by default).
func (t Temperature) String() string {
	if math.IsNaN(float64(t)) {
		return "0"
	}
	return fmt.Sprintf("%.2C", t)
}

// Format implements fmt.Formatter.
//
// Supported verbs:
//   - %K — kelvin
//   - %C — celsius
//   - %F — fahrenheit
//   - %f — alias for %C
func (t Temperature) Format(f fmt.State, verb rune) {
	precision, ok := f.Precision()
	if !ok {
		precision = 2
	}

	format := fmt.Sprintf("%%.%df %%s", precision)

	switch verb {
	case 'K':
		fmt.Fprintf(f, format, t.In(TempUnitKelvin), "K")
	case 'C', 'f':
		fmt.Fprintf(f, format, t.In(TempUnitCelsius), "°C")
	case 'F':
		fmt.Fprintf(f, format, t.In(TempUnitFahrenheit), "°F")
	default:
		fmt.Fprint(f, t.String())
	}
}

# Real

A collection of real-world values as Go types. For when you need actual units, not
just raw numbers.

## Why?

Because it was fun to write...! Do I add more?

## When to use?

DO NOT USE IT!

## Quick Examples

```go
import (
    "time"
    "github.com/Nadim147c/real-go"
)

// Data with proper units
file := 2*real.GB + 500*real.MB
fmt.Printf("File: %s\n", file)  // "2.50 GB"

// Download speeds that make sense
downloaded := real.NewSpeed(100*real.MB, 2*time.Second)
fmt.Printf("Speed: %s\n", downloaded)  // "50.00 MiB/s"

// Temperatures that don't confuse
room := real.Celsius(20)
fmt.Printf("Room: %s\n", room)  // "20.00°C"
```

## What's Inside

### 📦 Data Sizes (`real.DataSize`)

Bytes, bits, and everything in between. Knows the difference between MB (1000) and MiB (1024).

```go
// Create
file := 2*real.GB + 500*real.MB  // 2.5 GB file
ram := 16 * real.GiB             // 16 GiB RAM

// Print
fmt.Println(file.String())  // "2.50 GB" (auto-chooses unit)
fmt.Printf("%B\n", ram)     // "16.00 GiB" (binary units)
```

### ⚡ Transfer Speeds (`real.DataSpeed`)

Internet speeds, file transfers, downloads. All with proper "/s" units.

```go
// From downloaded amount and time
speed := real.NewSpeed(100*real.MB, 2*time.Second)
fmt.Printf("%s\n", speed)  // "50.00 MiB/s"

// Fancy formatting
fmt.Printf("%.1M\n", speed)  // "50.0 MB/s" (metric, 1 decimal)
fmt.Printf("%m\n", speed)    // "400.00 Mb/s" (bits!)
```

### 🌡️ Temperatures (`real.Temperature`)

Celsius, Fahrenheit, Kelvin. No more guessing which unit you're in.

```go
// Create
room := real.Celsius(20)      // 20°C
body := real.Fahrenheit(98.6) // 98.6°F
cold := real.Kelvin(0)        // 0K (brrr)

// Convert
fmt.Printf("%s = %.1f°F\n", room,
    room.In(real.UnitFahrenheit))  // "20.00°C = 68.0°F"
```

## Install

```bash
go get github.com/Nadim147c/real-go
```

# LICENSE

This repository is licensed under [LGPL-3.0](./LICENSE.md).

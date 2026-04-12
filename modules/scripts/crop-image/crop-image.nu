const precision = 10000

# Crop an image using specific ratio
def main [
  input: string # Input image files
  output?: string # Output image files
  --ratio (-r): string # Ratio of the output image. (Required) E.g. 16:9 or 2/1 or 1.5
] {
  if ($ratio == null) {
    error make -u {msg: "Please provide a ratio"}
  }

  let parts = $ratio | split row --regex "[:/x]";

  let imagemagick_ratio = match ($parts | length) {
    1 => { $parts | first | into float | fraction $in }
    2 => { $parts | str join ":" }
    _ => { error make -u {msg: "Please prvide one or more input"} }
  }

  let outfile = if ($output == null) {
    $input | path parse | update stem {|it| $it.stem + "-cropped" } | path join
  } else {
    $output
  }

  magick $input -gravity center -crop $imagemagick_ratio $outfile
}

# Returns the GCD of two integers using the Euclidean Algorithm
def gcd [a: int b: int] {
  mut x = $a
  mut y = $b
  while $y != 0 {
    let temp = $y
    $y = $x mod $y
    $x = $temp
  }
  return $x
}

def fraction [f: float] {
  let m = ($f * $precision | math round | into int)
  let common = gcd $m $precision

  let numerator = $m / $common | math round
  let denominator = $precision / $common | math round

  $numerator + ":" + $denominator
}

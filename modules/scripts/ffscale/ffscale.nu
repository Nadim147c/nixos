#!/usr/bin/env nu

# Scale a video (aspect ratio preserved) and encode it as H.264 with GPU acceleration
def main [
  input: string # Input video file to scale
  output?: string # Output video file
  --scale (-c): float # Scale multiplier (e.g. 2, 1.5, 0.5)
  --quality (-q): int # Target height (e.g. 1080, 720)
  --size (-s): string # Bounding box (e.g. 1920:1080)
  --filter (-f): string # Additional ffmpeg filter (e.g. fps=10)
] {
  if (which ffmpeg | is-empty) {
    error make -u {msg: "ffmpeg not found in PATH"}
  }

  # Every mode keeps the aspect ratio and produces even dimensions (required for H.264 4:2:0).
  # Sizes are computed by ffmpeg itself, so rotated videos and odd sources are handled correctly.
  let scaling = if $size != null {
    let box = $size | str replace --all "x" ":"
    let f = if ($box | str contains "-") {
      # Caller used ffmpeg's own auto-size syntax, e.g. -2:720 or 1280:-2
      $"scale=($box)"
    } else {
      $"scale=($box):force_original_aspect_ratio=decrease:force_divisible_by=2"
    }
    {filter: $f label: ($box | str replace ":" "x")}
  } else if $quality != null {
    let h = ($quality // 2) * 2
    {filter: $"scale=-2:($h)" label: $"($h)p"}
  } else if $scale != null {
    let s = $scale | into string
    {
      filter: (["scale=trunc(iw*" $s "/2)*2:trunc(ih*" $s "/2)*2"] | str join)
      label: $"x($s)"
    }
  } else {
    error make -u {msg: "No scale, size or quality specified"}
  }

  let enc = pick_encoder
  print $"Encoder: ($enc.name)"

  let vf = [$scaling.filter $filter $enc.vf] | compact | str join ","

  let output_name = if $output != null {
    $output
  } else {
    let p = $input | path expand | path parse
    # H.264 doesn't go into webm, so default to mp4 there
    let ext = if ($p.extension | is-empty) or (($p.extension | str downcase) == "webm") {
      "mp4"
    } else {
      $p.extension
    }
    $p
    | upsert stem {|it| $"($it.stem)_($scaling.label)" }
    | upsert extension $ext
    | path join
  }

  let args = [
    "-hide_banner"
    "-hwaccel"
    "auto" # hardware decode when available, silently falls back to software
    ...$enc.pre
    "-i"
    $input
    "-vf"
    $vf
    ...$enc.venc
    "-c:a"
    "copy"
    "-movflags"
    "+faststart"
    $output_name
  ]

  ^ffmpeg ...$args
}

# Software fallback, used only when no GPU encoder works
def software_encoder [] {
  {
    name: "libx264 (software)"
    pre: []
    vf: "format=yuv420p"
    venc: ["-c:v" "libx264" "-crf" "23" "-preset" "medium"]
  }
}

# GPU encoders worth trying on this machine, best first
def hw_candidates [] {
  match $nu.os-info.name {
    "macos" => {
      # Apple Silicon supports quality-based rate control; Intel Macs need a bitrate
      let rate = if ($nu.os-info.arch in ["aarch64" "arm64"]) {
        ["-q:v" "65"]
      } else {
        ["-b:v" "8M"]
      }
      [
        {
          name: "h264_videotoolbox"
          pre: []
          vf: "format=yuv420p"
          venc: (["-c:v" "h264_videotoolbox" "-profile:v" "high"] ++ $rate)
        }
      ]
    }
    "linux" => {
      # NVIDIA proprietary driver -> NVENC
      let nvidia = if (("/dev/nvidiactl" | path exists) or (which nvidia-smi | is-not-empty)) {
        [
          {
            name: "h264_nvenc"
            pre: []
            vf: "format=yuv420p"
            venc: ["-c:v" "h264_nvenc" "-preset" "p5" "-rc" "vbr" "-cq" "23" "-b:v" "0"]
          }
        ]
      } else {
        []
      }

      # Intel (0x8086) and AMD (0x1002) render nodes -> VAAPI (iHD/i965 or Mesa radeonsi)
      let vaapi = glob "/dev/dri/renderD*"
        | sort
        | where  {|node|
          let vendor = try {
            open --raw $"/sys/class/drm/($node | path basename)/device/vendor" | str trim
          } catch {
            ""
          }
          $vendor in ["0x8086" "0x1002"]
        }
        | each {|node|
          {
            name: $"h264_vaapi \(($node)\)"
            pre: ["-vaapi_device" $node]
            vf: "format=nv12,hwupload"
            venc: ["-c:v" "h264_vaapi" "-qp" "23"]
          }
        }

      $nvidia ++ $vaapi
    }
    _ => []
  }
}

# Try a tiny test encode so we only pick an encoder that actually works with the installed driver
def probe_encoder [enc: record] {
  let args = [
    "-hide_banner"
    "-loglevel"
    "error"
    ...$enc.pre
    "-f"
    "lavfi"
    "-i"
    "color=c=black:s=256x256:r=25:d=0.2"
    "-vf"
    $enc.vf
    ...$enc.venc
    "-f"
    "null"
    "-"
  ]
  (^ffmpeg ...$args | complete).exit_code == 0
}

def pick_encoder [] {
  let hw = (hw_candidates | where  {|e| probe_encoder $e } | get 0?)
  if $hw == null {
    print -e "warning: no working GPU H.264 encoder found, falling back to libx264 (CPU)"
    software_encoder
  } else {
    $hw
  }
}

# Get current weather states as json. Data is cached for 10min in /tmp/weather.json.
def main [] {
  let file = "/tmp/weather.json"

  let time = date now | into int | $in / (15min | into int) | math floor
  if ($file | path exists) and (open $file | get time) == $time {
    print --stderr "Cached weather data"
    cat $file
    return
  }

  let uri = (
    make url http://api.weatherapi.com/v1/current.json {
      key: (open ~/.config/weather_api.key | str trim)
      q: (http get api.ipquery.io)
    }
  )

  let data = http get $uri | upsert time $time

  $data | save --force $file

  print ($data | to json)
}

def "make url" [url: string params: record] {
  $url | url parse | update params $params | url join
}

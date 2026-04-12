pragma Singleton

import qs.modules.common.models
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property WeatherLocation location: WeatherLocation {}
    property CurrentWeather weather: CurrentWeather {}

    Process {
        id: fetcher
        command: ["qs-weather"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0)
                    return;
                try {
                    root.parseJSON(text);
                } catch (e) {
                    console.error(`[WeatherService] ${e.message}`);
                }
            }
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 5 * 60 * 1000  // 5min
        triggeredOnStart: true
        onTriggered: fetcher.running = true
    }

    function parseJSON(jsonString) {
        var obj = JSON.parse(jsonString);

        location.name = obj.location.name;
        location.region = obj.location.region;
        location.country = obj.location.country;
        location.lat = obj.location.lat;
        location.lon = obj.location.lon;
        location.tzId = obj.location.tz_id;

        weather.lastUpdated = obj.current.last_updated;
        weather.tempC = obj.current.temp_c;
        weather.isDay = obj.current.is_day;

        weather.condition.text = obj.current.condition.text;
        weather.condition.icon = obj.current.condition.icon;
        weather.condition.code = obj.current.condition.code;

        weather.windKph = obj.current.wind_kph;
        weather.windDegree = obj.current.wind_degree;
        weather.windDir = obj.current.wind_dir;

        weather.pressureMb = obj.current.pressure_mb;
        weather.precipMm = obj.current.precip_mm;
        weather.humidity = obj.current.humidity;
        weather.cloud = obj.current.cloud;

        weather.feelslikeC = obj.current.feelslike_c;
        weather.windchillC = obj.current.windchill_c;
        weather.heatindexC = obj.current.heatindex_c;
        weather.dewpointC = obj.current.dewpoint_c;

        weather.visKm = obj.current.vis_km;
        weather.uv = obj.current.uv;
    }
}

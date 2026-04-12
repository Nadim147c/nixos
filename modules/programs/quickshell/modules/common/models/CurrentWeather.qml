import QtQml

QtObject {
    property string lastUpdated      // e.g. "2026-03-03 19:15"
    property double tempC
    property int isDay                // 0 = night, 1 = day
    property WeatherCondition condition: WeatherCondition {}

    property double windKph
    property int windDegree
    property string windDir

    property double pressureMb
    property double precipMm
    property int humidity
    property int cloud

    property double feelslikeC
    property double windchillC
    property double heatindexC
    property double dewpointC

    property double visKm
    property double uv

    property double gustKph

    property double shortRad
    property double diffRad
    property double dni
    property double gti
}

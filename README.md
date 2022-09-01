# FloodNotice-iOS
SwiftUI based app to view USGS Stream Gage stations locations and the National Weather Service's Advanced Hydrologic Prediction Service output for each station.

## Overview

```mermaid
flowchart LR
    srcJSON[(<br>JSON of Stream Gages)]
    srcJSON --> mmv1(Interactive map<br>displaying all<br>stream gage locations)
    srcJSON --> lv1(Stream gages<br>ordered by state<br>then waterbody name)
    
    subgraph Main Map View
    mmv1
    end
    
    subgraph List View
    lv1
    end
    
    mmv1 -->|Select stream gage<br>by location|queryJSON{Query JSON for<br>stream gage data}
    lv1 -->|Select stream gage<br>by name|queryJSON
    
    queryJSON --> nwsID[(<br>NWS ID)]
    queryJSON --> gageGeo[(<br>Stream Gage<br>Geometry)]
    queryJSON --> gageWB[(<br>Waterbody Name)]
    queryJSON --> gageLoc[(<br>Location<br>Description)]
    
    gageGeo --> sgv1(Thumbnail map)
    gageWB --> sgv2(General description<br>of stream gage location)
    gageLoc --> sgv2
    nwsID --> parseXML{Retrieve & Parse<br>NWS AHPS data}
    
    parseXML --> floodStages[(<br>Flood Stages)]
    parseXML --> observations[(<br>Observations)]
    parseXML --> forecast[(<br>Forecast)]
    
    floodStages --> sgv3(Gage heights for Flood Stages)
    observations --> sgv4(Most recent observation)
    observations --> sgv5(Stream flow trend & forecast)
    forecast --> sgv5
    
    subgraph Stream Gage View
    sgv1
    sgv2
    sgv3
    sgv4
    sgv5
    end
```

---

## Demo

![Simulator Screen Recording - iPhone 11 - 2022-09-01 at 03 45 18](https://user-images.githubusercontent.com/22895187/187872425-b5f2f620-d91c-4a02-bc88-cd8eb7478260.gif)

---

## Current Coverage

```geojson
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "id": 1,
      "properties": {
        "ID": 0
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [
          [
              [-97.26691933,37.60076195],
              [-97.26691933,34.64466615],
              [-89.50761168,34.64466615],
              [-89.50761168,37.60076195],
              [-97.26691933,37.60076195]
          ]
        ]
      }
    }
  ]
}
```

---

## License

FloodNotice is released under the MIT license. See [LICENSE](LICENSE) for details.

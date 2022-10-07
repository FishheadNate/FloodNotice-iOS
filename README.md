# FloodNotice-iOS
Swift based iOS app to view stream gages with coverage by the National Weather Service's Advanced Hydrologic Prediction Service.

<img src='https://github.com/FishheadNate/FloodNotice-iOS/blob/main/samples/main_map.png' width='300'><img src='https://github.com/FishheadNate/FloodNotice-iOS/blob/main/samples/list_view.png' width='300'>

<img src='https://github.com/FishheadNate/FloodNotice-iOS/blob/main/samples/gage_view_1.png' width='300'><img src='https://github.com/FishheadNate/FloodNotice-iOS/blob/main/samples/gage_view_2.png' width='300'>

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
    
    observations --> sgv3(Current Stream Flow Status)
    floodStages --> sgv4(Gage heights for Flood Stages)
    observations --> sgv5(Most recent observation)
    forecast --> sgv6(Stream flow forecast)
    
    subgraph Stream Gage View
    sgv1
    sgv2
    sgv3
    sgv4
    sgv5
    sgv6
    end
```

---

## Demo

![Simulator Screen Recording - iPhone 14 Pro - 2022-10-06 at 14 30 40](https://user-images.githubusercontent.com/22895187/194402589-4bbc945a-f5f1-4570-becb-5f4135057580.gif)

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

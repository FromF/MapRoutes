//
//  MapViewModel.swift
//  MapRoutes
//
//  Created by 藤 治仁 on 2021/01/04.
//

import SwiftUI
import MapKit
import CoreLocation

// All Map Data Goes Here ...
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var mapView = MKMapView()
    
    /// 地図の表示範囲
    @Published var region: MKCoordinateRegion!
    
    /// 位置情報サービス不許可時のアラート表示
    @Published var permissionDenied = false
    
    /// 地図の表示種別
    @Published var mapType: MKMapType = .standard
    
    /// 検索するキーワード
    @Published var searchText = ""
    
    /// 検索結果の位置情報リスト
    @Published var places: [PlaceModel] = []
    
    /// 地図の表示種別を更新する
    func updateMapType() {
        if mapType == .standard {
            mapType = .hybrid
            mapView.mapType = mapType
        } else {
            mapType = .standard
            mapView.mapType = mapType
        }
    }
    
    /// 地図の表示範囲を更新する
    func focusLocation() {
        guard let _ = region else {
            return
        }
        
        // 地図の表示位置を更新する
        mapView.setRegion(region, animated: true)
        
        // 表示位置の移動アニメーションする
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    /// 検索するキーワードを使って検索する
    func searchQuery() {
        places.removeAll()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        // 検索する
        MKLocalSearch(request: request).start { (response, _) in
            guard let result = response else {
                return
            }
            
            self.places = result.mapItems.compactMap({ (item) -> PlaceModel? in
                return PlaceModel(placemark: item.placemark)
            })
        }
    }
    
    /// 検索結果の位置情報から選択する
    func selectPlace(place: PlaceModel) {
        //検索するキーワードをクリアする
        searchText = ""
        
        guard  let coordinate = place.placemark.location?.coordinate else {
            return
        }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        pointAnnotation.title = place.placemark.name ?? "No Name"
        
        // 検索結果の位置情報リストをクリアする
        mapView.removeAnnotations(mapView.annotations)
        
        mapView.addAnnotation(pointAnnotation)
        
        // 地図の表示範囲を位置情報から生成する
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        // 地図の表示位置を更新する
        mapView.setRegion(coordinateRegion, animated: true)
        
        // 表示位置の移動アニメーションする
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Checking Permissions...
        switch manager.authorizationStatus {
        case .notDetermined:
            //位置情報サービスの許可を得るためのダイヤログを表示する
            manager.requestWhenInUseAuthorization()
        case .denied:
            //位置情報サービスの許可が得られなかったので、アラート表示する
            permissionDenied.toggle()
        case .authorizedWhenInUse:
            //位置情報サービスの取得許可が得られたので位置情報を取得する
            manager.requestLocation()
        default:
        // .restricted:
        // .authorizedAlways:
            ()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // エラーが発生
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 現在地に基づいて地図の表示位置を変更する
        guard let location = locations.last else {
            return
        }
        
        // 地図の表示範囲を生成する
        region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        // 地図の表示位置を更新する
        mapView.setRegion(region, animated: true)
        
        // 表示位置の移動アニメーションする
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
}

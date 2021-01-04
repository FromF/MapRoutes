//
//  PlaceModel.swift
//  MapRoutes
//
//  Created by 藤 治仁 on 2021/01/04.
//

import SwiftUI
import MapKit

struct PlaceModel: Identifiable {
    var id = UUID().uuidString
    var placemark: CLPlacemark
}

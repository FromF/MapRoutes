//
//  HomeView.swift
//  MapRoutes
//
//  Created by 藤 治仁 on 2021/01/04.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    @StateObject var mapData = MapViewModel()
    // Location Manager...
    @State var locationManager = CLLocationManager()
    var body: some View {
        ZStack {
            MapView()
                // enviromentObjectとしてMKMapViewを使えるようにする
                .environmentObject(mapData)
                .ignoresSafeArea(.all, edges: .all)
            
            VStack {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search", text: $mapData.searchText)
                            .colorScheme(.light)
                        
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(Color.white)
                    
                    // 検索結果を表示する
                    if !mapData.places.isEmpty && mapData.searchText != "" {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(mapData.places) { place in
                                    Text(place.placemark.name ?? "")
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .onTapGesture {
                                            mapData.selectPlace(place: place)
                                        }
                                    
                                    Divider()
                                }
                            }
                            .padding(.top)
                        }
                        .background(Color.white)
                    }
                }
                .padding()

                Spacer()
                
                VStack {
                    Button(action: mapData.focusLocation) {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }

                    Button(action: mapData.updateMapType) {
                        Image(systemName: mapData.mapType == .standard ? "network" : "map")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            }
            
        }
        .onAppear(perform: {
            // Delegateを設定する
            locationManager.delegate = mapData
            //位置情報サービスの許可を得るためのダイヤログを表示する
            locationManager.requestWhenInUseAuthorization()
        })
        // 位置情報サービスの許可が得られなかったので、アラート表示する
        .alert(isPresented: $mapData.permissionDenied, content: {
            Alert(title: Text("位置情報サービスがオフになっています"), message: Text("位置情報サービスをオンにすると、地図に現在地を表示できるようになります"), dismissButton: .default(Text("設定でオンにする"), action: {
                // Redireting User To Settings
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
        })
        .onChange(of: mapData.searchText, perform: { value in
            // 検索するキーワードで検索をする
            // 時間を遅延させて連続で検索しないようにする
            let delay = 0.3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if value == mapData.searchText {
                    // 検索実行
                    self.mapData.searchQuery()
                }
            }
        })
        //ダークモードの配色を確認するときにコメントを消して有効化する
//        .preferredColorScheme(.dark)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

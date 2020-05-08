//
//  SlideMenuView.swift
//  MapsDirectionsGooglePlaces_LBTA
//
//  Created by Brian Voong on 1/4/20.
//  Copyright © 2020 Brian Voong. All rights reserved.
//

import SwiftUI
import MapKit

struct MenuItem: Identifiable, Hashable {
    let id = UUID().uuidString
    let title: String
    let mapType: MKMapType
    let imageName: String
}

struct SlideMenuView: View {
    
    @State var isMenuShowing = false
    @State var mapType: MKMapType = .standard
    
    let menuItems: [MenuItem] = [
        .init(title: "Standard", mapType: .standard, imageName: "car"),
        .init(title: "Hybrid", mapType: .hybrid, imageName: "antenna.radiowaves.left.and.right"),
        .init(title: "Globe", mapType: .satelliteFlyover, imageName: "safari")
    ]
    
    var body: some View {
        ZStack {
            SlideMenuMapView(mapType: mapType)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                VStack {
                    Button(action: {
                        self.isMenuShowing.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle.fill")
                        .font(.system(size: 34))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    }
                    
                    Spacer()
                }
                Spacer()
            }.padding()
            
            Color(.init(white: 0, alpha: self.isMenuShowing ? 0.5 : 0))
                .edgesIgnoringSafeArea(.all)
                .animation(.spring())
            
            HStack {
                ZStack {
                    
                    Color(.systemBackground)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            self.isMenuShowing.toggle()
                    }
                    
                    HStack {
                        VStack {
                            HStack {
                                Text("Menu")
                                .font(.system(size: 26, weight: .bold))
                                Spacer()
                            }
                            
                                .padding()
                            
                            VStack {
                                ForEach(menuItems, id: \.self) { item in
                                    
                                    Button(action: {
                                        self.mapType = item.mapType
                                        self.isMenuShowing.toggle()
                                    }) {
                                        
                                        HStack (spacing: 16) {
                                            Image(systemName: item.imageName)
                                            
                                            Text(item.title)
                                            
                                            Spacer()
                                        }.padding()
                                    }.foregroundColor(self.mapType != item.mapType ? Color(.label) : Color(.systemBackground))
                                        .background(self.mapType == item.mapType ? Color(.label) : Color(.systemBackground))
                                    
                                    
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                self.isMenuShowing.toggle()
                            }, label: {
                                Text("Dismiss")
                            })
                        }
                        Spacer()
                    }
                    
                }.frame(width: 200)
                
                Spacer()
            }.offset(x: self.isMenuShowing ? 0 : -200)
                .animation(.spring())
        }
    }
}

struct SlideMenuMapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    var mapType: MKMapType
    
    func makeUIView(context: UIViewRepresentableContext<SlideMenuMapView>) -> MKMapView {
        MKMapView()
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<SlideMenuMapView>) {
        uiView.mapType = mapType
    }
}

struct SlideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([ColorScheme.dark, .light], id: \.self) { scheme in
            SlideMenuView().colorScheme(scheme)
        }
        
//        VStack {
//            SlideMenuView().colorScheme(.dark)
//            SlideMenuView().colorScheme(.light)
//        }
        
    }
}

//
//  MapView.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 1/23/25.
//

import SwiftUI
import MapKit

// =============================================================
// A VIEW that renders the UI displaying data from the VIEWMODEL
// (V in MVVM Model-View-ViewModel)
// =============================================================

struct MapView: View {
    
    //@EnvironmentObject var viewModel: PinTaskViewModel
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject var dataManager: DataManager
    
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 41.826084,
            longitude: -71.403246
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.005,
            longitudeDelta: 0.005
        )
    )
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isOnUserLocation = true
    @State private var showingAddSheet = false
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    
    @StateObject var sheetManager = SheetManager()
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PinTask.deadline, ascending: true)])
    private var pinTasks: FetchedResults<PinTask>
    
    var body: some View {
        ZStack {
            MapReader { proxy in
                Map(position: $cameraPosition) {
                    ForEach(pinTasks, id: \.self) { pinTask in
                        Marker("Task", coordinate: CLLocationCoordinate2D(
                            latitude: pinTask.latitude,
                            longitude: pinTask.longitude
                        ))
                        MapCircle(
                            center: CLLocationCoordinate2D(
                                latitude: pinTask.latitude,
                                longitude: pinTask.longitude
                            ),
                            radius: 50
                        )
                        .foregroundStyle(.blue.opacity(0.30))
                        .mapOverlayLevel(level: .aboveLabels)
                    }
                    UserAnnotation()
                }
                .mapStyle(.standard)
                .onTapGesture { position in
                    if let coordinate = proxy.convert(position, from: .local) {
                        selectedCoordinate = coordinate
                        sheetManager.showSheet = true
                    }
                }
                .gesture(
                    DragGesture()
                    .onChanged{ _ in
                        isOnUserLocation = false
                    }
                )
            }
            VStack {
                Spacer()
                    .frame(height: 60)
                HStack {
                    Spacer()
                    RecenterButton(
                        isOnUserLocation: $isOnUserLocation,
                        cameraPosition: $cameraPosition
                    )
                        .padding()
                        .shadow(radius: 10)
                }
                Spacer()
            }
            
            
        }
        .sheet(isPresented: $sheetManager.showSheet, content:{
            if let coordinate = selectedCoordinate {
                PinTaskInputForm(
                    coordinate: coordinate,
                    onSave: {coordinate in
                        
                    })
            }
        })
        .onAppear {
            locationManager.checkIfLocationServicesIsEnable()
        }
        .onChange(of: locationManager.isLocationReady) { oldValue, newValue in
            if newValue && isOnUserLocation{
                cameraPosition = .userLocation(fallback: .automatic)
            }
        }
        .onChange(of: locationManager.userLocation) { oldValue, newValue in
            if let locationWrapper = newValue,
               let boundingBox = locationManager.calculateBoundingBox() {
                dataManager.removePinTasksWithin50Meters(
                    userLocation: locationWrapper.coordinate,
                    boundingbox: boundingBox,
                    context: viewContext
                )
            }
        }
        .alert(item: $locationManager.alertItem) { alertItem in
            Alert(
                title: alertItem.title,
                message: alertItem.message,
                dismissButton: alertItem.dismissButton
            )
        }
        .alert(item: $dataManager.alertItem) { alertItem in
            Alert(title: alertItem.title,
                      message: alertItem.message,
                      dismissButton: alertItem.dismissButton)
        }
    }
    
    
    
}

#Preview {
    let dataManager = DataManager()
    MapView()
        .environmentObject(dataManager)
        .environmentObject(LocationManager())
        .environment(\.managedObjectContext, dataManager.container.viewContext)
}

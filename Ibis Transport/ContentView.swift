import CoreLocation
import SwiftUI
import MapKit

struct ContentView: View {
    @Environment(\.modelContext) private var context
    let locationManager = CLLocationManager()
    @State var showHomeSheet = true
    
    // Initialize stationService lazily without passing context in init
    @StateObject private var trainStupid = stationService()
    @State private var stations: [stationData] = []
    @State private var cameraLocation: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -33.866464, longitude: 151.200923),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $cameraLocation, annotationItems: stations) { station in
                MapAnnotation(coordinate: station.stopCoord.toCLLocationCoordinate2D()) {
                    Circle()
                        .strokeBorder(Color.blue, lineWidth: 2)
                        .frame(width: 20, height: 20)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
            }
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
                deviceLocationService.shared.requestLocationUpdates()
                
                // Set the model context for the stationService object after view appears
                trainStupid.modelContext = context
                trainStupid.subscribeToLocationUpdates()
                trainStupid.fetchNearbyTrainStations { fetchedStations in
                    if let fetchedStations = fetchedStations {
                        self.stations = fetchedStations
                    }
                }
                
                // Update camera location to user's actual location
                if let userLocation = locationManager.location?.coordinate {
                    cameraLocation.center = userLocation
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showHomeSheet.toggle()
                    } label: {
                        Image(systemName: "house")
                    }
                    .frame(alignment: .bottomTrailing)
                    .buttonStyle(.bordered)
                    .background(Color.white)
                    .buttonBorderShape(.roundedRectangle)
                    .controlSize(.regular)
                    .padding()
                    Button {
                        trainStupid.fetchNearbyTrainStations { fetchedStations in
                            if let fetchedStations = fetchedStations {
                                self.stations = fetchedStations
                                stations.forEach { print($0) }
                            }
                        }
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .frame(alignment: .bottomTrailing)
                    .buttonStyle(.bordered)
                    .background(Color.white)
                    .buttonBorderShape(.roundedRectangle)
                    .controlSize(.regular)
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showHomeSheet) {
            homeSheetView()
                .presentationDetents([.fraction(0.20), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(50)
                .presentationBackground(.ultraThinMaterial)
                .presentationBackgroundInteraction(.enabled)
        }
    }
}

struct homeSheetView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Ibis Transport")
                    .fontWeight(.bold)
                    .fontWidth(.expanded)
                    .font(.system(size: 30))
                MapUserLocationButton()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(30)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: stationData.self)
    }
}

extension stationData.Coordinate2D {
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

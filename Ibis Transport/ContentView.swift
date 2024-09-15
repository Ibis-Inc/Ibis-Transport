import SwiftUI
import MapKit
import CoreLocation

class SharedStationService: ObservableObject {
    @Published var stations: [stationData] = []
    let service = stationService()
    
    @MainActor func fetchNearbyTrainStations(completion: @escaping ([stationData]?) -> Void) {
        service.fetchNearbyTrainStations { fetchedStations in
            if let fetchedStations = fetchedStations {
                DispatchQueue.main.async {
                    self.stations = fetchedStations
                }
            }
            completion(fetchedStations)
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var context
    let locationManager = CLLocationManager()
    @State var showHomeSheet = true
    
    @StateObject private var sharedService = SharedStationService()
    @State private var cameraLocation: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -33.866464, longitude: 151.200923),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ZStack {
            Map() {
                UserAnnotation()
                
                ForEach(sharedService.stations) { station in
                    Marker(station.stopName ,coordinate: station.stopCoord.toCLLocationCoordinate2D())
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
                sharedService.service.modelContext = context
                sharedService.service.subscribeToLocationUpdates()
                sharedService.fetchNearbyTrainStations { _ in }
                
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
                        sharedService.fetchNearbyTrainStations { _ in }
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
            homeSheetView(sharedService: sharedService)
                .presentationDetents([.fraction(0.20), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(50)
                .presentationBackground(.ultraThinMaterial)
                .presentationBackgroundInteraction(.enabled)
        }
    }
}

struct homeSheetView: View {
    @ObservedObject var sharedService: SharedStationService
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Ibis Transport")
                    .fontWeight(.bold)
                    .fontWidth(.expanded)
                    .font(.system(size: 30))
                
                Button {
                    sharedService.fetchNearbyTrainStations { _ in }
                } label: {
                    Image(systemName: "pencil")
                }
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

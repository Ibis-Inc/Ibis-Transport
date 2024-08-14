import Swift
import SwiftUI
import MapKit

struct ContentView: View {
    let locationManager = CLLocationManager()
    @State var showHomeSheet = true
    @State private var cameraLocation: MapCameraPosition = .userLocation(fallback: .automatic)
    var body: some View {
        ZStack {
            Map(position: $cameraLocation) {
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
            }
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
            }
        }
        .sheet(isPresented: $showHomeSheet) {
            homeSheetView()
                .presentationDetents([.fraction(0.20), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(50)
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

struct homeSheetView: View {
    var body: some View {
            VStack (alignment: .leading) {
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
    }
}

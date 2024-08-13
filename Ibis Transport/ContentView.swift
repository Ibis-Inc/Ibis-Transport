import Swift
import SwiftUI
import MapKit

struct ContentView: View {
    
    @State var showHomeSheet = true
    
    var body: some View {
        ZStack {
            Map() {
            }
            .mapStyle(.standard(elevation: .realistic))
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
                Text("Ibis Transport")
                    .fontWeight(.bold)
                    .fontWidth(.expanded)
                    .font(.system(size: 30))
                Spacer()
                    .frame(height: 60)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

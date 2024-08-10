import Swift
import SwiftUI
import MapKit

struct ContentView: View {
    
    @State var showHomeSheet = false
    
    var body: some View {
        ZStack {
            Map() {
            }
            .mapStyle(.standard(elevation: .realistic))
            
            Button("Show Home Sheet") {
                showHomeSheet.toggle()
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $showHomeSheet) {
            Text("This is le home screen!!!")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

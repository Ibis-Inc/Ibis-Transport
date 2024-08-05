import Swift
import SwiftUI

let apiKey = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJyWDFuQkF3S1ljdll2YWNUazRHYnQtLVlKbDFTMGgtVnNjeXhNSzNJeGZrIiwiaWF0IjoxNzIyNDc5OTMxfQ.9jSZ0RbZ2k7G7Pd4GwoRLhLPHxSyg1dZerFy2bOInHo"

struct ContentView: View {
    let hi: () = getStaticZip()
    var body: some View {
        Text("hi")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import Foundation
import Alamofire

let manager = FileManager.default
let headers: HTTPHeaders = [
    "accept": "application/octet-stream",
    "Authorization": "apikey eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiIyWEt5R0JlR210UjRjV1BJY0tKbThZUG4tSWNtbFJOTm9VQnJ5OENBWXUwIiwiaWF0IjoxNzIyNTEyNTIxfQ.st62SoiLldZGM1mEHJ5VtXMPxx9p7gebsx9Gvz9TknY"
]


public func getStaticZip() {
    guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    
    let gtfsFolderDir = url.appendingPathComponent("gtfs")
    
    do {
        try FileManager.default.createDirectory(at: gtfsFolderDir, withIntermediateDirectories: true)
    } catch {
        print(error)
    }
    
    let destination: DownloadRequest.Destination = { _, _ in
        let fileURL = gtfsFolderDir.appendingPathComponent("gtfs.zip")
        return (fileURL, [.removePreviousFile])
    }
    
    AF.download("https://api.transport.nsw.gov.au/v1/publictransport/timetables/complete/gtfs", headers: headers, to: destination).response { response in
        debugPrint(response)
    }
}

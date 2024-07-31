//
//  staticTimetableFetch.swift
//  Ibis Transport
//
//  Created by appleshoops on 31/7/2024.
//

import Foundation

let url = URL(string: "https://api.transport.nsw.gov.au/v1/publictransport/timetables/complete/gtfs")!
let headers = [
    "accept": "application/octet-stream",
    "Authorization": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJyR040V09TbmtDeTNHQ01VWlU2b0JjOG5kTlh6R2JpOHhVbjVRekstLTk0IiwiaWF0IjoxNzIxOTA0OTQ3fQ.xMcpdlIrxLPysiE8eC68Gql7PiWu0GKh2V7m7pqwAO0"
]

func fetchStaticTimetable(completionHandler: @escaping (String) -> Void) {
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = headers

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print(error)
        } else if let data = data {
            let str = String(data: data, encoding: .utf8)
            print(str ?? "")
            completionHandler(str ?? "")
        }
    }
    task.resume()
}


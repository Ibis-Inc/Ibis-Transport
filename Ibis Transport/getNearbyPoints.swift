//
//  getNearbyPoints.swift
//  Ibis Transport
//
//  Created by appleshoops on 15/8/24.
//

import Foundation
import Combine
import CoreLocation
import Alamofire
import SwiftData
import MapKit

@Model
class stationData {
    var id: String
    var name: String
    var coord: CLLocationCoordinate2D
    var type: String
    
}

class stationService {
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribeToLocationUpdates()
    }
    
    private func subscribeToLocationUpdates() {
        deviceLocationService.shared.coordinatesPublisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(_):
                    print("Failed To Get Location:")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] coordinate in
                self?.fetchNearbyTrainStations(latitude: coordinate.latitude, longitude: coordinate.longitude)
            })
            .store(in: &cancellables)
    }
    
    private func fetchNearbyTrainStations(latitude: Double, longitude: Double) {
        let api = "https://api.transport.nsw.gov.au/v1/tp/coord?outputFormat=rapidJSON&coord="
        let endString = "%3AEPSG%3A4326&coordOutputFormat=EPSG%3A4326&inclFilter=1&type_1=POI_POINT&radius_1=1000&PoisOnMapMacro=true&version=10.2.1.42"
        let latitudeString = String(format: "%.6f", latitude)
        let longitudeString = String(format: "%.6f", longitude)
        let urlString = api + longitudeString + "%38" + latitudeString + endString
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "apikey \(apiKey)"
        ]
        guard let url = URL(string: urlString) else {
            print("invalid url!!!")
            return
        }
        
        AF.request(url, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                guard let json = value as? [String: Any],
                      let locations = json["locations"] as? [[String: Any]] else {
                    print("Invalid JSON Thing")
                    return
                }
            case .failure(let error):
                print("Error \(error)")
            }
        }
    }
    
    private func saveStationData(locations: [[String: Any]]) {
        
    }
}

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

@Model
final class stationData {
    var stopID: String
    var stopName: String
    var stopType: String
    var stopCoord: CLLocationCoordinate2D
    
    init(stopID: String, stopName: String, stopType: String, stopCoord: CLLocationCoordinate2D) {
        self.stopID = stopID
        self.stopName = stopName
        self.stopType = stopType
        self.stopCoord = stopCoord
    }
}

public class stationService: ObservableObject {
    @Published var locations: [[String: Any]] = []
    
    private var longitude: Double?
    private var latitiude: Double?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribeToLocationUpdates()
    }
    
    public func subscribeToLocationUpdates() {
        deviceLocationService.shared.coordinatesPublisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(_):
                    print("Failed To Get Location:")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] coordinate in
                self?.longitude = coordinate.longitude
                self?.latitiude = coordinate.latitude
            })
            .store(in: &cancellables)
    }
    
    public func fetchNearbyTrainStations() {
        guard let latitude = self.latitiude, let longitude = self.longitude else {
            print("No coordinates available!!!")
            return
        }
        
        let api = "https://api.transport.nsw.gov.au/v1/tp/coord?outputFormat=rapidJSON&coord="
        let endString = "%3AEPSG%3A4326&coordOutputFormat=EPSG%3A4326&inclFilter=1&type_1=BUS_POINT&radius_1=1000&PoisOnMapMacro=true&version=10.2.1.42"
        let percentThing = "%3A"
        let latitudeString = String(format: "%.6f", latitude)
        let longitudeString = String(format: "%.6f", longitude)
        let urlString = api + longitudeString + percentThing + latitudeString + endString
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "apikey \(apiKey)"
        ]
        guard let url = URL(string: urlString) else {
            print("invalid url!!!")
            return
        }
        
        AF.request(url, headers: headers).responseJSON { [ weak self ] response in guard let self = self else { return }
            switch response.result {
            case .success(let value):
                guard let json = value as? [String: Any],
                      let locations = json["locations"] as? [[String: Any]]

                else {
                    print("Invalid JSON Thing: \(value)")
                    return
                }
                print("Locations: \(locations)")
            case .failure(let error):
                print("Error \(error)")
            }
            print(self.locations)
            print(urlString)
        }
        
        
    }
}

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
final class stationData: Decodable {
    struct Coordinate2D: Codable {
        let latitude: Double
            let longitude: Double

            init(latitude: Double, longitude: Double) {
                self.latitude = latitude
                self.longitude = longitude
            }
    }
    
    var stopID: String
    var stopName: String
    var stopType: String
    var stopCoord: Coordinate2D
    
    enum CodingKeys: String, CodingKey {
            case stopID = "stop_id"
            case stopName = "stop_name"
            case stopType = "stop_type"
            case stopCoord = "stop_coord"
        }
    
    init(stopID: String, stopName: String, stopType: String, stopCoord: Coordinate2D) {
        self.stopID = stopID
        self.stopName = stopName
        self.stopType = stopType
        self.stopCoord = stopCoord
    }
    
    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            stopID = try container.decode(String.self, forKey: .stopID)
            stopName = try container.decode(String.self, forKey: .stopName)
            stopType = try container.decode(String.self, forKey: .stopType)
            
        _ = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .stopCoord)
        stopCoord = try container.decode(Coordinate2D.self, forKey: .stopCoord)
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
    
    public func fetchNearbyTrainStations(completion: @escaping (([[String: Any]])?) -> Void) {
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
        
        AF.request(url, headers: headers).responseDecodable(of: [stationData].self) { [self] response in
            switch response.result {
            case .success(let stations):
                let locations = stations.map { station -> [String: Any] in
                                return [
                                    "id": station.id,
                                    "name": station.stopName,
                                    "type": station.stopType,
                                    "latitude": station.stopCoord.latitude,
                                    "longitude": station.stopCoord.longitude
                                ]
                            }
                print("Locations: \(locations)")
                completion(locations)
            case .failure(let error):
                print("Error \(error)")
                completion(nil)
            }
            print(self.locations)
            print(urlString)
        }
        
        
    }
    
    public func saveStationsToModel() {
            fetchNearbyTrainStations { [weak self] locations in
                guard let self = self, let locations = locations else { return }
                
                for location in locations {
                    if let stopID = location["stopID"] as? String,
                       let stopName = location["stopName"] as? String,
                       let stopType = location["stopType"] as? String,
                       let stopCoordDict = location["stopCoord"] as? [String: Double],
                       let latitude = stopCoordDict["latitude"],
                       let longitude = stopCoordDict["longitude"] {
                        
                        let stopCoord = stationData.Coordinate2D(latitude: latitude, longitude: longitude)
                        let station = stationData(stopID: stopID, stopName: stopName, stopType: stopType, stopCoord: stopCoord)
                        
                        // Save to SwiftData model
                        do {
                            try SwiftData.save(station)
                        } catch {
                            print("Failed to save station: \(error)")
                        }
                    }
                }
            }
        }
}

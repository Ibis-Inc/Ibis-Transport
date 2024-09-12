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
import SwiftUI

@Model
public final class stationData: Decodable, CustomStringConvertible, Identifiable, Hashable {
    struct Coordinate2D: Codable {
        let latitude: Double
        let longitude: Double

        init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    @Attribute(.unique)
    var stopID: String
    var stopName: String
    var stopType: String
    var stopCoord: Coordinate2D
    
    enum CodingKeys: String, CodingKey {
        case stopID = "id"
        case stopName = "name"
        case stopType = "type"
        case stopCoord = "coord"
    }

    init(stopID: String, stopName: String, stopType: String, stopCoord: Coordinate2D) {
        self.stopID = stopID
        self.stopName = stopName
        self.stopType = stopType
        self.stopCoord = stopCoord
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stopID = try container.decode(String.self, forKey: .stopID)
        stopName = try container.decode(String.self, forKey: .stopName)
        stopType = try container.decode(String.self, forKey: .stopType)
        let coord = try container.decode([Double].self, forKey: .stopCoord)
        stopCoord = Coordinate2D(latitude: coord[0], longitude: coord[1])
    }

    // Custom description
    public var description: String {
        return "Station ID: \(stopID), Name: \(stopName), Type: \(stopType), Coordinates: (\(stopCoord.latitude), \(stopCoord.longitude))"
    }
}



public class stationService: ObservableObject {
    @Published var locations: [[String: Any]] = []

    private var longitude: Double?
    private var latitiude: Double?

    private var cancellables = Set<AnyCancellable>()

    // Make modelContext optional
    public var modelContext: ModelContext?

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
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

    @MainActor
    public func fetchNearbyTrainStations(completion: @escaping ([stationData]?) -> Void) {
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

        AF.request(url, headers: headers).responseJSON { [weak self] response in
            guard let self = self else { return }

            switch response.result {
            case .success(let json):
                guard let jsonDict = json as? [String: Any],
                      let locationsArray = jsonDict["locations"] as? [[String: Any]] else {
                    print("Failed to decode JSON structure")
                    completion(nil)
                    return
                }

                let stationDataList = locationsArray.compactMap { dict -> stationData? in
                    let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
                    return try? JSONDecoder().decode(stationData.self, from: jsonData ?? Data())
                }

                // Safely unwrap modelContext before using it
                if let modelContext = self.modelContext {
                    stationDataList.forEach { modelContext.insert($0) }

                } else {
                    print("Model context is nil, cannot insert data")
                }
                
                
                completion(stationDataList)

            case .failure(let error):
                print("Error \(error)")
                completion(nil)
            }
        }
    }

}

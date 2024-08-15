//
//  getNearbyPoints.swift
//  Ibis Transport
//
//  Created by appleshoops on 15/8/24.
//

import Foundation
import Combine
import CoreLocation

class stationService {
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribeToLocationUpdates()
    }
    
    private func subscribeToLocationUpdates() {
        deviceLocationService.shared.coordinatesPublisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
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
        
    }
}

//
//  RemoteConfigValues.swift
//  ShoppingList
//
//  Created by Eric Alves Brito on 15/09/20.
//  Copyright © 2020 DevBoost. All rights reserved.
//

import Foundation
import Firebase

class RemoteConfigValues {
    
    static let shared = RemoteConfigValues()
    let rc = RemoteConfig.remoteConfig()
    
    private init() {
        loadDefaultValues()
    }
    
    private func loadDefaultValues() {
        let defaultValues: [String: Any] = [
            "copyrightMessage": "Sendo um",
            "featureToggle": "{\"addItem\":true,\"editItem\":false,\"deleteItem\":false}"
        ]
        
        rc.setDefaults(defaultValues as? [String: NSObject])
    }
    
    func fetch() {
        rc.fetch(withExpirationDuration: 5) { (status, error) in
            switch status {
            case .failure:
                print("Falha")
            case .noFetchYet:
                print("Não foi feito fetch")
            case .throttled:
                print("Throttled")
            case .success:
                print("Sucesso")
                self.rc.activate { (error) in
                    if let error = error {
                        print(error)
                    }
                }
            @unknown default:
                print("Desconhecido")
            }
        }
    }
    
    var copyrightMessage: String {
        rc.configValue(forKey: "copyrightMessage").stringValue ?? "Sendo outro"
    }
    
    var featureToggle: [String: Bool] {
        do {
            let featureToggle = try JSONDecoder().decode([String: Bool].self, from: rc.configValue(forKey: "featureToggle").dataValue)
            return featureToggle
        } catch {
            return ["addItem": true, "editItem": false, "deleteItem": false]
        }
    }
}

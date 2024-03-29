//
//  Bundle+Extensions.swift
//  MxNetworking_Tests
//
//  Created by Uriel Hernandez Gonzalez on 10/04/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

extension Bundle {
    static func getDataFromFile(_ fileName: String, type: String) -> Data? {
        if let fileURL = Bundle(for: MxNetworkerTests.self).path(forResource: fileName, ofType: type) {
            let resourceData = try? Data(contentsOf: URL(fileURLWithPath: fileURL))
            return resourceData
        }

        return nil
    }
}

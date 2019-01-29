//
//  ShoutMessage.swift
//  Lab2_TemplateApp
//
//  Created by Mateusz Wydmański on 26.01.2019.
//  Copyright © 2019 KIS AGH. All rights reserved.
//

import Foundation

struct ShoutMessageResponse: Codable {
    var entries: [ShoutMessage] = []
 }

class ShoutMessage: Codable {
    var id: String = ""
    var name: String = ""
    var message: String = ""
    var timestamp: String = ""
}

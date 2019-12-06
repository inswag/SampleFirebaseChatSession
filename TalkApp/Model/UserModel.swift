//
//  UserModel.swift
//  TalkApp
//
//  Created by 박인수 on 17/11/2019.
//  Copyright © 2019 inswag. All rights reserved.
//

import ObjectMapper // Codable 보다 ObjectMapper 가 더 안정적 의견...!

struct UserModel: Mappable {
    
    var userName : String?
    var uid : String?
    var profileImageUrl : String?

    init() {
        
    }
    
    init?(map: Map) {
           
    }
    
    mutating func mapping(map: Map) {
        userName <- map["userName"]
        uid <- map["uid"]
        profileImageUrl <- map["profileImageUrl"]
    }
    
}

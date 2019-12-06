//
//  ChatModel.swift
//  TalkApp
//
//  Created by 박인수 on 24/11/2019.
//  Copyright © 2019 inswag. All rights reserved.
//

import ObjectMapper

struct ChatModel: Mappable {
    
    var comments: [String: Comment] = [:]
    var users: [String: Bool] = [:]
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        comments <- map["comments"]
        users <- map["users"]
    }
    
    struct Comment: Mappable {
        
        var uid: String?
        var message: String?
        var timestamp: Int?
        
        init?(map: Map) {
            
        }
        
        mutating func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
            timestamp <- map["timestamp"]
        }
        
    }
    
}

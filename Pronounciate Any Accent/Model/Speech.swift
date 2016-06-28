//
//  Speech.swift
//  Pronounciate Any Accent
//
//  Created by Maxwell Zhou on 6/27/16.
//  Copyright © 2016 Max. All rights reserved.
//

import Foundation

struct Speech {
    var speakerName: String?
    var speechName: String?
    var rating: Float
    var imageUrlString: String?
    
    init(speakerName: String?, speechName: String?, rating: Float, imageUrlString: String?) {
        self.speakerName = speakerName
        self.speechName = speechName
        self.rating = rating
        self.imageUrlString = imageUrlString
    }
}

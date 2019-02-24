//
//  HashTagApi.swift
//  InstagramClone
//
//  Created by Violet Wei on 2018-12-27.
//  Copyright © 2018 Violet Wei. All rights reserved.
//

import Foundation
import FirebaseDatabase
class HashTagApi {
    var REF_HASHTAG = Database.database().reference().child("hashTag")
    
    func fetchPosts(withTag tag: String, completion: @escaping (String) -> Void) {
        REF_HASHTAG.child(tag.lowercased()).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
}

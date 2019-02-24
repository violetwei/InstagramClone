//
//  Comment.swift
//  InstagramClone
//
//  Created by Violet Wei on 2018-12-28.
//  Copyright © 2018 Violet Wei. All rights reserved.
//

import Foundation

class Comment {
    var commentText: String?
    var uid: String?
}

extension Comment {
    static func transformComment(dict: [String: Any]) -> Comment {
        let comment = Comment()
        comment.commentText = dict["commentText"] as? String
        comment.uid = dict["uid"] as? String
        return comment
    }
}

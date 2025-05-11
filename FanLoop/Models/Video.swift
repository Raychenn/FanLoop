//
//  Video.swift
//  FanLoop
//
//  Created by Boray Chen on 2025/5/10.
//

import Foundation

struct Video: Codable {
    let id: String
    let title: String
    let subTitle: String
    let url: String
}

extension Video {
    static func stub(id: String = "1",
                    title: String = "Test Video",
                    subTitle: String = "Test Subtitle",
                    url: String = "test_url") -> Video {
        Video(id: id, title: title, subTitle: subTitle, url: url)
    }
}

extension Video: Equatable {
    public static func == (lhs: Video, rhs: Video) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.subTitle == rhs.subTitle &&
        lhs.url == rhs.url
    }
}

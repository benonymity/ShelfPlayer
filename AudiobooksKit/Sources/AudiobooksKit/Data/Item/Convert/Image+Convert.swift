//
//  Image+Convert.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 03.10.23.
//

import Foundation

extension Item.Image {
    static func convertFromAudiobookshelf(item: AudiobookshelfClient.AudiobookshelfItem) -> Item.Image? {
        if (item.mediaType == "book" || item.mediaType == "podcast") && item.media?.coverPath != nil {
            return Item.Image(url: AudiobookshelfClient.shared.serverUrl
                .appending(path: "api")
                .appending(path: "items")
                .appending(path: item.id)
                .appending(path: "cover")
                .appending(queryItems: [
                    URLQueryItem(name: "token", value: AudiobookshelfClient.shared.token),
                ])
            )
        } else if item.name != nil && item.imagePath != nil {
            // item is author
            return Item.Image(url: AudiobookshelfClient.shared.serverUrl
                .appending(path: "api")
                .appending(path: "authors")
                .appending(path: item.id)
                .appending(path: "image")
                .appending(queryItems: [
                    URLQueryItem(name: "token", value: AudiobookshelfClient.shared.token),
                ])
            )
        }
        
        return nil
    }
    
    static func convertFromAudiobookshelf(podcast: AudiobookshelfClient.AudiobookshelfItem.AudiobookshelfPodcastEpisode.AudiobookshelfItemPodcast) -> Item.Image? {
        if podcast.coverPath != nil {
            return Item.Image(url: AudiobookshelfClient.shared.serverUrl
                .appending(path: "api")
                .appending(path: "items")
                .appending(path: podcast.libraryItemId)
                .appending(path: "cover")
                .appending(queryItems: [
                    URLQueryItem(name: "token", value: AudiobookshelfClient.shared.token),
                ])
            )
        }
        
        return nil
    }
}

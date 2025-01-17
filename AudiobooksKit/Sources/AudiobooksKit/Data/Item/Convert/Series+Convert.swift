//
//  Series+Convert.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 04.10.23.
//

import Foundation

extension Series {
    static func convertFromAudiobookshelf(item: AudiobookshelfClient.AudiobookshelfItem) -> Series {
        Series(
            id: item.id,
            additionalId: nil,
            libraryId: item.libraryId ?? "",
            name: item.name!,
            author: nil,
            description: item.description,
            image: nil,
            genres: [],
            addedAt: Date(timeIntervalSince1970: (item.addedAt ?? 0) / 1000),
            released: nil,
            images: item.books?.reduce([], {
                if let image = Image.convertFromAudiobookshelf(item: $1) {
                    return $0 + [image]
                }
                
                return $0
            }) ?? [])
    }
    static func convertFromAudiobookshelf(item: AudiobookshelfClient.AudiobookshelfItem, books: [AudiobookshelfClient.AudiobookshelfItem]) -> Series {
        Series(
            id: item.id,
            additionalId: nil,
            libraryId: item.libraryId ?? "",
            name: item.name!,
            author: nil,
            description: item.description,
            image: nil,
            genres: [],
            addedAt: Date(timeIntervalSince1970: (item.addedAt ?? 0) / 1000),
            released: nil,
            images: books.reduce([], {
                if let image = Image.convertFromAudiobookshelf(item: $1) {
                    return $0 + [image]
                }
                
                return $0
            }))
    }
}

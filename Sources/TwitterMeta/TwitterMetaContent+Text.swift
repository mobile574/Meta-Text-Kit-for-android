//
//  TwitterMetaContent+Text.swift
//  iOS Example
//
//  Created by MainasuK Cirno on 2021-7-13.
//

import Foundation
import Meta

extension TwitterMetaContent {

    public static func convert(
        content: TwitterContent,
        urlMaximumLength: Int,
        twitterTextProvider: TwitterTextProvider
    ) -> TwitterMetaContent {
        let original = content.content
        var entities: [Meta.Entity] = []
        let twitterTextEntities = twitterTextProvider.entities(in: original)

        for twitterTextEntity in twitterTextEntities {
            let range = twitterTextEntity.range
            guard let text = original.string(in: range) else { continue }
            switch twitterTextEntity {
            case .url:
                let entity = Meta.Entity(
                    range: range,
                    meta: .url(text, trimmed: text.trim(to: urlMaximumLength), url: text, userInfo: nil)
                )
                entities.append(entity)
            case .screenName:
                let mention = text.hasPrefix("@") ? String(text.dropFirst()) : text
                let entity = Meta.Entity(
                    range: range,
                    meta: .mention(text, mention: mention, userInfo: nil)
                )
                entities.append(entity)
            case .hashtag:
                let hashtag = text.hasPrefix("#") ? String(text.dropFirst()) : text
                let entity = Meta.Entity(
                    range: range,
                    meta: .hashtag(text, hashtag: hashtag, userInfo: nil)
                )
                entities.append(entity)
            case .listName:
                continue
            case .symbol:
                continue
            case .tweetChar:
                continue
            case .tweetEmojiChar:
                continue
            }
        }

        let trimmed = Meta.trim(content: original, orderedEntities: entities)

        return TwitterMetaContent(
            original: original,
            trimmed: trimmed,
            entities: entities
        )
    }

}

fileprivate extension String {
    func string(in nsrange: NSRange) -> String? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return String(self[range])
    }

    func trim(to maximumCharacters: Int) -> String {
        guard maximumCharacters > 0, count > maximumCharacters else {
            return self
        }
        return "\(self[..<index(startIndex, offsetBy: maximumCharacters)])" + "..."
    }
}

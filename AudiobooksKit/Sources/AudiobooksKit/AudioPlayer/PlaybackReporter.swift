//
//  PlaybackReporter.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 10.10.23.
//

import Foundation

class PlaybackReporter {
    let itemId: String
    let episodeId: String?
    let playbackSessionId: String?
    
    var duration: Double
    var currentTime: Double
    var lastReportedTime: Double
    
    init(itemId: String, episodeId: String?, playbackSessionId: String?) {
        self.itemId = itemId
        self.episodeId = episodeId
        self.playbackSessionId = playbackSessionId
        
        duration = .nan
        currentTime = .nan
        lastReportedTime = Date.timeIntervalSinceReferenceDate
    }
    
    deinit {
        Self.reportPlaybackStop(playbackSessionId: playbackSessionId, itemId: itemId, episodeId: episodeId, currentTime: currentTime, duration: duration, timeListened: getTimeListened())
    }
}

// MARK: Public

extension PlaybackReporter {
    func reportProgress(currentTime: Double, duration: Double) {
        updateTime(currentTime: currentTime, duration: duration)
        
        // report every 30 seconds
        if Int(currentTime) % 30 == 0 {
            reportProgress()
        }
    }
    func reportProgress(playing: Bool, currentTime: Double, duration: Double) {
        updateTime(currentTime: currentTime, duration: duration)
        
        if playing {
            let _ = getTimeListened()
        } else {
            reportProgress()
        }
    }
}

// MARK: Report

extension PlaybackReporter {
    private func reportProgress() {
        if currentTime.isNaN || duration.isNaN {
            return
        }
        
        let timeListened = getTimeListened()
     
        Task.detached { [self] in
            var success = true
            
            do {
                if let playbackSessionId = playbackSessionId {
                    try await AudiobookshelfClient.shared.reportPlaybackUpdate(playbackSessionId: playbackSessionId, currentTime: currentTime, duration: duration, timeListened: timeListened)
                } else {
                    try await Self.reportWithoutPlaybackSession(itemId: itemId, episodeId: episodeId, currentTime: currentTime, duration: duration)
                }
            } catch {
                self.lastReportedTime -= timeListened
                success = false
            }
            
            await Self.updateOfflineProgress(itemId: itemId, episodeId: episodeId, currentTime: currentTime, duration: duration, success: success)
        }
    }
    
    private func getTimeListened() -> Double {
        let timeListened = Date.timeIntervalSinceReferenceDate - lastReportedTime
        lastReportedTime = Date.timeIntervalSinceReferenceDate
        
        if !timeListened.isFinite {
            return 0
        }
        
        return timeListened
    }
    private func updateTime(currentTime: Double, duration: Double) {
        if duration.isFinite && duration != 0 {
            self.duration = duration
        }
        if currentTime.isFinite && currentTime != 0 {
            self.currentTime = currentTime
        }
    }
}

// MARK: Close

extension PlaybackReporter {
    private static func reportPlaybackStop(playbackSessionId: String?, itemId: String, episodeId: String?, currentTime: Double, duration: Double, timeListened: Double) {
        if currentTime.isNaN || duration.isNaN {
            return
        }
        
        Task.detached {
            var success = true
            
            do {
                if let playbackSessionId = playbackSessionId {
                    try await AudiobookshelfClient.shared.reportPlaybackClose(playbackSessionId: playbackSessionId, currentTime: currentTime, duration: duration, timeListened: timeListened)
                } else {
                    try await Self.reportWithoutPlaybackSession(itemId: itemId, episodeId: episodeId, currentTime: currentTime, duration: duration)
                }
            } catch {
                success = false
            }
            
            await updateOfflineProgress(itemId: itemId, episodeId: episodeId, currentTime: currentTime, duration: duration, success: success)
        }
        
        if UserDefaults.standard.bool(forKey: "deleteFinishedDownloads") && currentTime >= duration {
            Task.detached {
                if let episodeId = episodeId {
                    try? await OfflineManager.shared.deleteEpisode(episodeId: episodeId)
                } else {
                    try? await OfflineManager.shared.deleteAudiobook(audiobookId: itemId)
                }
            }
        }
    }
    
    @MainActor
    private static func updateOfflineProgress(itemId: String, episodeId: String?, currentTime: Double, duration: Double, success: Bool) {
        let progress = OfflineManager.shared.getOrCreateProgress(itemId: itemId, episodeId: episodeId)
        progress.currentTime = currentTime
        progress.duration = duration
        progress.progress = currentTime / duration
        progress.lastUpdate = Date()
        progress.progressType = success ? .localSynced : .localCached
    }
    private static func reportWithoutPlaybackSession(itemId: String, episodeId: String?, currentTime: Double, duration: Double) async throws {
        try await AudiobookshelfClient.shared.updateMediaProgress(itemId: itemId, episodeId: episodeId, currentTime: currentTime, duration: duration)
    }
    
    enum ReportError: Error {
        case playbackSessionIdMissing
    }
}

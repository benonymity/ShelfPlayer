//
//  PodcastView.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 08.10.23.
//

import SwiftUI
import AudiobooksKit

struct PodcastView: View {
    var podcast: Podcast
    
    @State var navigationBarVisible: Bool
    @State var failed: Bool
    
    @State var filter: EpisodeFilterSortMenu.Filter
    @State var episodes: [Episode]?
    
    @State var backgroundColor: UIColor = .secondarySystemBackground
    
    init(podcast: Podcast) {
        self.podcast = podcast
        
        navigationBarVisible = false
        failed = false
        
        filter = EpisodeFilterSortMenu.getFilter(podcastId: podcast.id)
        
    }
    
    var body: some View {
        List {
            Header(podcast: podcast, navigationBarVisible: $navigationBarVisible, backgroundColor: $backgroundColor)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            if failed {
                ErrorView()
                    .listRowSeparator(.hidden)
            } else if let episodes = episodes {
                HStack {
                    EpisodeFilterSortMenu(podcastId: podcast.id, filter: $filter)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    NavigationLink(destination: AllEpisodesView(episodes: episodes, podcastId: podcast.id)) {
                        HStack {
                            Spacer()
                            Text("episodes.all")
                        }
                    }
                }
                .padding(.horizontal, 15)
                .frame(height: 45)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                
                EpisodesList(episodes: Array(EpisodeFilterSortMenu.filterAndSortEpisodes(episodes, filter: filter, podcastId: podcast.id).prefix(15)))
            } else {
                HStack {
                    Spacer()
                    LoadingView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .padding(.top, 50)
            }
        }
        .listStyle(.plain)
        .ignoresSafeArea(edges: .top)
        .modifier(ToolbarModifier(podcast: podcast, navigationBarVisible: $navigationBarVisible, backgroundColor: $backgroundColor))
        .modifier(NowPlayingBarSafeAreaModifier())
        .task(fetchEpisodes)
        .refreshable(action: fetchEpisodes)
    }
}

// MARK: Helper

extension PodcastView {
    @Sendable
    func fetchEpisodes() {
        failed = false
        
        Task.detached {
            if let episodes = try? await AudiobookshelfClient.shared.getPodcastEpisodes(podcastId: podcast.id) {
                self.episodes = episodes
                podcast.episodeCount = episodes.count
            } else {
                failed = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        PodcastView(podcast: Podcast.fixture)
    }
}

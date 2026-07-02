import SwiftUI

/// Hub-backed search results shown inside Explore when the query is active.
struct ExploreSearchResultsView: View {
    @EnvironmentObject private var app: AppState

    let query: String
    let results: ExploreSearchResults
    let loading: Bool
    let onSelectProfile: (String) -> Void
    let onSelectTribe: (Channel) -> Void

    var body: some View {
        Group {
            if loading, results.isEmpty {
                searchLoadingState
            } else if results.isEmpty {
                EmptyStateView(
                    symbol: "magnifyingglass",
                    title: "No results",
                    message: "Nothing in this channel matched \"\(query)\"."
                )
            } else {
                List {
                    if !results.users.isEmpty {
                        Section("People") {
                            ForEach(results.users) { user in
                                Button { onSelectProfile(user.tid) } label: {
                                    ExploreSearchUserRow(user: user)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if !results.channels.isEmpty {
                        Section("Channels") {
                            ForEach(results.channels) { channel in
                                Button { onSelectTribe(channel) } label: {
                                    ExploreSearchChannelRow(channel: channel)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if !results.events.isEmpty {
                        Section("Events") {
                            ForEach(results.events) { event in
                                ExplorePreviewLink(route: .event(event)) {
                                    ExploreEventPreview(event: event)
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                    }

                    if !results.polls.isEmpty {
                        Section("Polls") {
                            ForEach(results.polls) { poll in
                                ExplorePreviewLink(route: .poll(poll)) {
                                    ExplorePollPreview(poll: poll)
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                    }

                    if !results.tasks.isEmpty {
                        Section("Tasks") {
                            ForEach(results.tasks) { task in
                                ExplorePreviewLink(route: .task(task)) {
                                    ExploreTaskPreview(task: task)
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                    }

                    if !results.crowdfunds.isEmpty {
                        Section("Crowdfunds") {
                            ForEach(results.crowdfunds) { fund in
                                ExplorePreviewLink(route: .crowdfund(fund)) {
                                    ExploreCrowdfundPreview(crowdfund: fund)
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                    }

                    if !results.tweets.isEmpty {
                        Section("Posts") {
                            ForEach(results.tweets) { tweet in
                                TweetCardView(tweet: tweet)
                                    .environmentObject(app)
                                    .environmentObject(app.interactions)
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color(.systemBackground))
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
            }
        }
    }

    private var searchLoadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Searching \(app.activeChannel?.displayName ?? "channel")…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ExploreSearchUserRow: View {
    let user: User

    private var handle: String {
        if let u = user.username { return "@\(u).tribe" }
        return "@tid\(user.tid)"
    }

    var body: some View {
        HStack(spacing: 12) {
            UserAvatarView(
                tid: user.tid,
                initial: user.initial,
                size: 44,
                seed: user.username ?? user.tid
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(handle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}

private struct ExploreSearchChannelRow: View {
    @EnvironmentObject private var app: AppState
    let channel: Channel

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Theme.accentTeal.opacity(0.15))
                Image(systemName: channel.isCity ? "building.2.fill" : "number")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.accentTeal)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(channel.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text("#\(channel.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if app.isJoined(channelId: channel.id) {
                Text("Joined")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.brand)
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}

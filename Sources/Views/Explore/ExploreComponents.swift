import SwiftUI

// MARK: - Preview cards

struct ExploreEventPreview: View {
    let event: Event

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d · h:mm a"
        return formatter.string(from: event.startsAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            Text(dateLabel)
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.accentEmerald)
            HStack(spacing: 8) {
                if let loc = event.locationText, !loc.isEmpty {
                    exploreChip(loc, symbol: "mappin.and.ellipse", tint: Theme.accentTeal)
                }
                if event.yesCount > 0 {
                    exploreChip("\(event.yesCount) going", symbol: "person.2.fill", tint: Theme.accentEmerald)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tribeCard(cornerRadius: 16, padding: 14)
    }
}

struct ExplorePollPreview: View {
    let poll: Poll

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(poll.question)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            HStack(spacing: 8) {
                exploreChip("\(poll.options.count) options", symbol: "list.bullet", tint: Theme.accentIndigo)
                if let total = poll.totalVotes, total > 0 {
                    exploreChip("\(total) votes", symbol: "person.2.fill", tint: Theme.accentTeal)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tribeCard(cornerRadius: 16, padding: 14)
    }
}

struct ExploreTaskPreview: View {
    let task: TaskItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(task.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            if let description = task.description, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            exploreChip(task.status.capitalized, symbol: "circle.fill", tint: Theme.warning)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tribeCard(cornerRadius: 16, padding: 14)
    }
}

struct ExploreCrowdfundPreview: View {
    let crowdfund: Crowdfund

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(crowdfund.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            ProgressView(value: crowdfund.progress)
                .tint(Theme.accentAmber)
            Text("\(Int(crowdfund.progress * 100))% funded")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.accentAmber)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tribeCard(cornerRadius: 16, padding: 14)
    }
}

struct ExploreMemberCard: View {
    @EnvironmentObject private var app: AppState
    let member: ChannelMember
    var onTap: (() -> Void)?

    private var handle: String {
        if let u = member.username { return "@\(u).tribe" }
        return "@tid\(member.tid)"
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            cardContent
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            UserAvatarView(
                tid: member.tid,
                initial: member.initial,
                size: 56,
                seed: member.username ?? member.tid
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(member.displayName)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                Text(handle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
        }
        .frame(width: 188, height: 140, alignment: .topLeading)
        .tribeCard(cornerRadius: 16, padding: 14)
    }
}

struct ExploreMembersList: View {
    @EnvironmentObject private var app: AppState
    let members: [ChannelMember]

    var body: some View {
        List {
            ForEach(members) { member in
                NavigationLink {
                    UserProfileView(tid: member.tid)
                        .environmentObject(app)
                } label: {
                    ExploreMemberRow(member: member)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemBackground))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Members")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ExploreMemberRow: View {
    let member: ChannelMember

    private var handle: String {
        if let u = member.username { return "@\(u).tribe" }
        return "@tid\(member.tid)"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            UserAvatarView(
                tid: member.tid,
                initial: member.initial,
                size: 48,
                seed: member.username ?? member.tid
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(member.displayName)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                Text(handle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let joinedAt = member.joinedAt {
                    Text("Joined \(RelativeTime.short(joinedAt))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer(minLength: 8)
            FollowButton(targetTID: member.tid)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.cardStroke.opacity(0.4))
                .frame(height: 0.5)
        }
    }
}

struct ExplorePersonCard: View {
    let user: User

    private var handle: String {
        if let u = user.username { return "@\(u).tribe" }
        return "@tid\(user.tid)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            UserAvatarView(
                tid: user.tid,
                initial: user.initial,
                size: 56,
                seed: user.username ?? user.tid
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                Text(handle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            if let bio = user.profile?.bio, !bio.isEmpty {
                Text(bio)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 4)
            Text("\(user.followersCount) followers")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.tertiary)
                .monospacedDigit()
        }
        .frame(width: 188, height: 190, alignment: .topLeading)
        .tribeCard(cornerRadius: 16, padding: 14)
    }
}

struct ExploreTribeRow: View {
    let channel: Channel
    let joined: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Theme.accentTeal.opacity(0.15))
                Image(systemName: "number")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.accentTeal)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(channel.displayName)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                Text("#\(channel.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if joined {
                Text("Joined")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.brand)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Theme.brand.opacity(0.12)))
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .tribeCard(cornerRadius: 16, padding: 14)
    }
}

private func exploreChip(_ text: String, symbol: String, tint: Color) -> some View {
    HStack(spacing: 4) {
        Image(systemName: symbol)
            .font(.caption2.weight(.semibold))
        Text(text)
            .font(.caption2.weight(.medium))
            .lineLimit(1)
    }
    .foregroundStyle(tint)
    .padding(.horizontal, 8)
    .padding(.vertical, 3)
    .background(Capsule().fill(tint.opacity(0.12)))
}

// MARK: - See-all lists

struct ExploreEventsList: View {
    @EnvironmentObject private var app: AppState
    let events: [Event]

    var body: some View {
        List {
            ForEach(events) { event in
                EventCardView(event: event)
                    .environmentObject(app)
                    .feedListRow()
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Events")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExplorePollsList: View {
    @EnvironmentObject private var app: AppState
    let polls: [Poll]

    var body: some View {
        List {
            ForEach(polls) { poll in
                PollCardView(poll: poll)
                    .environmentObject(app)
                    .feedListRow()
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Polls")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExploreTasksList: View {
    @EnvironmentObject private var app: AppState
    let tasks: [TaskItem]

    var body: some View {
        List {
            ForEach(tasks) { task in
                TaskCardView(task: task)
                    .environmentObject(app)
                    .feedListRow()
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExploreCrowdfundsList: View {
    let crowdfunds: [Crowdfund]

    var body: some View {
        List {
            ForEach(crowdfunds) { fund in
                CrowdfundCardView(crowdfund: fund)
                    .feedListRow()
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Crowdfunds")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExplorePeopleList: View {
    let users: [User]

    var body: some View {
        List {
            ForEach(users) { user in
                ExplorePeopleRow(user: user)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.systemBackground))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("People")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ExplorePeopleRow: View {
    let user: User

    private var handle: String {
        if let u = user.username { return "@\(u).tribe" }
        return "@tid\(user.tid)"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            UserAvatarView(
                tid: user.tid,
                initial: user.initial,
                size: 48,
                seed: user.username ?? user.tid
            )
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(user.displayName)
                            .font(.subheadline.weight(.bold))
                            .lineLimit(1)
                        Text(handle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 8)
                    FollowButton(targetTID: user.tid)
                }
                if let bio = user.profile?.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.subheadline)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.cardStroke.opacity(0.4))
                .frame(height: 0.5)
        }
    }
}

struct ExploreTribesList: View {
    @EnvironmentObject private var app: AppState
    let tribes: [Channel]
    let onSelect: (Channel) -> Void

    var body: some View {
        List {
            ForEach(tribes) { tribe in
                Button { onSelect(tribe) } label: {
                    ExploreTribeRow(channel: tribe, joined: app.isJoined(channelId: tribe.id))
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Tribes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension View {
    func feedListRow() -> some View {
        listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color(.systemBackground))
    }
}

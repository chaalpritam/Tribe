import SwiftUI

/// Navigation target for an Explore preview row (event, poll, task, or crowdfund).
enum ExploreItemRoute: Hashable, Identifiable {
    case event(Event)
    case poll(Poll)
    case task(TaskItem)
    case crowdfund(Crowdfund)

    var id: String {
        switch self {
        case .event(let event): return "event-\(event.id)"
        case .poll(let poll): return "poll-\(poll.id)"
        case .task(let task): return "task-\(task.id)"
        case .crowdfund(let fund): return "crowdfund-\(fund.id)"
        }
    }
}

/// Full interactive card for a single Explore item.
struct ExploreItemDetailView: View {
    @EnvironmentObject private var app: AppState

    let route: ExploreItemRoute

    private var title: String {
        switch route {
        case .event(let event): return event.title
        case .poll(let poll): return poll.question
        case .task(let task): return task.title
        case .crowdfund(let fund): return fund.title
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                switch route {
                case .event(let event):
                    EventCardView(event: event)
                        .environmentObject(app)
                case .poll(let poll):
                    PollCardView(poll: poll)
                        .environmentObject(app)
                case .task(let task):
                    TaskCardView(task: task)
                        .environmentObject(app)
                case .crowdfund(let crowdfund):
                    CrowdfundCardView(crowdfund: crowdfund)
                }
            }
            .padding(.vertical, 12)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

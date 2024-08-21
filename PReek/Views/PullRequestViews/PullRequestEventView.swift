import MarkdownUI
import SwiftUI

func eventDataToActionLabel(data: any EventData) -> String {
    let reviewLabels = [
        EventReviewData.State.approve: String(localized: "approved"),
        EventReviewData.State.changesRequested: String(localized: "requested changes"),
        EventReviewData.State.comment: String(localized: "commented"),
        EventReviewData.State.dismissed: String(localized: "reviewed (dismissed)"),
    ]

    switch data {
    case is EventClosedData:
        return String(localized: "closed")
    case let pushedData as EventPushedData:
        return pushedData.isForcePush ? String(localized: "force pushed") : String(localized: "pushed")
    case is EventMergedData:
        return String(localized: "merged")
    case let reviewData as EventReviewData:
        return reviewLabels[reviewData.state] ?? String(localized: "reviewed")
    case is EventCommentData:
        return String(localized: "commented")
    case is ReadyForReviewData:
        return String(localized: "marked ready")
    case is EventRenamedTitleData:
        return String(localized: "renamed")
    case is EventReopenedData:
        return String(localized: "reopened")
    case is EventReviewRequestedData:
        return String(localized: "requested review")
    case is EventConvertToDraftData:
        return String(localized: "converted to draft")
    default:
        return String(localized: "unknown")
    }
}

struct PullRequestEventView: View {
    var pullRequestEvent: Event

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(pullRequestEvent.user.displayName).frame(width: 200, alignment: .leading)
                Spacer()
                Text(eventDataToActionLabel(data: pullRequestEvent.data)).frame(width: 150, alignment: .trailing)
                Spacer()
                Text(pullRequestEvent.time.formatted(date: .numeric, time: .shortened))
                    .foregroundStyle(.secondary)
                ModifierLink(destination: pullRequestEvent.url) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            PullRequestEventDataView(data: pullRequestEvent.data)
                .padding(.leading, 30)
                .padding(.top, 2)
        }
        .padding(.trailing)
    }
}

#Preview {
    let pullRequestEvents: [Event] = [
        Event.previewClosed,
        Event.previewCommit(),
        Event.previewCommit(commits: [
            Commit(id: "1", messageHeadline: "my first commit!", url: URL(string: "https://example.com")!),
        ]),
        Event.previewCommit(commits: [
            Commit(id: "1", messageHeadline: "my first commit!", url: URL(string: "https://example.com")!),
            Commit(id: "2", messageHeadline: "my second commit!", url: URL(string: "https://example.com")!),
            Commit(id: "3", messageHeadline: "my third commit!", url: URL(string: "https://example.com")!),
        ]),
        Event.previewMerged,
        Event.previewReview(),
        Event.previewComment,
        Event.previewReopened,
        Event.previewForcePushed,
        Event.previewRenamedTitle,
        Event.previewReviewRequested,
        Event.previewReadyForReview,
        Event.previewConvertToDraft,
    ]

    return ScrollView {
        VStack {
            DividedView {
                ForEach(pullRequestEvents) { pullRequestEvent in
                    PullRequestEventView(pullRequestEvent: pullRequestEvent)
                }
            }
        }
        .padding()
    }
}

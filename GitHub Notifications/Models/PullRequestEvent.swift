//
//  PullRequestEvent.swift
//  GitHub Notifications
//
//  Created by Max Heidinger on 24.05.24.
//

import Foundation

protocol PullRequestEventData {}

struct PullRequestEvent: Identifiable {
    var id: String
    var user: User
    var time: Date
    
    var data: PullRequestEventData
    
    static let previewClosed = PullRequestEvent(id: UUID().uuidString, user: User.preview(login: "person-1"), time: Date(), data: PullRequestEventClosedData())
    static let previewForcePushed = PullRequestEvent(id: UUID().uuidString, user: User.preview(login: "person-with-long-name-2"), time: Date(), data: PullRequestEventForcePushedData())
    static let previewMerged = PullRequestEvent(id: UUID().uuidString, user: User.preview(login: "per3"), time: Date(), data: PullRequestEventMergedData())
    static let previewCommit = PullRequestEvent(id: UUID().uuidString, user: User.preview(login: "person-4"), time: Date(), data: PullRequestEventCommitData(commitCount: 3))
    static func previewReview(comments: [PullRequestReviewComment]? = nil) -> PullRequestEvent {
        PullRequestEvent(
            id: UUID().uuidString,
            user: User.preview(login: "person-5"),
            time: Date(),
            data: PullRequestEventReviewData(
                state: .changesRequested,
                comments: comments ?? [
                    PullRequestReviewComment(id: UUID().uuidString, comment: "Some important comment that also is not too short as we'll get long comments and it won't stop and go on and on and on", fileReference: nil, isReply: false),
                    PullRequestReviewComment(id: UUID().uuidString, comment: "Some important comment that also is not too short as we'll get long comments", fileReference: "MyComponent.tsx#L123", isReply: true)
                ]
            )
        )
    }
    static let previewComment = PullRequestEvent(id: UUID().uuidString, user: User.preview(login: "person-6"), time: Date(), data: PullRequestEventCommentData(comment: "Hello World, this is some really long comment which basically has no content but it has to be long"))
    static let previewReadyForReview = PullRequestEvent(id: UUID().uuidString, user: User.preview(login: "person-7"), time: Date(), data: PullRequestEventReadyForReviewData())
    static let previewRenamedTitle = PullRequestEvent(id: UUID().uuidString, user: User.preview(login: "person-8"), time: Date(), data: PullRequestEventRenamedTitleData(currentTitle: "current title", previousTitle: "previous title"))
    static let previewReopened = PullRequestEvent(id: UUID().uuidString, user: User.preview(login: "person-9"), time: Date(), data: PullRequestEventReopenedData())
    static let previewReviewRequested = PullRequestEvent(id: UUID().uuidString, user: User.preview(login: "person-10"), time: Date(), data: PullRequestEventReviewRequestedData(requestedReviewer: "me"))
}

struct PullRequestEventClosedData: PullRequestEventData {}

struct PullRequestEventForcePushedData: PullRequestEventData {
    var commitCount: Int? = nil
}

struct PullRequestEventMergedData: PullRequestEventData {}

struct PullRequestEventCommitData: PullRequestEventData {
    var commitCount: Int
}

struct PullRequestReviewComment: Identifiable {
    var id: String
    var comment: String
    var fileReference: String?
    var isReply: Bool
}

struct PullRequestEventReviewData: PullRequestEventData {
    enum State {
        case comment
        case approve
        case changesRequested
        case dismissed
    }
    
    var state: State
    var comments: [PullRequestReviewComment]
}

struct PullRequestEventCommentData: PullRequestEventData {
    var comment: String
}

struct PullRequestEventReadyForReviewData: PullRequestEventData {}

struct PullRequestEventRenamedTitleData: PullRequestEventData {
    var currentTitle: String
    var previousTitle: String
}

struct PullRequestEventReopenedData: PullRequestEventData {}

struct PullRequestEventReviewRequestedData: PullRequestEventData {
    var requestedReviewer: String?
}

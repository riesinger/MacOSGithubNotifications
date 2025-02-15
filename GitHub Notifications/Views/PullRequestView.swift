//
//  PullRequestView.swift
//  GitHub Notifications
//
//  Created by Max Heidinger on 23.05.24.
//

import SwiftUI

private let statusToIcon = [
    PullRequest.Status.draft: "PRDraft",
    PullRequest.Status.open: "PROpen",
    PullRequest.Status.merged: "PRMerged",
    PullRequest.Status.closed: "PRClosed"
]

struct PullRequestHeaderView: View {
    var pullRequest: PullRequest
    var isRead: Bool
    var toggleRead: () -> Void
    
    @Binding var sectionExpanded: Bool
    
    var modifierLinkAction: ModifierLink.AdditionalActionProcessor?
    
    var body: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: isRead ? "circle" : "circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                    .onTapGesture(perform: toggleRead)
                    .padding(.trailing, 10)
                Image(statusToIcon[pullRequest.status] ?? "PROpen")
                    .foregroundStyle(.primary)
                    .imageScale(.large)
            }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        ModifierLink(destination: pullRequest.repository.url, additionalAction: modifierLinkAction) {
                            Text(pullRequest.repository.name)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                        }
                        ModifierLink(destination: pullRequest.url, additionalAction: modifierLinkAction) {
                            Text(pullRequest.numberFormatted)
                                .foregroundStyle(.secondary)
                                .monospaced()
                        }
                    }
                    ModifierLink(destination: pullRequest.url, additionalAction: modifierLinkAction) {
                        Text(pullRequest.title)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                            .frame(width: 250, alignment: .leading)
                            .lineLimit(2)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    if let authorUrl = pullRequest.author.url {
                        ModifierLink(destination: authorUrl, additionalAction: modifierLinkAction) {
                            Text("by \(pullRequest.author.login)")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("by \(pullRequest.author.login)")
                            .foregroundStyle(.secondary)
                    }
                    Text("last update \(pullRequest.lastUpdated.formatted(date: .numeric, time: .shortened))")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: sectionExpanded ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                .imageScale(.large)
                .onTapGesture {
                    sectionExpanded.toggle()
                }
                .onHover { inside in
                    if inside {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PullRequestContentView: View {
    @State var eventLimit = 0;
    
    var pullRequest: PullRequest
    
    init(pullRequest: PullRequest) {
        self.eventLimit =  min(pullRequest.events.count, 5)
        self.pullRequest = pullRequest
    }
    
    func loadMore() {
        self.eventLimit = min(pullRequest.events.count, eventLimit + 5)
    }
    
    @ViewBuilder var noEventsBody: some View {
        Text("No Events")
            .foregroundStyle(.secondary)
    }
    
    @ViewBuilder var eventsBody: some View {
        VStack {
            DividedView {
                ForEach(pullRequest.events[0..<eventLimit]) { event in
                    PullRequestEventView(pullRequestEvent: event)
                }
                if (self.eventLimit < pullRequest.events.count) {
                    Button(action: loadMore) {
                        Label("Load More", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
        .padding(.leading, 30)
    }
    
    var body: some View {
        if pullRequest.events.isEmpty {
            noEventsBody
        }
        eventsBody
    }
}

struct PullRequestView: View {
    var pullRequest: PullRequest
    var modifierLinkAction: ModifierLink.AdditionalActionProcessor?
    
    @AppStorage("pullRequestReadMap") var pullRequestReadMap: [String: Date] = [:]
    @State var sectionExpanded: Bool = false

    var isRead: Bool {
        guard let markedRead = pullRequestReadMap[pullRequest.id] else {
            return false
        }
        return markedRead > pullRequest.lastUpdated
    }
    
    func toggleRead() {
        if isRead {
            pullRequestReadMap.removeValue(forKey: pullRequest.id)
        } else {
            pullRequestReadMap[pullRequest.id] = Date()
        }
    }
    
    var body: some View {
        VStack {
            Section(
                isExpanded: $sectionExpanded,
                content: {
                    PullRequestContentView(pullRequest: pullRequest)
                        .padding(.top, 5)
                },
                header: {
                    PullRequestHeaderView(
                        pullRequest: pullRequest,
                        isRead: isRead,
                        toggleRead: toggleRead,
                        sectionExpanded: $sectionExpanded,
                        modifierLinkAction: modifierLinkAction
                    )
                    .frame(maxWidth: .infinity)
                }
            )
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    PullRequestView(
        pullRequest: PullRequest.preview(),
        sectionExpanded: true
    )
    .padding()
}

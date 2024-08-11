import Foundation

class PullRequestsViewModel: ObservableObject {
    @Published var lastUpdated: Date? = nil
    @Published var isRefreshing = false
    @Published var hasError = false
    
    @Published private var pullRequestMap: [String: PullRequest] = [:]
    var pullRequests: [PullRequest] {
        return pullRequestMap.map { entry in
            return entry.value
        }.filter { pullRequest in
            return pullRequest.events.allSatisfy { event in
                return !ConfigService.excludedUsers.contains(event.user.login)
            }
        }.sorted {
            $0.lastUpdated > $1.lastUpdated
        }
    }
    
    private var timer: Timer?
    
    func triggerFetchPullRequests() {
        Task {
            await fetchPullRequests()
        }
    }
        
    func startFetchTimer() {
        if timer != nil {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.triggerFetchPullRequests()
        }
    }
    
    private func handleReceivedNotifications(notifications: [Notification]) async throws {
        print("Got \(notifications.count) notifications")
        
        let repoMap = notifications.reduce([String: [Int]]()) { repoMap, notification in
            var repoMapClone = repoMap
            
            let existingPRs = repoMap[notification.repo]
            repoMapClone[notification.repo] = (existingPRs ?? []) + [notification.prNumber]
            
            return repoMapClone
        }
        
        if !repoMap.isEmpty {
            let pullRequests = try await GitHubService.fetchPullRequests(repoMap: repoMap)
            print("Got \(pullRequests.count) pull requests")
            
            DispatchQueue.main.async {
                pullRequests.forEach { pullRequest in
                    self.pullRequestMap[pullRequest.id] = pullRequest
                }
            }
        } else {
            print("No new PRs to fetch")
        }
    }
    
    private func fetchPullRequests() async {
        do {
            print("Fetch notifications")
            
            DispatchQueue.main.async {
                self.isRefreshing = true
                self.hasError = false
            }
            
            let since = lastUpdated ?? Calendar.current.date(byAdding: .day, value: ConfigService.onStartFetchWeeks * 7 * -1, to: Date())!
            try await GitHubService.fetchUserNotifications(since: since, onNotificationsReceived: handleReceivedNotifications)
            
            cleanupPullRequests()
            
            DispatchQueue.main.async {
                self.lastUpdated = Date()
                self.isRefreshing = false
            }
            print("Finished fetching notifications")
        } catch {
            print("Failed to get pull requests: \(error)")
            DispatchQueue.main.async {
                self.hasError = true
            }
        }
    }
    
    private func cleanupPullRequests() {
        let deleteFrom = Calendar.current.date(byAdding: .day, value: ConfigService.deleteAfterWeeks * 7 * -1, to: Date())!

        let filteredPullRequestMap = pullRequestMap.filter { _, pullRequest in
            pullRequest.lastUpdated > deleteFrom || (ConfigService.deleteOnlyClosed && pullRequest.status != .merged && pullRequest.status != .merged)
        }
        
        if (filteredPullRequestMap.count != pullRequestMap.count) {
            print("Removed \(pullRequestMap.count - filteredPullRequestMap.count) pull requests")
            DispatchQueue.main.async {
                self.pullRequestMap = filteredPullRequestMap
            }
        }
    }
}

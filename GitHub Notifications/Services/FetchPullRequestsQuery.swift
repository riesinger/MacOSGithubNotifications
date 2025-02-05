//
//  FetchUserPullRequestsQuery.swift
//  GitHub Notifications
//
//  Created by Max Heidinger on 24.05.24.
//

import Foundation

struct FetchPullRequestsResponse: Decodable {
    var data: [String: [String: PullRequestDto]]
}

struct FetchPullRequestsQueryBuilder {
    static func fetchPullRequestQuery(repoMap: [String: [Int]]) -> String {
        var repoCount = 0
        let queryContent = repoMap.reduce("") { query, repo in
            let repoQuery = repo.value.reduce("") { repoQuery, prNumber in
                return repoQuery + """
                    pr\(prNumber): pullRequest(number: \(prNumber)) {
                      ...PullRequestFragment
                    }
                    
                    """
            }
            
            repoCount += 1
            let repoSplit = repo.key.split(separator: "/")
            return query + """
                repo\(repoCount): repository(owner:"\(repoSplit.first!)", name:"\(repoSplit.last!)") {
                    \(repoQuery)
                }
                
                """
        }
        
        return """
            \(pullRequestFragment)
            
            query pullRequests {
                \(queryContent)
            }
            """
    }
    
    private static let pullRequestFragment = """
        fragment PullRequestReviewFragment on PullRequestReview {
          author {
            login
            url
          }
          bodyText
          state
          createdAt
          comments(last: 30) {
            nodes {
              id
              author {
                login
                url
              }
              bodyText
              createdAt
              diffHunk
              outdated
              path
              replyTo {
                id
              }
            }
          }
        }

        fragment PullRequestFragment on PullRequest {
          id
          state
          title
          number
          updatedAt
          author {
            login
            url
          }
          repository {
            nameWithOwner
            url
          }
          isDraft
          url
          timelineItems(last: 30) {
            nodes {
              type: __typename
              ... on Node {
                id
              }
              ... on ClosedEvent {
                actor {
                  login
                  url
                }
                createdAt
              }
              ... on HeadRefForcePushedEvent {
                actor {
                  login
                  url
                }
                createdAt
              }
              ... on IssueComment {
                author {
                  login
                  url
                }
                bodyText
                createdAt
              }
              ... on MergedEvent {
                actor {
                  login
                  url
                }
                createdAt
              }
              ... on PullRequestCommit {
                commit {
                  author {
                    user {
                      login
                      url
                    }
                  }
                  committedDate
                }
              }
              ... on PullRequestReview {
                ...PullRequestReviewFragment
              }
              ... on ReadyForReviewEvent {
                actor {
                  login
                  url
                }
                createdAt
              }
              ... on RenamedTitleEvent {
                actor {
                  login
                  url
                }
                createdAt
                currentTitle
                previousTitle
              }
              ... on ReopenedEvent {
                actor {
                  login
                  url
                }
                createdAt
              }
              ... on ReviewRequestedEvent {
                actor {
                  login
                  url
                }
                createdAt
                requestedReviewer {
                  ... on Actor {
                    login
                    url
                  }
                }
              }
            }
          }
        }
        """

}

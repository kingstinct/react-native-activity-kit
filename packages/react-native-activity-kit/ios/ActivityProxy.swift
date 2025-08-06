import ActivityKit
import Foundation
import NitroModules

@available(iOS 16.1, *)
class ActivityProxy : HybridActivityProxySpec {
    func subscribeToActivityStateUpdates(callback: @escaping (ActivityState) -> Void) throws {
        Task {
            for await activityState in activity.activityStateUpdates {
                callback(convertActivityState(activityState))
            }
        }
    }
    
    func subscribeToPushTokenUpdates(callback: @escaping (String) -> Void) throws {
        Task {
            for await pushToken in activity.pushTokenUpdates {
                if let tokenString = parsePushToken(pushToken) {
                    callback(tokenString)
                }
            }
        }
    }
    
    func subscribeToStateUpdates(callback: @escaping (ActivityStateUpdate) -> Void) throws {
        Task {
            if #available(iOS 16.2, *) {
                for await content in activity.contentUpdates {
                    callback(
                        ActivityStateUpdate(
                            state: try serializeContentState(contentState: content.state),
                            staleDate: content.staleDate,
                            relevanceScore: content.relevanceScore
                        ))
                }
            } else {
                for await contentState in activity.contentStateUpdates {
                    callback(ActivityStateUpdate(
                        state: try serializeContentState(contentState: contentState),
                        staleDate: nil,
                        relevanceScore: nil
                    ))
                }
            }
        }
    }
    
    // Swift
    var attributes: AnyMap {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(activity.attributes)
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return serializeAnyMap(jsonObject)
            }
        } catch {
            // Handle error if needed
        }
        return AnyMap()
    }
    
    var state: AnyMap {
        do {
            let encoder = JSONEncoder()
            var data: GenericDictionaryStruct
            if #available(iOS 16.2, *) {
                data = activity.content.state
            } else {
                data = activity.contentState
            }
            
            let encodedData = try encoder.encode(data)
            if let jsonObject = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any] {
                return serializeAnyMap(jsonObject)
            }
        } catch {
            // Handle error if needed
        }
        return AnyMap()
    }
    
    var relevanceScore: Double? {
        if #available(iOS 16.2, *) {
            return activity.content.relevanceScore
        } else {
            return nil
        }
    }
    
    var staleDate: Date? {
        if #available(iOS 16.2, *) {
            return activity.content.staleDate
        } else {
            return nil
        }
    }
    
    var activityState: ActivityState {
        switch activity.activityState {
        case .active:
            return .active
        case .dismissed:
            return .dismissed
        case .ended:
            return .ended
        case .stale:
            return .stale
        default:
            return .none
        }
    }
    
    func update(state: AnyMap, options: UpdateOptions?) throws -> Void {
        Task {
            let contentState = try ActivityKitModuleAttributes.ContentState(data: anyMapToDictionary(state))
            
            var alertConfiguration: ActivityKit.AlertConfiguration? = nil
            if let config = options?.alertConfiguration {
                alertConfiguration = ActivityKit.AlertConfiguration(
                    title: LocalizedStringResource(stringLiteral: config.title),
                    body: LocalizedStringResource(stringLiteral: config.body),
                    sound: config.sound != nil
                        ? ActivityKit.AlertConfiguration.AlertSound.named(config.sound!)
                        : .default
                )
            }
            
            if #available(iOS 16.2, *) {
                let updatedState = ActivityContent.init(
                    state: contentState,
                    staleDate: options?.staleDate,
                    relevanceScore: options?.relevanceScore ?? 0
                )
                
                if #available(iOS 17.2, *) {
                    await activity.update(
                        updatedState,
                        alertConfiguration: alertConfiguration,
                        timestamp: options?.timestamp ?? Date.now
                    )
                } else {
                    await activity.update(
                        updatedState,
                        alertConfiguration: alertConfiguration
                    )
                }
            } else {
                await activity.update(
                    using: contentState,
                    alertConfiguration: alertConfiguration
                )
            }
        }
    }
    
    func end(state: AnyMap, options: EndOptions?) throws -> Void {
        Task {
            let newState = try ActivityKitModuleAttributes.ContentState(data: anyMapToDictionary(state))
            
            var dismissalPolicy: ActivityUIDismissalPolicy = .default
            if let policy = options?.dismissalPolicy {
                if(policy.timeIntervalSinceNow < 0) {
                    dismissalPolicy = .after(policy)
                } else {
                    dismissalPolicy = .immediate
                }
            }
            
            let timestamp = options?.timestamp ?? Date()
            
            if #available(iOS 16.2, *) {
                let endingState = ActivityContent.init(
                    state: newState,
                    staleDate: options?.staleDate,
                    relevanceScore: options?.relevanceScore ?? 0
                )
                
                if #available(iOS 17.2, *) {
                    await activity.end(
                        endingState,
                        dismissalPolicy: dismissalPolicy,
                        timestamp: timestamp
                    )
                } else {
                    await activity.end(
                        endingState,
                        dismissalPolicy: dismissalPolicy
                    )
                }
            } else {
                await activity.end(using: newState, dismissalPolicy: dismissalPolicy)
            }
        }
        
    }
    
    var id: String {
        return activity.id
    }
    
    var pushToken: String? {
        if let pushToken = activity.pushToken {
            return parsePushToken(pushToken)
        }
        return nil
    }
    
    var activity: Activity<ActivityKitModuleAttributes>
    
    init(activity: Activity<ActivityKitModuleAttributes>) {
        self.activity = activity
    }
}

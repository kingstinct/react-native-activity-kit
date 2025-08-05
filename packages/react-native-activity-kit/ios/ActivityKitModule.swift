import ActivityKit
import NitroModules

@available(iOS 16.1, *)
let activityAuthorizationInfo = ActivityKit.ActivityAuthorizationInfo()

class ActivityKitModule : HybridActivityKitModuleSpec {
    var pushToStartToken: String? {
        if #available(iOS 17.2, *) {
            if let token = Activity<ActivityKitModuleAttributes>.pushToStartToken {
                if let tokenString = parsePushToken(token) {
                    return tokenString
                }
            }
        } else {
            print("[react-native-activity-kit] pushToStartToken requires iOS 17.2 or later")
        }
        return nil
    }
    
    var isAvailable: Bool {
        if #available(iOS 16.1, *) {
            return true
        } else {
            return false
        }
    }
    
    func subscribeToActivityUpdates(callback: @escaping (any HybridActivityProxySpec) -> Void) throws {
        if #available(iOS 16.1, *) {
            Task {
                for await activity in Activity<ActivityKitModuleAttributes>.activityUpdates {
                    callback(ActivityProxy(activity: activity))
                }
            }
        }
    }
    
    var areActivitiesEnabled: Bool {
        if #available(iOS 16.1, *) {
            return activityAuthorizationInfo.areActivitiesEnabled
        } else {
            return false
        }
    }
    
    var frequentPushesEnabled: Bool {
        if #available(iOS 16.2, *) {
            return activityAuthorizationInfo.frequentPushesEnabled
        } else {
            
           print("[react-native-activity-kit] frequentPushesEnabled requires iOS 16.2 or later")
            return false
        }
    }
    
    func subscribeToFrequentPushesUpdates(callback: @escaping (Bool) -> Void) throws {
        Task {
            if #available(iOS 16.2, *) {
                for await isEnabled in activityAuthorizationInfo.frequentPushEnablementUpdates {
                    callback(isEnabled)
                }
            } else {
                print("[react-native-activity-kit] subscribeToActivityEnablementUpdates requires iOS 16.2 or later")
            }
        }
    }
    
    func subscribeToActivityEnablementUpdates(callback: @escaping (Bool) -> Void) throws {
        Task {
            if #available(iOS 16.1, *) {
                for await isEnabled in activityAuthorizationInfo.activityEnablementUpdates {
                    callback(isEnabled)
                }
            } else {
                print("[react-native-activity-kit] subscribeToActivityEnablementUpdates requires iOS 16.1 or later")
            }
        }
    }
    
    func subscribeToPushToStartTokenUpdates(callback: @escaping (String) -> Void) throws {
        Task {
            if #available(iOS 17.2, *) {
                for await token in Activity<ActivityKitModuleAttributes>.pushToStartTokenUpdates {
                    if let tokenString = String(data: token, encoding: .utf8) {
                        callback(tokenString)
                    }
                }
            } else {
                print("[react-native-activity-kit] subscribeToPushToStartTokenUpdates requires iOS 17.2 or later")
            }
        }
    }
    
    
    func startActivity(attributes: AnyMap, state: AnyMap, options: StartActivityOptions?) throws -> HybridActivityProxySpec {
        
        if #available(iOS 16.1, *) {
            var pushType: PushType?
            
            switch options?.pushType {
            case .first(let useTokenConfig):
                if(useTokenConfig.token){
                    pushType = .token
                }
            case .second(let pushChannelConfig):
                if #available(iOS 18.0, *) {
                    pushType = .channel(pushChannelConfig.channelName)
                } else {
                    // Fallback on earlier versions
                }
            default:
                pushType = nil
            }
            
            let state = try ActivityKitModuleAttributes.ContentState(data: state)
            
            let attributes = try ActivityKitModuleAttributes(data: attributes)
            
            var activity: Activity<ActivityKitModuleAttributes>
            
            if #available(iOS 16.2, *) {
                let content = ActivityContent<ActivityKitModuleAttributes.ContentState>.init(
                    state: state,
                    staleDate: options?.staleDate,
                    relevanceScore: options?.relevanceScore ?? 0,
                )
                
                if #available(iOS 18.0, *) {
                    activity = try Activity.request(
                        attributes: attributes,
                        content: content,
                        pushType: pushType,
                        style: options?.style == .transient ? .transient : .standard
                    )
                } else {
                    activity = try Activity.request(
                        attributes: attributes,
                        content: content,
                        pushType: pushType
                    )
                }
            } else {
                activity = try Activity.request(attributes: attributes, contentState: state)
            }
            return ActivityProxy(activity: activity)
        } else {
            throw RuntimeError.error(withMessage: "ActivityKit is not available on this version of iOS. Please use iOS 16.1 or later.")
        }
    }
        
        func getActivityById(activityId: String) throws -> HybridActivityProxySpec? {
            if #available(iOS 16.1, *) {
                let activity = Activity<ActivityKitModuleAttributes>.activities.first(where: { $0.id == activityId })
                if let activity = activity {
                    return ActivityProxy(activity: activity)
                }
            } else {
                // Fallback on earlier versions
            }
            
            return nil
        }
        
        func getAllActivities() throws -> [HybridActivityProxySpec] {
            if #available(iOS 16.1, *) {
                let activityProxies = Activity.activities
                    .map {
                        ActivityProxy(activity: $0)
                    }
                return activityProxies
            } else {
                // Fallback on earlier versions
            }
            return []
        }
        
    
}

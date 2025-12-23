    //
    //  TravelReceiptApp.swift
    //  TravelReceipt
    //
    //  Created by YiJou on 2025/11/12.
    //

import SwiftUI
import SwiftData
import UserNotifications

@main
struct TravelReceiptApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Trip.self, Expense.self)
        } catch {
            print("❌ ModelContainer creation failed: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        requestNotificationPermission()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("通知權限已開啟")
            } else {
                print("通知權限被拒絕")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}

    // ✅ 新增 AppDelegate 處理前景通知
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
        // ✅ 這個方法讓 App 在前景時也能顯示通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

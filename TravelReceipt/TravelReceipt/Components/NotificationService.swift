//
//  NotificationService.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/12/23.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
        // 記帳成功通知
    func sendExpenseAddedNotification(amount: Decimal, category: String) {
        let content = UNMutableNotificationContent()
        content.title = "記錄成功 ✓"
        content.body = "已新增 NT$\(amount) \(category)費用"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
        // 每日記帳提醒
    func scheduleDailyReminder(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "出差收據通"
        content.body = "別忘了記錄今天的費用喔！"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "dailyReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
        // 取消提醒
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }
}

//
//  GressoAppApp.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 07.06.2023.
//

import SwiftUI
import AWSCore
import AdjustSdk
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseMessaging
import BackgroundTasks

let RFont = R.font
let RImage = R.image
let Localizable = R.string.localizable

@main
struct GressoAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast2, identityPoolId: "us-east-2:8b7fcad8-4407-4d04-a0bd-2e134d84e98d")
        let configuration = AWSServiceConfiguration(region: .USEast2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        DispatchQueue.main.async {
            let defaults = UserDefaults.standard
            let appLaunchCounter = defaults.integer(forKey: UserDefaultsKey.appLaunchCounter.rawValue)
            defaults.set(appLaunchCounter + 1, forKey: UserDefaultsKey.appLaunchCounter.rawValue)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    let backgroundTaskIdentifier = "com.gresso.GressoApp.downloadModels"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupAdjust()
        FirebaseApp.configure()
        registerRemoteNotifications(application: application)
        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token {
            print("FCM registration token: \(token)")
          }
        }
        
        // Регистрируем обработчик фоновой задачи
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            self.handleBackgroundTask(task: task as! BGProcessingTask)
        }

        // Планируем фоновую задачу при запуске приложения
        scheduleBackgroundTask()
        
        return true
    }
    
    private func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        request.requiresNetworkConnectivity = true // Задача требует интернета
        request.requiresExternalPower = false // Не требует подключения к зарядке

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("### Не удалось запланировать фоновую задачу: \(error)")
        }
    }
    
    private func handleBackgroundTask(task: BGProcessingTask) {
        AnalyticsService.shared.backgroundTaskLaunch()
        // Устанавливаем обработчик завершения задачи
        task.expirationHandler = {
            // Вызывается, если задача завершается из-за нехватки времени
            task.setTaskCompleted(success: false)
        }
        
        // Запускаем загрузку моделей
        let s3Service = S3ServiceHandler()
        s3Service.downloadAllModelsIfNeeded {
            // Уведомляем систему о завершении задачи
            task.setTaskCompleted(success: true)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
    
    private func setupAdjust() {
        let yourAppToken = "90iu8omef5z4"
        let environment = ADJEnvironmentSandbox
        let adjustConfig = ADJConfig(appToken: yourAppToken,
                                     environment: environment)
        Adjust.initSdk(adjustConfig)
    }
    
    private func registerRemoteNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()

    }
    
}

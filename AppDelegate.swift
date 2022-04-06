//
//  AppDelegate.swift
//  MinIODemo
//
//  Created by Bindi Manek on 04/04/22.
//

import UIKit
import AWSS3
import AWSCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        
//        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .APSouth1, identityPoolId: S3Configuration.IDENTITY_POOL_ID.rawValue)
//        let configuration = AWSServiceConfiguration(region: .EUWest1, credentialsProvider: credentialProvider)
//        AWSS3TransferUtility.registerS3TransferUtilityWithConfiguration(configuration, forKey: S3Configuration.CALLBACK_KEY.rawValue)
        
//        let builder: RSConfigBuilder = RSConfigBuilder()
//            .withDataPlaneUrl(DATA_PLANE_URL)
//        RSClient.getInstance("27MuD4bHPj6PjGENucseiZW81Ci", config: builder.build())
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}


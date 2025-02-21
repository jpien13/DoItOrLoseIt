//
//  PaymentManager.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 2/20/25.
//

//import Foundation
//import CoreData
//import SwiftUI
//
//final class PaymentManager: ObservableObject {
//    @Published var alertItem: AlertItem?
//    private let viewContext: NSManagedObjectContext
//    
//    init(viewContext: NSManagedObjectContext) {
//        self.viewContext = viewContext
//    }
//    
//    func authorizePayment(for task: PinTask) {
//        let fakeAuthToken = "fake-auth-token\(UUID().uuidString)"
//        task.paymentAuthorizationToken = fakeAuthToken
//        task.paymentAuthorizationDate = Date()
//        
//        do {
//            try viewContext.save()
//            print("🔧 DEV MODE: Payment of $\(task.challengeAmount) authorized for task \(task.title ?? "untitled")")
//            print("🔧 DEV MODE: Authorization token: \(fakeAuthToken)")
//        } catch {
//            alertItem = AlertItem(
//                title: Text("Error"),
//                message: Text("Failed to authorize payment"),
//                dismissButton: .default(Text("OK"))
//            )
//        }
//    }
//    
//    func processPayment(for task: PinTask) {
//        guard let authToken = task.paymentAuthorizationToken else {
//            print("No payment authorization found for this task")
//            return
//        }
//        
//        if task.taskStatus == .completed {
//            print("✅ DEV MODE: Cancelling payment authorization \(authToken) for completed task")
//            task.paymentAuthorizationDate = nil
//            task.paymentAuthorizationToken = nil
//        } else if task.taskStatus == .failed {
//            print("💰 DEV MODE: Processing payment of $\(task.challengeAmount) using auth token \(authToken)")
//            // TODO: Actual payment processing
//            task.paymentAuthorizationDate = nil
//            task.paymentAuthorizationToken = nil
//        }
//        
//        do {
//            try viewContext.save()
//        } catch {
//            alertItem = AlertItem(
//                title: Text("Error"),
//                message: Text("Failed to authorize payment"),
//                dismissButton: .default(Text("OK"))
//            )
//        }
//    }
//    
//    
//}

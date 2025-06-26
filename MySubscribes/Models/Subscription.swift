//
//  Subscription.swift
//  MySubscribes
//
//  Created by apple on 25.06.2025.
//



import SwiftUI
import SwiftData

// MARK: - SwiftData Model
@Model
final class Subscription {
    var serviceName: String = ""
    var monthlyCost: Double = 0.0
    var billingPeriod: String = "Monthly"
    var nextPaymentDate: Date = Date()
    var createdDate: Date = Date()
    
    init(serviceName: String, monthlyCost: Double, billingPeriod: String, nextPaymentDate: Date) {
        self.serviceName = serviceName
        self.monthlyCost = monthlyCost
        self.billingPeriod = billingPeriod
        self.nextPaymentDate = nextPaymentDate
        self.createdDate = Date()
    }
    
    // Empty initializer for SwiftData
    init() {}
}










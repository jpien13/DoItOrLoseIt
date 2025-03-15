//
//  BalanceManager.swift
//  DoItOrLoseIt
//
//  Created by Jason Pien on 3/15/25.
//

import Foundation
import CoreData
import OSLog
import SwiftUI

class BalanceManager: ObservableObject {
    
    @Published var alertItem: AlertItem?
    
    /*
     Add funds to balance.
     
     Param:
     amount: A double that is the value being added to balance.
             The "_" means I dont have to specify the paramater.
             I.E. I dont have to do addFunds(amount: 50)
     transactionDescription: Defaults to "deposit" if not specified.
                             The type of transaction
     
     Does not return anything, just updates balance
     
     --------------------------------------------------------------
     Guards the amount to first ensure amount is a pos num. If not pos,
     executes inside the {}
     */
    func addFunds(_ amount: Double, transactionDescription: String = "Deposit"){
        guard amount > 0 else {
            alertItem = AlertItem(
                title: Text("Invalid Amount"),
                message: Text("Amount must be positive to add funds."),
                dismissButton: .default(Text("OK"))
            )
            return
        }
        
        updateBalance(amount, type: .deposit, transactionDescription: transactionDescription)
    }
    
    func deductWager(){
        
    }
    
    func refundWager(){
        
    }
    
    private func loadBalance(){
        
    }
    
    private func createInitBalance(){
        
    }
    
    private func loadTransactions(){
        
    }
    
    private func updateBalance(_ amount: Double, type: TransactionType, transactionDescription: String, taskId: UUID? = nil){
        
    }
    
    
}

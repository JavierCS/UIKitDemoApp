import Foundation
import CoreData

class CoreDataExamples {
    static func run() {
        runBowTiesExamples()
    }
    
    static func runBowTiesExamples() {
        let bowTie = NSEntityDescription.insertNewObject(forEntityName: "BowTie", into: CDBowTies.shared.persistantContainer.viewContext) as! BowTie
        bowTie.name = "My bow tie"
        bowTie.lastWorn = Date()
        try? CDBowTies.shared.persistantContainer.viewContext.save()
        
        let request = BowTie.fetchRequest()
        
        if let ties = try? CDBowTies.shared.persistantContainer.viewContext.fetch(request),
           let testName = ties.first?.name,
           let testLastWorn = ties.first?.lastWorn {
            print("Name: \(testName), Worn: \(testLastWorn)")
        } else {
            print("Test failed.")
        }
        
    }
}

import Foundation
import CoreData

extension Sneaker {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sneaker> {
        return NSFetchRequest<Sneaker>(entityName: "Sneaker")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var brand: String?
    @NSManaged public var size: Double
    @NSManaged public var price: Double
    @NSManaged public var currency: String?
    @NSManaged public var sizeUnit: String?
    @NSManaged public var condition: Int16
    @NSManaged public var isWishlist: Bool
    @NSManaged public var imageData: Data?
    @NSManaged private var rawUUID: UUID?
    @NSManaged public var photoFront: Data?
    @NSManaged public var photoBox: Data?
    @NSManaged public var photoInsole: Data?
    @NSManaged public var photoSide: Data?
    @NSManaged public var photoSole: Data?
    @NSManaged public var photoBack: Data?


    public var uuid: UUID {
        get {
            if let existingUUID = rawUUID {
                return existingUUID
            } else {
                let newUUID = UUID()
                self.rawUUID = newUUID
                return newUUID
            }
        }
        set {
            rawUUID = newValue
        }
    }
}

extension Sneaker: Identifiable {
}

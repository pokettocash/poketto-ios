// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PKContact.swift instead.

import Foundation
import CoreData

public enum PKContactAttributes: String {
    case address = "address"
    case avatar_url = "avatar_url"
    case contact_id = "contact_id"
    case name = "name"
}

open class _PKContact: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "PKContact"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<PKContact> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _PKContact.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var address: String!

    @NSManaged open
    var avatar_url: String?

    @NSManaged open
    var contact_id: String?

    @NSManaged open
    var name: String?

    // MARK: - Relationships

}


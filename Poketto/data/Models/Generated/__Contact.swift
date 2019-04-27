// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Contact.swift instead.

import Foundation
import CoreData

public enum ContactAttributes: String {
    case address = "address"
    case avatar_url = "avatar_url"
    case contact_id = "contact_id"
    case name = "name"
}

open class _Contact: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Contact"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Contact.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var address: String!

    @NSManaged open
    var avatar_url: String?

    @NSManaged open
    var contact_id: Int16 // Optional scalars not supported

    @NSManaged open
    var name: String?

    // MARK: - Relationships

}


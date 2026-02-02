import Foundation
import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    /// Initialize Core Data stack, use in-memory store if specified
    init(inMemory: Bool = false) {
        // Programmatic model definition
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "ClipboardEntry"
        // Use generic NSManagedObject class
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        // Attributes
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let contentAttr = NSAttributeDescription()
        contentAttr.name = "content"
        contentAttr.attributeType = .stringAttributeType
        contentAttr.isOptional = false

        let typeAttr = NSAttributeDescription()
        typeAttr.name = "type"
        typeAttr.attributeType = .stringAttributeType
        typeAttr.isOptional = false

        let timestampAttr = NSAttributeDescription()
        timestampAttr.name = "timestamp"
        timestampAttr.attributeType = .dateAttributeType
        timestampAttr.isOptional = false

        let pinnedAttr = NSAttributeDescription()
        pinnedAttr.name = "pinned"
        pinnedAttr.attributeType = .booleanAttributeType
        pinnedAttr.isOptional = false

        entity.properties = [idAttr, contentAttr, typeAttr, timestampAttr, pinnedAttr]
        model.entities = [entity]

        // Container setup
        container = NSPersistentContainer(name: "ClipboardHistoryModel", managedObjectModel: model)
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores { storeDesc, error in
            if let error = error {
                fatalError("Unresolved Core Data error: \(error)")
            }
        }
    }

    /// Insert a new clipboard entry
    func addEntry(content: String, type: String, pinned: Bool = false) {
        // Skip duplicate: do not add if same as the most recent entry
        if let latest = (try? fetchEntries(limit: 1).first), latest.value(forKey: "content") as? String == content {
            return
        }
        let context = container.viewContext
        guard let entity = container.managedObjectModel.entitiesByName["ClipboardEntry"] else { return }
        let entry = NSManagedObject(entity: entity, insertInto: context)
        entry.setValue(UUID(), forKey: "id")
        entry.setValue(content, forKey: "content")
        entry.setValue(type, forKey: "type")
        entry.setValue(Date(), forKey: "timestamp")
        entry.setValue(pinned, forKey: "pinned")
        saveContext()
        // Enforce max items limit
        let maxItems = UserDefaults.standard.object(forKey: "maxItems") as? Int ?? 50
        do {
            try purgeExcessEntries(keeping: maxItems)
        } catch {
            print("Error enforcing max items: \(error)")
        }
    }

    /// Fetch entries sorted by timestamp descending
    func fetchEntries(limit: Int? = nil) throws -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "ClipboardEntry")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        if let limit = limit {
            request.fetchLimit = limit
        }
        return try container.viewContext.fetch(request)
    }

    /// Delete a given entry
    func deleteEntry(_ entry: NSManagedObject) throws {
        let context = container.viewContext
        context.delete(entry)
        try context.save()
    }

    /// Delete entries older than specified number of days
    func purgeOldEntries(olderThan days: Int) throws {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ClipboardEntry")
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        fetchRequest.predicate = NSPredicate(format: "timestamp < %@", cutoffDate as NSDate)
        let oldEntries = try container.viewContext.fetch(fetchRequest)
        for entry in oldEntries {
            container.viewContext.delete(entry)
        }
        if container.viewContext.hasChanges {
            try container.viewContext.save()
        }
    }

    /// Purge entries exceeding the max count, keeping only the newest `maxItems` entries
    func purgeExcessEntries(keeping maxItems: Int) throws {
        let allCount = try fetchEntries().count
        let excess = allCount - maxItems
        guard excess > 0 else { return }
        let request = NSFetchRequest<NSManagedObject>(entityName: "ClipboardEntry")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        request.fetchLimit = excess
        let toDelete = try container.viewContext.fetch(request)
        for entry in toDelete {
            container.viewContext.delete(entry)
        }
        if container.viewContext.hasChanges {
            try container.viewContext.save()
        }
    }

    /// Save context if changes exist
    private func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}

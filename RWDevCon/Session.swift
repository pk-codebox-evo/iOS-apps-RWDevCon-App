
import Foundation
import CoreData

private let formatter = NSDateFormatter()

@objc(Session)
class Session: NSManagedObject {
  @NSManaged var identifier: String
  @NSManaged var active: Bool
  @NSManaged var title: String
  @NSManaged var date: NSDate
  @NSManaged var duration: Int32
  @NSManaged var column: Int32
  @NSManaged var sessionNumber: String
  @NSManaged var sessionDescription: String
  @NSManaged var room: Room
  @NSManaged var track: Track
  @NSManaged var presenters: NSOrderedSet

  var fullTitle: String {
    return (sessionNumber != "" ? "\(sessionNumber): " : "") + title
  }

  var startDateDayOfWeek: String {
    return formatDate("EEEE")
  }

  var startDateTimeString: String {
    return formatDate("EEEE h:mm a")
  }

  var startTimeString: String {
    return formatDate("h:mm a")
  }

  var isFavorite: Bool {
    get {
      let favorites = Config.favoriteSessions()
      return Array(favorites.values).contains(identifier)
    }
    set {
      if newValue {
        Config.registerFavorite(self)
      } else {
        Config.unregisterFavorite(self)
      }
    }
  }
  
  var isParty: Bool {
    return title.lowercaseString.containsString("party")
  }

  func formatDate(format: String) -> String {
    formatter.dateFormat = format
    formatter.timeZone = NSTimeZone(name: "US/Eastern")!

    return formatter.stringFromDate(date)
  }

  class func sessionCount(context: NSManagedObjectContext) -> Int {
    let fetch = NSFetchRequest(entityName: "Session")
    fetch.includesSubentities = false
    return context.countForFetchRequest(fetch, error: nil)
  }

  class func sessionByIdentifier(identifier: String, context: NSManagedObjectContext) -> Session? {
    let fetch = NSFetchRequest(entityName: "Session")
    fetch.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
    do {
      let results = try context.executeFetchRequest(fetch)
      guard let result = results.first as? Session else { return nil }
      return result
    } catch {
      return nil
    }
  }

  class func sessionByIdentifierOrNew(identifier: String, context: NSManagedObjectContext) -> Session {
    return sessionByIdentifier(identifier, context: context) ?? Session(entity: NSEntityDescription.entityForName("Session", inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
  }
}

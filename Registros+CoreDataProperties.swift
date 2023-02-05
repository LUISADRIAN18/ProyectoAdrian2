//
//  Registros+CoreDataProperties.swift
//  ProyectoAdrian
//
//  Created by Luis Garcia on 30/01/23.
//
//

import Foundation
import CoreData


extension Registros {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Registros> {
        return NSFetchRequest<Registros>(entityName: "Registros")
    }

    @NSManaged public var tiempo: String?
    @NSManaged public var observaciones: String?
    @NSManaged public var fecha: Date?

}

extension Registros : Identifiable {

}

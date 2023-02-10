//
//  MukLocation+CoreDataProperties.swift
//  MukLabTest2
//
//  Created by Mukhtar Yusuf on 2/1/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//
//

import Foundation
import CoreData


extension MukLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MukLocation> {
        return NSFetchRequest<MukLocation>(entityName: "MukLocation")
    }

    @NSManaged public var mukTitle: String
    @NSManaged public var mukSubTitle: String
    @NSManaged public var mukLatitude: Double
    @NSManaged public var mukLongitude: Double

}

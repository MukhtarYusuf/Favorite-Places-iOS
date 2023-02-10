//
//  MukLocation+CoreDataClass.swift
//  MukLabTest2
//
//  Created by Mukhtar Yusuf on 2/1/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(MukLocation)
public class MukLocation: NSManagedObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(mukLatitude, mukLongitude)
    }
    public var title: String? {
        return mukTitle
    }
    public var subtitle: String? {
        return mukSubTitle
    }
}

//
//  RealmServiceTests.swift
//  CallKittyTests
//
//  Created by Steve Baker on 11/8/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import XCTest
@testable import CallKitty

class RealmServiceTests: XCTestCase {

    func testShared() {
        XCTAssertNotNil(RealmService.shared)
    }

    func testReadAddUpdateDelete() {

        let realmService = RealmService.shared
        let phoneCallers = realmService.realm.objects(PhoneCaller.self).sorted(byKeyPath: "phoneNumber")
        let initialCount = phoneCallers.count

        let phoneCaller = PhoneCaller(phoneNumber: 123, label: "dog")
        XCTAssertEqual(phoneCaller.phoneNumber, 123)
        XCTAssertEqual(phoneCaller.label, "dog")
        XCTAssertFalse(phoneCaller.isBlocked)

        realmService.add(phoneCaller)
        XCTAssertEqual(phoneCallers.count, initialCount + 1)

        realmService.update(phoneCaller, with: ["phoneNumber" : 456])
        XCTAssertEqual(phoneCaller.phoneNumber, 456)
        XCTAssertEqual(phoneCaller.label, "dog")
        XCTAssertFalse(phoneCaller.isBlocked)

        realmService.update(phoneCaller, with: ["label" : "cat", "isBlocked" : true])
        XCTAssertEqual(phoneCaller.phoneNumber, 456)
        XCTAssertEqual(phoneCaller.label, "cat")
        XCTAssertTrue(phoneCaller.isBlocked)

        realmService.delete(phoneCaller)
        XCTAssertEqual(phoneCallers.count, initialCount)
    }

}

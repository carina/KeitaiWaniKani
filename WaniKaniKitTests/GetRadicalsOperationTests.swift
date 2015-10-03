//
//  GetRadicalsOperationTests.swift
//  WaniKaniKit
//
//  Copyright © 2015 Chris Laverty. All rights reserved.
//

import XCTest
import OperationKit
@testable import WaniKaniKit

class GetRadicalsOperationTests: DatabaseTestCase {
        
    func testRadicalLevel1Success() {
        // Check a radical with a Unicode character
        let expectedFinsRadical = Radical(character: "ハ",
            meaning: "fins",
            level: 1,
            userSpecificSRSData: UserSpecificSRSData(srsLevel: .Guru,
                srsLevelNumeric: 6,
                dateUnlocked: NSDate(timeIntervalSince1970: NSTimeInterval(1436287262)),
                dateAvailable: NSDate(timeIntervalSince1970: NSTimeInterval(1438280100)),
                burned: false,
                meaningStats: ItemStats(correctCount: 5, incorrectCount: 0, maxStreakLength: 5, currentStreakLength: 5)))
        
        // Check a radical with an image instead of a Unicode character
        let expectedStickRadical = Radical(meaning: "stick",
            image: NSURL(string: "https://s3.amazonaws.com/s3.wanikani.com/images/radicals/802e9542627291d4282601ded41ad16ce915f60f.png"),
            level: 1,
            userSpecificSRSData: UserSpecificSRSData(srsLevel: .Guru,
                srsLevelNumeric: 6,
                dateUnlocked: NSDate(timeIntervalSince1970: NSTimeInterval(1436287262)),
                dateAvailable: NSDate(timeIntervalSince1970: NSTimeInterval(1438280100)),
                burned: false,
                meaningStats: ItemStats(correctCount: 5, incorrectCount: 0, maxStreakLength: 5, currentStreakLength: 5)))
        

        let resourceResolver = TestFileResourceResolver(fileName: "Radicals Level 1")
        let operationQueue = OperationQueue()
        
        self.measureBlock() {
            let expect = self.expectationWithDescription("radicals")
            let operation = GetRadicalsOperation(resolver: resourceResolver, databaseQueue: self.databaseQueue, downloadStrategy: self.stubDownloadStrategy)
            
            let completionObserver = BlockObserver(finishHandler: { (operation, errors) -> Void in
                defer { expect.fulfill() }
                XCTAssertEqual(errors.count, 0, "Expected no errors, but received: \(errors)")
            })
            operation.addObserver(completionObserver)
            operationQueue.addOperation(operation)
            
            self.waitForExpectationsWithTimeout(5.0, handler: nil)
        }
        
        databaseQueue.inDatabase { database in
            do {
                let fromDatabase = try Radical.coder.loadFromDatabase(database)
                XCTAssertEqual(fromDatabase.count, 26, "Failed to load all radicals")
                
                if let actualFinsRadical = fromDatabase.filter({ $0.meaning == expectedFinsRadical.meaning }).first {
                    XCTAssertEqual(actualFinsRadical, expectedFinsRadical, "Fins radical did not match")
                } else {
                    XCTFail("Could not find radical with meaning \(expectedFinsRadical.meaning)")
                }
                
                if let actualStickRadical = fromDatabase.filter({ $0.meaning == expectedStickRadical.meaning }).first {
                    XCTAssertEqual(actualStickRadical, expectedStickRadical, "Stick radical did not match")
                } else {
                    XCTFail("Could not find radical with meaning \(expectedStickRadical.meaning)")
                }
            } catch {
                XCTFail("Could not load radicals from database due to error: \(error)")
            }
        }
    }
    
    #if HAS_DOWNLOADED_DATA
    func testLoadByLevel() {
        let resourceResolver = TestFileResourceResolver(fileName: "Radicals Levels 1-20")
        let operationQueue = OperationQueue()
        
        let expect = self.expectationWithDescription("radicals")
        let operation = GetRadicalsOperation(resolver: resourceResolver, databaseQueue: self.databaseQueue, downloadStrategy: self.stubDownloadStrategy)
        
        let completionObserver = BlockObserver(finishHandler: { (operation, errors) -> Void in
            defer { expect.fulfill() }
            XCTAssertEqual(errors.count, 0, "Expected no errors, but received: \(errors)")
        })
        operation.addObserver(completionObserver)
        operationQueue.addOperation(operation)
        
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        databaseQueue.inDatabase { database in
            do {
                let fromDatabase = try Radical.coder.loadFromDatabase(database, forLevel: 3)
                XCTAssertEqual(fromDatabase.count, 22, "Failed to load all radicals")
            } catch {
                XCTFail("Could not load radicals from database due to error: \(error)")
            }
        }
    }
    
    func testRadicalsPerformance() {
        let radicalCount = 26 + 35 + 22 + 33 + 27 + 19 + 17 + 16 + 15 + 14 +
            14 + 11 + 16 + 6 + 7 + 6 + 8 + 8 + 9 + 7
        
        let resourceResolver = TestFileResourceResolver(fileName: "Radicals Levels 1-20")
        let operationQueue = OperationQueue()
        
        self.measureBlock() {
            let expect = self.expectationWithDescription("radicals")
            let operation = GetRadicalsOperation(resolver: resourceResolver, databaseQueue: self.databaseQueue, downloadStrategy: self.stubDownloadStrategy)
            
            let completionObserver = BlockObserver(finishHandler: { (operation, errors) -> Void in
                defer { expect.fulfill() }
                XCTAssertEqual(errors.count, 0, "Expected no errors, but received: \(errors)")
            })
            operation.addObserver(completionObserver)
            operationQueue.addOperation(operation)
            
            self.waitForExpectationsWithTimeout(10.0, handler: nil)
        }

        databaseQueue.inDatabase { database in
            do {
                let fromDatabase = try Radical.coder.loadFromDatabase(database)
                XCTAssertEqual(fromDatabase.count, radicalCount, "Failed to load all radicals")
            } catch {
                XCTFail("Could not load radicals from database due to error: \(error)")
            }
        }
    }
    #endif

}

/**
 *  Copyright (C) 2010-2019 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import XCTest

@testable import Pocket_Code

final class IterableCacheTests: XCTestCase {

    var iterableCache: IterableCache<AudioPlayer>!

    override func setUp() {
        super.setUp()
        iterableCache = IterableCache<AudioPlayer>()
    }

    func testSetObject_setOnePlayerInCache_expectSamePlayerInCache() {
        let audioPlayerFactory = MockAudioPlayerFactory()
        let player = audioPlayerFactory.createAudioPlayer(fileName: "player1", filePath: "player1")
        iterableCache.setObject(player!, forKey: "player1")
        XCTAssertEqual(iterableCache.getKeySet().count, 1)
        XCTAssertTrue(iterableCache.cache.object(forKey: "player1" as NSString)! === player)
    }

    func testSetObject_setTwoPlayersInCache_expectSamePlayersInCache() {
        let players = setTwoPlayersInCache()
        XCTAssertEqual(iterableCache.getKeySet().count, 2)
        XCTAssertTrue(iterableCache.cache.object(forKey: "player1" as NSString)! === players.0)
        XCTAssertTrue(iterableCache.cache.object(forKey: "player2" as NSString)! === players.1)
    }

    func testSetObject_limitCacheToOneElementAndSetTwoElements_expectFirstElementGettingEvicted() {
        iterableCache.cache.countLimit = 1
        let players = setTwoPlayersInCache()

        let onePlayerEjectedPredicate = NSPredicate { _, _ in self.iterableCache.getKeySet().count == 1 }
        expectation(for: onePlayerEjectedPredicate, evaluatedWith: "", handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertNil(iterableCache.cache.object(forKey: "player1" as NSString))
        XCTAssertTrue(iterableCache.cache.object(forKey: "player2" as NSString)! === players.1)
    }

    func testObjectForKey_setTwoPlayersInCache_retrieveCorrectPlayers() {
        let players = setTwoPlayersInCache()
        XCTAssertTrue(iterableCache.object(forKey: "player1") === players.0)
        XCTAssertTrue(iterableCache.object(forKey: "player2") === players.1)
    }

    func testGetKeySet_setTwoPlayersInCache_retrieveCorrectKeySet() {
        _ = setTwoPlayersInCache()
        XCTAssertTrue(iterableCache.keySet.contains("player1"))
        XCTAssertTrue(iterableCache.keySet.contains("player2"))
    }

    func testRemoveAllObjects_removePlayersFromCahce_noPlayersInCache() {
        _ = setTwoPlayersInCache()
        iterableCache.removeAllObjects()
        XCTAssertEqual(iterableCache.keySet.count, 0)
        XCTAssertNil(iterableCache.cache.object(forKey: "player1"))
        XCTAssertNil(iterableCache.cache.object(forKey: "player2"))
    }

    private func setTwoPlayersInCache() -> (AudioPlayer, AudioPlayer) {
        let audioPlayerFactory = MockAudioPlayerFactory()
        let player1 = audioPlayerFactory.createAudioPlayer(fileName: "player1", filePath: "player1")
        player1?.fileName = "player1"
        let player2 = audioPlayerFactory.createAudioPlayer(fileName: "player2", filePath: "player2")
        player2?.fileName = "player2"
        iterableCache.setObject(player1!, forKey: "player1")
        iterableCache.setObject(player2!, forKey: "player2")
        return (player1!, player2!)
    }
}

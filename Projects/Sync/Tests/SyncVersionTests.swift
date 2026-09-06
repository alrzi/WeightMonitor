import Foundation
import Sync
@testable import SyncImplementation
import Testing

@Suite
struct SyncVersionTests {
    @Test func usesDeviceIDAsFinalTieBreaker() {
        // GIVEN
        let physicalTime = Date(timeIntervalSince1970: 1000)
        let first = SyncVersion(physicalTime: physicalTime, logicalCounter: 1, deviceID: makeDeviceID(1))
        let second = SyncVersion(physicalTime: physicalTime, logicalCounter: 1, deviceID: makeDeviceID(2))

        // THEN
        #expect(first < second)
    }

    private func makeDeviceID(_ value: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", value))!
    }
}

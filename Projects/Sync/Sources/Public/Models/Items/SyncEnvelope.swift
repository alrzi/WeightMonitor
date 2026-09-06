import Foundation

public enum SyncEnvelope: Codable, Equatable, Sendable {
    case payload(SyncPayload)
    case snapshot(SyncSnapshot)
    case acknowledgement(SyncAcknowledgement)

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(Kind.self, forKey: .kind) {
        case .payload:
            self = .payload(try container.decode(SyncPayload.self, forKey: .payload))

        case .snapshot:
            self = .snapshot(try container.decode(SyncSnapshot.self, forKey: .snapshot))

        case .acknowledgement:
            self = .acknowledgement(
                try container.decode(SyncAcknowledgement.self, forKey: .acknowledgement)
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .payload(let payload):
            try container.encode(Kind.payload, forKey: .kind)
            try container.encode(payload, forKey: .payload)

        case .snapshot(let snapshot):
            try container.encode(Kind.snapshot, forKey: .kind)
            try container.encode(snapshot, forKey: .snapshot)

        case .acknowledgement(let acknowledgement):
            try container.encode(Kind.acknowledgement, forKey: .kind)
            try container.encode(acknowledgement, forKey: .acknowledgement)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case payload
        case snapshot
        case acknowledgement
    }

    private enum Kind: String, Codable {
        case payload
        case snapshot
        case acknowledgement
    }
}

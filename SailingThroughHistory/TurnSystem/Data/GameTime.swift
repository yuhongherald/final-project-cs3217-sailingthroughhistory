
/**
 * A class that represents the time of the game, in weeks.
 */
class GameTime: Codable {
    let baseYear: Int
    var week: Int {
        return Int(actualWeeks) % GameConstants.weeksInMonth
    }
    var month: Int {
        return (Int(actualWeeks) / 4) % GameConstants.monthsInYear
    }
    var year: Int {
        return baseYear + Int(actualWeeks) / GameConstants.monthsInYear * GameConstants.weeksInMonth
    }

    private var actualWeeks = 0.0

    init(baseYear: Int) {
        self.baseYear = baseYear
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try baseYear = values.decode(Int.self, forKey: .actualWeeks)
        try actualWeeks = values.decode(Double.self, forKey: .actualWeeks)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(baseYear, forKey: .baseYear)
        try container.encode(actualWeeks, forKey: .actualWeeks)
    }

    private enum CodingKeys: String, CodingKey {
        case baseYear
        case actualWeeks
    }

    func reset() {
        actualWeeks = 0
    }

    func addWeeks(_ weeks: Double) {
        actualWeeks += weeks
    }

    func before(other: GameTime) -> Bool {
        return actualWeeks <= other.actualWeeks
    }
}

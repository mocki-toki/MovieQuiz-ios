//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Simon Butenko on 15.02.2024.
//

import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

class StatisticServiceImpl: StatisticService {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case total, bestGame, gamesCount
    }

    /// Сохранение результата
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1

        let accuracy = Double(count) / Double(amount) * 100
        totalAccuracy = (totalAccuracy * Double(gamesCount) + accuracy) / Double(gamesCount + 1)

        let record = GameRecord(correct: count, total: amount, date: Date())
        if record.isBetterThan(bestGame) {
            bestGame = record
        }
    }

    /// Общая аккуратность
    var totalAccuracy: Double {
        get {
            userDefaults.double(forKey: Keys.total.rawValue)
        }

        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }

    /// Количество игр
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }

        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    /// Лучший результат
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data)
            else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }

        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
}

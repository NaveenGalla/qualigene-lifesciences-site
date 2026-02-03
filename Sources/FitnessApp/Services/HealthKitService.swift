import Foundation
import HealthKit

enum HealthKitError: Error {
    case notAvailable
    case missingType
}

final class HealthKitService {
    private let healthStore = HKHealthStore()
    private let calendar = Calendar.current

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isAvailable else { throw HealthKitError.notAvailable }

        let readTypes = try requestedReadTypes()
        try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HealthKitError.notAvailable)
                }
            }
        }

        try await enableBackgroundDelivery(for: readTypes)
    }

    func fetchDailySamples(for metric: MetricType, days: Int = 14) async throws -> [MetricSample] {
        let dateRange = makeDateRange(days: days)

        switch metric {
        case .sleep:
            return try await fetchSleepSamples(in: dateRange)
        case .workout:
            return try await fetchWorkoutSamples(in: dateRange)
        case .heartRate:
            return try await fetchQuantitySamples(
                identifier: .heartRate,
                unit: HKUnit.count().unitDivided(by: .minute()),
                options: .discreteAverage,
                in: dateRange
            )
        case .recovery:
            return try await fetchQuantitySamples(
                identifier: .heartRateVariabilitySDNN,
                unit: HKUnit.secondUnit(with: .milli),
                options: .discreteAverage,
                in: dateRange
            )
        case .water:
            return try await fetchQuantitySamples(
                identifier: .dietaryWater,
                unit: .fluidOunceUS(),
                options: .cumulativeSum,
                in: dateRange
            )
        case .mood:
            return []
        }
    }

    // MARK: - Private

    private func requestedReadTypes() throws -> Set<HKObjectType> {
        var types: Set<HKObjectType> = []

        guard
            let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
            let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
            let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
            let water = HKObjectType.quantityType(forIdentifier: .dietaryWater)
        else {
            throw HealthKitError.missingType
        }

        types.insert(sleep)
        types.insert(heartRate)
        types.insert(hrv)
        types.insert(water)
        types.insert(HKObjectType.workoutType())

        return types
    }

    private func enableBackgroundDelivery(for types: Set<HKObjectType>) async throws {
        try await withCheckedThrowingContinuation { continuation in
            healthStore.enableBackgroundDelivery(for: types, frequency: .daily) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HealthKitError.notAvailable)
                }
            }
        }
    }

    private func makeDateRange(days: Int) -> (start: Date, end: Date) {
        let today = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -(days - 1), to: today) ?? today
        let end = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        return (start, end)
    }

    private func fetchQuantitySamples(
        identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        options: HKStatisticsOptions,
        in range: (start: Date, end: Date)
    ) async throws -> [MetricSample] {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            throw HealthKitError.missingType
        }

        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: range.start, end: range.end)
            let anchorDate = calendar.startOfDay(for: range.end)
            let interval = DateComponents(day: 1)

            let query = HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: options,
                anchorDate: anchorDate,
                intervalComponents: interval
            )

            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                var samples: [MetricSample] = []
                results?.enumerateStatistics(from: range.start, to: range.end) { statistic, _ in
                    let value: Double
                    switch options {
                    case .cumulativeSum:
                        value = statistic.sumQuantity()?.doubleValue(for: unit) ?? 0
                    default:
                        value = statistic.averageQuantity()?.doubleValue(for: unit) ?? 0
                    }
                    samples.append(MetricSample(date: statistic.startDate, value: value))
                }

                continuation.resume(returning: samples)
            }

            healthStore.execute(query)
        }
    }

    private func fetchSleepSamples(in range: (start: Date, end: Date)) async throws -> [MetricSample] {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitError.missingType
        }

        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: range.start, end: range.end)
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let categorySamples = (samples as? [HKCategorySample]) ?? []
                var buckets: [Date: TimeInterval] = [:]

                for sample in categorySamples {
                    guard isAsleep(sample.value) else { continue }
                    let day = self.calendar.startOfDay(for: sample.startDate)
                    let duration = sample.endDate.timeIntervalSince(sample.startDate)
                    buckets[day, default: 0] += duration
                }

                let metricSamples = buckets
                    .map { MetricSample(date: $0.key, value: $0.value / 3600) }
                    .sorted { $0.date < $1.date }

                continuation.resume(returning: metricSamples)
            }
            healthStore.execute(query)
        }
    }

    private func fetchWorkoutSamples(in range: (start: Date, end: Date)) async throws -> [MetricSample] {
        let workoutType = HKObjectType.workoutType()

        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: range.start, end: range.end)
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let workouts = (samples as? [HKWorkout]) ?? []
                var buckets: [Date: TimeInterval] = [:]

                for workout in workouts {
                    let day = self.calendar.startOfDay(for: workout.startDate)
                    buckets[day, default: 0] += workout.duration / 60
                }

                let metricSamples = buckets
                    .map { MetricSample(date: $0.key, value: $0.value) }
                    .sorted { $0.date < $1.date }

                continuation.resume(returning: metricSamples)
            }
            healthStore.execute(query)
        }
    }

    private func isAsleep(_ value: Int) -> Bool {
        if #available(iOS 16.0, *) {
            return value == HKCategoryValueSleepAnalysis.asleep.rawValue
                || value == HKCategoryValueSleepAnalysis.asleepCore.rawValue
                || value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue
                || value == HKCategoryValueSleepAnalysis.asleepREM.rawValue
        }
        return value == HKCategoryValueSleepAnalysis.asleep.rawValue
    }
}

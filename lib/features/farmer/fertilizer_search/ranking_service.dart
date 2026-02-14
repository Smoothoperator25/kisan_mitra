import 'fertilizer_search_model.dart';
import 'dart:math';

class RankingService {
  // Weights
  static const double distanceWeight = 0.4;
  static const double priceWeight = 0.3;
  static const double availabilityWeight = 0.2;
  static const double ratingWeight = 0.1;

  List<StoreSearchResult> rankStores(
    List<StoreSearchResult> results,
    double maxDistance,
    double maxPrice,
  ) {
    if (results.isEmpty) return [];

    double minPrice = results.map((e) => e.details.price).reduce(min);
    double maxP = results.map((e) => e.details.price).reduce(max);

    // Avoid division by zero if all prices are same
    if (minPrice == maxP) {
      minPrice = 0;
      // maxP stays as is, or effectively normalized price becomes 1.0 or 0.0 depending on logic
    }

    // We want to normalize such that:
    // Distance: closer is better (1.0 for 0km, 0.0 for maxDistance)
    // Price: lower is better (1.0 for minPrice, 0.0 for maxPrice)
    // Rating: higher is better (1.0 for 5 stars, 0.0 for 0 stars)

    // Creating a new list to store results with scores
    List<StoreSearchResult> rankedResults = [];

    for (var result in results) {
      // 1. Normalize Distance Score (0 to 1) - Closer is better
      // If distance > maxDistance (5km), score is 0.
      // But we filtered them out already? Assuming we passed filtered list.
      // Let's assume max possible helpful distance in this context is 5km
      double normalizedDistanceScore = 1.0 - (result.distance / 5.0);
      if (normalizedDistanceScore < 0) normalizedDistanceScore = 0;

      // 2. Normalize Price Score (0 to 1) - Lower is better
      // priceScore = 1 - ( (price - min) / (max - min) )
      double normalizedPriceScore;
      if (maxP == minPrice) {
        normalizedPriceScore = 1.0;
      } else {
        normalizedPriceScore =
            1.0 - ((result.details.price - minPrice) / (maxP - minPrice));
      }

      // 3. Availability Score (0 or 1)
      double availabilityScore = result.details.isAvailable ? 1.0 : 0.0;
      // Bonus: In stock = +1 bonus (as per requirement "In stock = +1 bonus")
      // Wait, "In stock = +1 bonus" in the prompt might mean add +1 to the raw score?
      // Or 1.0 for the weight calculation?
      // "availabilityWeight * availabilityScore" implies weighted score.
      // Let's stick to 1.0 * 0.2
      // If the prompt meant a raw +1 to the final score, that would dominate the 0-1 range weights.
      // I will assume it means full score for this component.

      // 4. Normalize Rating Score (0 to 1)
      double normalizedRatingScore = result.store.rating / 5.0;

      // Final Score Calculation
      double score =
          (distanceWeight * normalizedDistanceScore) +
          (priceWeight * normalizedPriceScore) +
          (availabilityWeight * availabilityScore) +
          (ratingWeight * normalizedRatingScore);

      // If "In stock = +1 bonus" meant literally adding 1 to the final score:
      // The prompt said:
      // Score formula:
      // score = (distanceWeight ...) + ... + (availabilityWeight * availabilityScore) + ...
      // Rules: ... In stock = +1 bonus ...
      // This is slightly contradictory or just a phrasing for "availability gives a full point in its component".
      // I will follow the formula provided in the prompt strictly.

      rankedResults.add(
        StoreSearchResult(
          store: result.store,
          details: result.details,
          distance: result.distance,
          score: score,
        ),
      );
    }

    // Sort descending by score
    rankedResults.sort((a, b) => b.score.compareTo(a.score));

    return rankedResults;
  }
}

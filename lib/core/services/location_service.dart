import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart' as geocoding;

class Position {
  Position({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}

class LocationService {
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Konum hizmetleri devre dışı.');
    }

    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        throw Exception('Konum izni reddedildi.');
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      throw Exception('Konum izni kalıcı olarak reddedildi.');
    }

    final geoPosition = await geo.Geolocator.getCurrentPosition();
    return Position(
      latitude: geoPosition.latitude,
      longitude: geoPosition.longitude,
    );
  }

  Future<String> getAddressFromCoordinates(Position position) async {
    try {
      final addresses = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (addresses.isNotEmpty) {
        final placemark = addresses.first;

        // Turkey Address Logic:
        // administrativeArea: City (e.g. Kocaeli, Istanbul)
        // subAdministrativeArea: District (e.g. Darıca, Kadıköy) - PRIORITIZE THIS
        // locality: Often same as City or a central town
        // subLocality: Neighborhood (Mahalle)

        final city = placemark.administrativeArea ?? '';
        final district =
            placemark.subAdministrativeArea ?? placemark.locality ?? '';
        final neighborhood = placemark.subLocality ?? '';

        // If we have Neighborhood + District
        if (neighborhood.isNotEmpty && district.isNotEmpty) {
          return '$neighborhood, $district';
        }

        // Fallback: District + City (e.g. Darıca, Kocaeli)
        if (district.isNotEmpty && city.isNotEmpty && district != city) {
          return '$district, $city';
        }

        // Fallback: Just District or City
        return district.isNotEmpty ? district : city;
      }
      return 'Bilinmeyen Konum';
    } catch (e) {
      return 'Konum Alınamadı';
    }
  }

  Future<Map<String, String>> getLocationDetails(Position position) async {
    try {
      final addresses = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (addresses.isNotEmpty) {
        final place = addresses.first;
        final city = place.administrativeArea ?? '';

        // Potential District Candidates
        // In Turkey:
        // subAdministrativeArea is usually the District (e.g. Darıca)
        // locality is sometimes the District or the City Center

        String district = '';

        // Known Central Districts for Major Cities (where "Merkez" is actually a named district)
        final knownCentralDistricts = {
          'Kocaeli': 'İzmit',
          'Sakarya': 'Adapazarı',
          'Hatay': 'Antakya',
          'Mersin': 'Akdeniz',
        };

        // 1. Try subAdministrativeArea (Most reliable for District)
        final candidate1 = place.subAdministrativeArea;
        if (candidate1 != null &&
            candidate1.isNotEmpty &&
            candidate1.toLowerCase() != city.toLowerCase()) {
          district = candidate1;
        }

        // 2. If 'district' is still empty, try locality
        if (district.isEmpty) {
          final candidate2 = place.locality;
          if (candidate2 != null &&
              candidate2.isNotEmpty &&
              candidate2.toLowerCase() != city.toLowerCase()) {
            district = candidate2;
          }
        }

        // 3. Smart Fallback: If district matches city or is empty, check known list
        if (district.isEmpty || district.toLowerCase() == city.toLowerCase()) {
          if (knownCentralDistricts.containsKey(city)) {
            district = knownCentralDistricts[city]!;
          }
        }

        // 4. Last Resort: subLocality (Neighborhood)
        if (district.isEmpty) {
          final candidate3 = place.subLocality;
          if (candidate3 != null &&
              candidate3.isNotEmpty &&
              candidate3.toLowerCase() != city.toLowerCase()) {
            district = candidate3;
          }
        }

        return {
          'city': city,
          'district': district,
          'neighborhood': place.subLocality ?? '',
          'full': '',
        };
      }
      return {};
    } catch (_) {
      return {};
    }
  }
}

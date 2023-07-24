import 'package:geolocator/geolocator.dart';

class LatLong {
  final double lat;
  final double long;

  const LatLong({
    required this.lat,
    required this.long,
  });
}

LatLong userPosition = const LatLong(lat: 0, long: 0);

abstract class AppLocation {

  Future<bool> checkPermission();

  Future<bool> requestPermission();

  Future<LatLong> getCurrentLocation();

}

// Сервис геолокаций.
class LocationService implements AppLocation {
  /// Получение текущей гео.
  @override
  Future<LatLong> getCurrentLocation() async {
    return Geolocator.getCurrentPosition().then((value) {
      return LatLong(lat: value.latitude, long: value.longitude);
    });
  }

  /// Отправить запрос на разрешение получения гео.
  @override
  Future<bool> requestPermission() {
    return Geolocator.requestPermission()
        .then((value) =>
    value == LocationPermission.always ||
        value == LocationPermission.whileInUse)
        .catchError((_) => false);
  }

  /// Проверка разрешения.
  @override
  Future<bool> checkPermission() {
    return Geolocator.checkPermission()
        .then((value) =>
    value == LocationPermission.always ||
        value == LocationPermission.whileInUse)
        .catchError((_) => false);
  }
}


Future<void> initPermission() async {
  if (!await LocationService().checkPermission()) {
    await LocationService().requestPermission();
  }
  await fetchCurrentLocation();
}

/// Поиск местоположения
Future<void> fetchCurrentLocation() async {
  LatLong location;

  location = await LocationService().getCurrentLocation();

  userPosition = LatLong(
    lat: location.lat,
    long: location.long,
  );

}

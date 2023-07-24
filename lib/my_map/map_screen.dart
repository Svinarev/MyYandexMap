import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'geolocation.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    initPermission().ignore();
    Timer(const Duration(seconds: 1), () {
      _moveToCurrentLocation(userPosition).ignore();
    });
  }

  // Менюшка.
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Контроллер от Yandex map SDK.
  final mapControllerCompleter = Completer<YandexMapController>();
  late YandexMapController _controller;

  // Объекты на карте.
  final List<MapObject> mapObjects = [];

  // Поинты.
  List<Point> listPoints = [];

  // Маршруты.
  final List<DrivingSessionResult> results = [];
  late DrivingSessionResult result;
  late DrivingSession session;


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(onPressed: _zoomIn,
              child: const Icon(Icons.add)),
          const SizedBox(height: 10.0),
          FloatingActionButton(onPressed: _zoomOut
              ,child: const Icon(Icons.remove)),
          const SizedBox(height: 10.0),
          FloatingActionButton(onPressed: () async{
            _moveToCurrentLocation(userPosition);
          },child: const Icon(Icons.location_on_outlined)),
          const SizedBox(height: 30.0),
        ],
      ),
      key: scaffoldKey,
      body: Builder(
          builder: (context) {
            return Stack(
              children: <Widget>[
                YandexMap(
                  nightModeEnabled: false,
                  logoAlignment: const MapAlignment(horizontal: HorizontalAlignment.right, vertical: VerticalAlignment.top),
                  onMapTap: (Point point) {

                  },
                  onMapCreated: (controller) async {
                    _controller = controller;
                    mapControllerCompleter.complete(controller);
                    await controller.toggleUserLayer(visible: true, autoZoomEnabled: true);
                  },
                  mapObjects: mapObjects,
                  onUserLocationAdded: (UserLocationView view) async {
                    return view.copyWith(
                      // pin: view.pin.copyWith(
                      //   icon: PlacemarkIcon.single(
                      //     PlacemarkIconStyle(image: BitmapDescriptor.fromAssetImage('assets/1.png'), scale: 0.4),
                      //   ),
                      //   opacity: 0.9,
                      // ),
                      arrow: view.arrow.copyWith(
                        icon: PlacemarkIcon.single(
                          PlacemarkIconStyle(image: BitmapDescriptor.fromAssetImage("assets/1.png"), scale: 0.1),
                        ),
                        opacity: 0.6,
                      ),
                      accuracyCircle: view.accuracyCircle.copyWith(
                        fillColor: Colors.blue.withOpacity(0),
                        strokeColor: Colors.blue.withOpacity(0),
                        strokeWidth: 3,
                      ),
                    );
                  },
                ),

              ],
            );
          }
      ),
    );
  }

  /// Метод для показа текущей позиции.
  // ignore: non_constant_identifier_names
  Future<void> _moveToCurrentLocation(LatLong LatLong) async {
    _controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: Point(latitude: LatLong.lat, longitude: LatLong.long),
            zoom: 18
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.linear,
        duration: 1,
      ),
    );
  }

  _zoomIn() async {
    YandexMapController controller = await mapControllerCompleter.future;
    controller.moveCamera(CameraUpdate.zoomIn(),animation: const MapAnimation(duration: 0.5));
  }

  _zoomOut() async{
    YandexMapController controller = await mapControllerCompleter.future;
    controller.moveCamera(CameraUpdate.zoomOut(),animation: const MapAnimation(duration: 0.5));
  }
}

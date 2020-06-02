//
//  MapManager.swift
//  MyPlaces
//
//  Created by Сергей Цыганков on 01.06.2020.
//  Copyright © 2020 Сергей Цыганков. All rights reserved.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private let rigionInMeters = 1000.0
    //массив для хранения массивов маршрутов
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?
    
    func setupPlaceMark(place: Place, mapView: MKMapView) {
        guard let location = place.location else { return }
        //преобразуем координаты (широту/долготу)
        let geocoder = CLGeocoder()
        //определяем положение по адресу
        //тут замыкание, в нем массив, потому что там находится название (названий может быть много)
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            //проверяем на наличие ошибок (впринципе не обязательно, но если появится ошибка, прога сломается)
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            //достаем название (оно первое)
            let placemark = placemarks.first
            
            //данный объект описывает точку на карте
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            //находим локацию нашей точки
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            //выбираем для отображения
            mapView.selectAnnotation(annotation, animated: true)
        }
        
    }
    
    
      //проверяем, включены ли службы геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
          //проверяем, включена ли геолокация
          if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorisation(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
          } else {
              //этот метод позволяет отложить вызов алерта на определенное время
              //который отложен на 1 сек
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                      title: "Location services are disabled",
                      message: "To enable it go: Settings -> Privacy -> Location services and turn on")
              }
          }
      }
    
    //проверяем, разрешил ли пользователь отслеживать свое местопложение
        func checkLocationAutorisation(mapView: MKMapView, segueIdentifier: String) {
           switch CLLocationManager.authorizationStatus() {
           case .authorizedWhenInUse:
               mapView.showsUserLocation = true
               if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
               break
           case .denied:
               DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                       title: "Your location isn't available",
                       message: "To give permission go to: Setting -> MyPlaces -> Location")
               }
               break
           case .notDetermined:
               locationManager.requestWhenInUseAuthorization()
               //Privacy - Location When In Use Usage Description - в инфо создаем еще одну строчку и ищем это (это разъеяснение зачем нам следить за ним)
               break
           case .restricted:
               //contr
               break
           case .authorizedAlways:
               break
           //доп функция (для того, чтоб в будущем, когда появится новый кейс, он автоматически обрабатывался, а не ломал программу
           @unknown default:
               print("New case is available")
           }
       }
    
    
    func showUserLocation(mapView: MKMapView) {
           //проверяем координаты пользователя (если можем их определить)
           if let location = locationManager.location?.coordinate {
               //задаем то, что будем отображать (центр на пользователе и дистанция отображения 1км)
               let region = MKCoordinateRegion(center: location,
                                               latitudinalMeters: rigionInMeters,
                                               longitudinalMeters: rigionInMeters)
               //переводим нашу карту
               mapView.setRegion(region, animated: true)
           }
       }
    
     func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        
        
        
           //определяем текущее местоположение пользователя
           guard let location = locationManager.location?.coordinate else {
               showAlert(title: "Error", message: "Current location isn't found")
               return
           }
           
           //постоянное отслеживание позиции
           locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
           
           guard let request = createDirectionsRequest(from: location) else {
               showAlert(title: "Error", message: "Destination isn't found")
               return
           }
           
//        labelsVC.timeLabel.isHidden = false
//        labelsVC.distanceLabel.isHidden = false
           
           //создаем маршрут
           let directions = MKDirections(request: request)
           
           //удаляем старые маршруты (если вдруг решили поменять его во время движения)
        resetMapView(withNew: directions, mapView: mapView)
           
           //расчет маршрута
           directions.calculate { (response, error) in
               
               if let error = error {
                   print(error)
                   return
               }
               
               guard let response = response else {
                self.showAlert(title: "Error", message: "Directions isn't available")
                   return
               }
               //делаем перебор возможных маршрутов
               for route in response.routes {
                   //добавляем геометрию всего маршрута
                   mapView.addOverlay(route.polyline)
                   //делаем видимым на экране как точку старта так и финиша
                   mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                   //расстояние между точками
                   let distance = String(format: "%.1f", route.distance / 1000)
                   //время пути (в сек)
                   let timeInterval = round(route.expectedTravelTime / 60)
                   
//                labelsVC.distanceLabel.text = "Distance to position is: \(distance) km."
//                labelsVC.timeLabel.text = "Driving time is: \(timeInterval) min."
                   print("Distance to position is: \(distance) km.")
                   print("Driving time is: \(timeInterval) min.")
                   
               }
           }
           
       }
    
    
    //если сможем определить координаты нашей цели, то запрос вернем, поэтому опциональный возврат
       func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
           
           guard let destinationCoordinate = placeCoordinate else { return nil }
           
           //точка начала маршрута
           let startingLocation = MKPlacemark(coordinate: coordinate)
           //точка конца маршрута
           let destination = MKPlacemark(coordinate: destinationCoordinate)
           
           let request = MKDirections.Request()
           //стартовая точка
           request.source = MKMapItem(placemark: startingLocation)
           request.destination = MKMapItem(placemark: destination)
           //средсво передвижения
           request.transportType = .automobile
           //строим несколько маршрутов, если есть альтернативные варианты
           request.requestsAlternateRoutes = true
           
           return request
       }
    
    
       // отслеживаем движение пользователя
     func startTractingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
           
           guard let location = location else {return}
           let center = getCenterLocation(for: mapView)
           //если расстояние от текущей области до пользователя больше 50 метров, то смещаем экран
           guard center.distance(from: location)  > 50 else { return }
          
          closure(center)
        }
      
    

        //определяем центр пина, чтоб из него (координаты) доставать инфу
       func getCenterLocation(for mapView: MKMapView) -> CLLocation {
            //наши координаты
            let latitude = mapView.centerCoordinate.latitude
            let longitude = mapView.centerCoordinate.longitude
            
            return CLLocation(latitude: latitude, longitude: longitude)
        }
        
    
    
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
           //удаляем прдедыущеие маршруты (сели мы пересоздаем новый, и они не накладывались друг на друга)
           mapView.removeOverlays(mapView.overlays)
           directionsArray.append(directions)
           //отменяем все маршруты
           let _ = directionsArray.map { $0.cancel() }
           directionsArray.removeAll()
       }
    
   private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        //тут создается окно, которое будет поверх нашего и будет постоянно показывать ошибки (чтоб можно было отсюда вызвать его на наш контроллер, необходимо создать окно-контроллер)
        //создаем объект окно, который будет поверх нашего окна
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController!.present(alert, animated: true)
    }
    
    
}

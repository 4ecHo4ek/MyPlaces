//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Сергей Цыганков on 01.06.2020.
//  Copyright © 2020 Сергей Цыганков. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    
    //уникальный идентификатор
    var annotationIdentifier = "annotationIdentifier"
    //менеджер по работе с геолокацией
    var incomeSegueIdentifier = ""
   
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTractingUserLocation(for: mapView, and: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
        @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
      @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
  
    
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
  
    @IBAction func closeMap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupMapView()
        addressLabel.text = ""
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        distanceLabel.isHidden = true
        timeLabel.isHidden = true
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlaceMark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
}
   
    

//делаем кастомный баннер для аннотации

extension MapViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //определяем что маркер не текущее положение пользователя
        guard !(annotation is MKUserLocation) else { return nil }
        
        //переиспользуем ранее использованные аннотации (так выгодней)
        //приводим к данному виду, чтоб не потерять форму маркера (а то будет только текст на карте)
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        //если еще нет ни одной аннотации (баннера на карте), то создаем
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        //проверяем наличие фото
        if let imageData = place.imageData {
            //делаем фото для баннера
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            //обрезаем границы
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            //размещаем наш баннер
            annotationView?.rightCalloutAccessoryView = imageView
            
        }
        
        return annotationView
    }
    
    //данный метод вызывается каждый раз при смене отображаемого региона
    internal func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        //что то отчищает
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            //находим название улицы
            let streetName = placemark?.thoroughfare
            //номер дома
            let buildNamber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNamber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNamber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    //делаем разные маршруты разными цветами
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .green
        return render
    }
}

//расширение для моментального отслеживания пользователя
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAutorisation(mapView: mapView, segueIdentifier: incomeSegueIdentifier)
    }
}

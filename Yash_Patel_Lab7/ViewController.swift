import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var cSpeedLabel: UILabel!
    @IBOutlet weak var mSpeedLabel: UILabel!
    @IBOutlet weak var aSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var maxAcceleration: UILabel!
    
    var locationManager: CLLocationManager!
    var startLocation: CLLocation?
    var lastLocation: CLLocation?
    var maxSpeed: CLLocationSpeed = 0.0
    var distance: CLLocationDistance = 0.0
    var acceleration: CLLocationSpeed = 0.0
    var tripStartTime: Date?
    var tripEndTime: Date?
    var totalSpeed: CLLocationSpeed = 0.0
    var speedReadings: Int = 0
    var isUpdatingLocation: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    @IBAction func startTripAction(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        tripStartTime = Date()
        redView.backgroundColor = .red
        greenView.backgroundColor = .green
        myMap.showsUserLocation = true
        myMap.setUserTrackingMode(.follow, animated: true)
        isUpdatingLocation = true
    }
    
    @IBAction func stopTripAction(_ sender: UIButton) {
        locationManager.stopUpdatingLocation()
        tripEndTime = Date()
        redView.backgroundColor = .red
        greenView.backgroundColor = .green
        redView.alpha = 1
        greenView.alpha = 1
        cSpeedLabel.text = "0.00 km/h"
        mSpeedLabel.text = "0.00 km/h"
        aSpeedLabel.text = "0.00 km/h"
        distanceLabel.text = "0.00 km"
        maxAcceleration.text = "0.00 m/s²"
        myMap.showsUserLocation = false
        myMap.setUserTrackingMode(.none, animated: true)
        isUpdatingLocation = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isUpdatingLocation, let liveLocation = locations.last else { return }
        
        let currentSpeed = liveLocation.speed
        cSpeedLabel.text = String(format: "%.1f km/h", abs(currentSpeed) * 3.6)
        if(abs(currentSpeed)*3.6) >= 120{
            redView.alpha = 1
            greenView.alpha = 0
                        }else{
                            redView.alpha = 0
                            greenView.alpha = 1
                        }
        
        if currentSpeed > maxSpeed {
            maxSpeed = currentSpeed
            mSpeedLabel.text = String(format: "%.1f km/h", abs(maxSpeed) * 3.6)
        }
        
        totalSpeed += currentSpeed
        speedReadings += 1
        let averageSpeed = totalSpeed / Double(speedReadings)
        aSpeedLabel.text = String(format: "%.1f km/h", abs(averageSpeed) * 3.6)
        
        if let lastLocation = lastLocation {
            let distanceIncrement = liveLocation.distance(from: lastLocation)
            distance += distanceIncrement
            distanceLabel.text = String(format: "%.2f km", distance / 1000)
            
            let timeIncrement = liveLocation.timestamp.timeIntervalSince(lastLocation.timestamp)
            acceleration = (currentSpeed - lastLocation.speed) / timeIncrement
            maxAcceleration.text = String(format: "%.1f m/s²", abs(acceleration))
        }
        
        lastLocation = liveLocation
        myMap.setCenter(liveLocation.coordinate, animated: true)
        let region = MKCoordinateRegion(center: liveLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        myMap.setRegion(region, animated: true)
    }
    
    func calculateDistanceToExceedSpeedLimit() -> CLLocationDistance {
        let speedLimit = 115.0 // km/h
        let averageSpeed = totalSpeed / Double(speedReadings)
        let timeToExceedLimit = (speedLimit / (averageSpeed * 3.6))
        let distanceToExceedLimit = timeToExceedLimit * maxSpeed * 3.6 * 1000
        return distanceToExceedLimit
    }
}

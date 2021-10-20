//
//  ViewController.swift
//  ChenXiaoLiu-Lab1
//
//  Created by lcx on 2021/9/12.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var originalPrice: UITextField!
    @IBOutlet weak var discount: UITextField!
    @IBOutlet weak var tax: UITextField!
    @IBOutlet weak var finalPrice: UILabel!
    @IBOutlet weak var originalPriceError: UILabel!
    @IBOutlet weak var discountError: UILabel!
    @IBOutlet weak var taxError: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var finalPriceLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet weak var discountButton: UIButton!
    @IBOutlet weak var taxButton: UIButton!
    @IBOutlet weak var location: UILabel!
    
    let locationManager = CLLocationManager()
    
    var values = [0.0, 0.0, 0.0]
    // values[0] = original price
    // values[1] = discount
    // values[2] = tax
    
    // Found at https://taxfoundation.org/2021-sales-taxes/
    let taxes = [
        "AL": 9.22, "AK": 1.76, "AZ": 8.4, "AR": 9.51, "CA": 8.68,
        "CO": 7.72, "CT": 6.35, "DE": 0, "FL": 7.08, "GA": 7.32,
        "HI": 4.44, "ID": 6.03, "IL": 8.82, "IN": 7.00, "IA": 6.94,
        "KS": 8.69, "KY": 6.00, "LA": 9.52, "ME": 5.50, "MD": 6.00,
        "MA": 6.25, "MI": 6.00, "MN": 7.46, "MS": 7.07, "MO": 8.25,
        "MT": 0.00, "NE": 6.94, "NV": 8.23, "NH": 0.00, "NJ": 6.60,
        "NM": 7.83, "NY": 8.52, "NC": 8.52, "ND": 6.96, "OH": 7.23,
        "OK": 8.95, "OR": 0.00, "PA": 6.34, "RI": 7.00, "SC": 7.46,
        "SD": 6.40, "TN": 9.55, "TX": 8.19, "UT": 7.19, "VT": 6.24,
        "VA": 5.73, "WA": 9.23, "WV": 6.50, "WI": 5.43, "WY": 5.33,
        "DC": 6.00
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestWhenInUseAuthorization()
        
        // Learned from https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        header.text = "My Shopping Calculator".localized()
        priceLabel.text = "Original Price".localized()
        discountLabel.text = "Discount".localized() + " %"
        taxLabel.text = "Sales Tax".localized() + " %"
        finalPriceLabel.text = "Final Price".localized()
        priceButton.setTitle("Clear".localized(), for: .normal)
        discountButton.setTitle("Clear".localized(), for: .normal)
        taxButton.setTitle("Clear".localized(), for: .normal)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(
            locations[0],
            completionHandler: { (placemarks, error) in
                if error == nil {
                    if let state = placemarks![0].administrativeArea {
                        if let stateTax = self.taxes[state] {
                            self.location.text = "Location".localized() + ": \(state)"
                            self.tax.text = String(stateTax)
                            self.updateFinalPrice(self.tax, 2, self.taxError)
                            return
                        }
                    }
                }
                self.location.text = "Location".localized() + ": " + "Outside the USA".localized()
                self.tax.text = ""
                self.updateFinalPrice(self.tax, 2, self.taxError)
            }
        )
    }
    
    @IBAction func originalPriceUpdated(_ sender: Any) {
        updateFinalPrice(originalPrice, 0, originalPriceError)
    }
    
    @IBAction func discountUpdated(_ sender: Any) {
        updateFinalPrice(discount, 1, discountError)
    }
    
    @IBAction func taxUpdated(_ sender: Any) {
        updateFinalPrice(tax, 2, taxError)
    }
    
    func getInputOrDefault (_ str: String?) -> Double {
        if str == "" {
            return 0;
        }
        if let input = Double(str!) {
            if input >= 0 {
                return input
            }
        }
        return -1
    }
    
    func updateFinalPrice (_ textField: UITextField, _ index: Int, _ errorLabel: UILabel) -> () {
        let input = getInputOrDefault(textField.text)
        if input != -1 {
            errorLabel.text = ""
            values[index] = input
            finalPrice.text = String(
                format: "%.2f",
                values[0] * (100 - values[1]) / 100 * (1 + values[2] / 100)
            )
        } else {
            errorLabel.text = "Invalid Input!".localized()
            finalPrice.text = "-"
        }
    }
    
    @IBAction func originalPriceClearButtonPressed(_ sender: Any) {
        originalPrice.text = ""
        updateFinalPrice(originalPrice, 0, originalPriceError)
    }
    
    @IBAction func discountClearButtonPressed(_ sender: Any) {
        discount.text = ""
        updateFinalPrice(discount, 1, discountError)
    }
    
    @IBAction func taxClearButtonPressed(_ sender: Any) {
        tax.text = ""
        updateFinalPrice(tax, 2, taxError)
    }
}

// Learned from https://www.youtube.com/watch?v=WSI_LS3Yq8I&t=611s
extension String {
    func localized () -> String {
        return NSLocalizedString(
            self,
            tableName: "Localization",
            bundle: .main,
            value: self,
            comment: self
        )
    }
}

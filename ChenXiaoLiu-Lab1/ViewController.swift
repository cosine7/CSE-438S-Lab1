//
//  ViewController.swift
//  ChenXiaoLiu-Lab1
//
//  Created by lcx on 2021/9/12.
//

import UIKit
import CoreLocation
import MapKit

struct Pair {
    let textField: UITextField
    let error: UILabel
}

enum Input: String {
    case originalPrice = "originalPrice"
    case discount = "discount"
    case tax = "tax"
}

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
    
    private var item = [Input:Pair]()

    override func viewDidLoad() {
        super.viewDidLoad()
        item = [
            .originalPrice: Pair(textField: originalPrice, error: originalPriceError),
            .discount: Pair(textField: discount, error: discountError),
            .tax: Pair(textField: tax, error: taxError)
        ]
        self.locationManager.requestWhenInUseAuthorization()
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
                guard error == nil,
                      let state = placemarks?[0].administrativeArea,
                      let stateTax = self.taxes[state]
                else {
                    self.updateLocationAndTax()
                    return
                }
                self.updateLocationAndTax("Location".localized() + ": \(state)", String(stateTax))
            }
        )
    }
    
    private func updateLocationAndTax(
        _ locationText: String = "Location".localized() + ": " + "Outside the USA".localized(),
        _ taxText: String = ""
    ) {
        location.text = locationText
        tax.text = taxText
        textDidChange(tax)
    }
    
    @IBAction func textDidChange(_ sender: UITextField) {
        var isValidInput = true
        for (key, value) in item {
            if value.textField.hasText {
                if !value.textField.isValid() {
                    value.error.text = "Invalid Input!".localized()
                    isValidInput = false
                }
            } else {
                value.error.text = ""
                if key == .originalPrice {
                    isValidInput = false
                }
            }
        }
        finalPrice.text = isValidInput
        ? String(
            format: "%.2f",
            originalPrice.toDouble() * (100 - discount.toDouble()) / 100 * (1 + tax.toDouble() / 100)
        )
        : "-"
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        guard let id = sender.restorationIdentifier,
              let key = Input(rawValue: id),
              let item = self.item[key]
        else {
            return
        }
        item.textField.text = ""
        textDidChange(item.textField)
    }
}

// Learned from https://www.youtube.com/watch?v=WSI_LS3Yq8I&t=611s
extension String {
    func localized() -> String {
        return NSLocalizedString(
            self,
            tableName: "Localization",
            bundle: .main,
            value: self,
            comment: self
        )
    }
}

extension UITextField {
    func toDouble() -> Double {
        guard let text = self.text,
              let num = Double(text)
        else {
            return -1
        }
        return num
    }
    
    func isValid() -> Bool {
        return self.toDouble() > 0
    }
}

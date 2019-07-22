//
//  RequestController.swift
//  Poketto
//
//  Created by André Sousa on 23/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import Presentr

class RequestController: UIViewController, PresentrDelegate {
    
    var address                         : String!
    @IBOutlet weak var addressLabel     : UILabel!
    @IBOutlet weak var qrCodeImageView  : UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.cornerRadius = 25
        navigationController?.navigationBar.layer.cornerRadius = 25
        navigationController?.navigationBar.clipsToBounds = true
        
        addressLabel.text = address

        // Get data from the string
        let data = address.data(using: String.Encoding.ascii)
        // Get a QR CIFilter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return }
        // Input the data
        qrFilter.setValue(data, forKey: "inputMessage")
        // Get the output image
        guard let qrImage = qrFilter.outputImage else { return }
        // Scale the image
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        // Replace the black with transparency
        guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else { return }
        maskToAlphaFilter.setValue(scaledQrImage, forKey: "inputImage")
        guard let outputCIImage = maskToAlphaFilter.outputImage else { return }
        // Do some processing to get the UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return }
        let processedImage = UIImage(cgImage: cgImage)
        
        qrCodeImageView.image = processedImage
    }
    
    @IBAction func dismiss() {
        
        AppDelegate.shared.removeBackgroundBlur()
        dismiss(animated: true, completion: nil)
    }
    
    func copyToClipboard() {
        
        UIPasteboard.general.string = address
        AppDelegate.shared.removeBackgroundBlur()
        dismiss(animated: true, completion: nil)
    }
    
    func share() {
        
        let items = [address]
        let ac = UIActivityViewController(activityItems: items as! [String], applicationActivities: nil)
        present(ac, animated: true)
    }
    
    func presentrShouldDismiss(keyboardShowing: Bool) -> Bool {
        AppDelegate.shared.removeBackgroundBlur()
        return true
    }
}

class RequestTableController : UITableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 { // copy to clipboard
            (self.parent as! RequestController).copyToClipboard()
        } else { // share
            (self.parent as! RequestController).share()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//
//  NearbyPlacesTVC.swift
//  Current Location
//
//  Created by AdBox on 7/18/17.
//  Copyright © 2017 myth. All rights reserved.
//

import UIKit
import GooglePlaces

class NearbyPlacesTVC: UITableViewController {
    
    // nearby placess array
    var places : [GMSPlace] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unwindSegueViewOnMap" {
        
            let vc = segue.destination as! ViewController
            // set selected place
            vc.selectedLocation = places[(tableView.indexPathForSelectedRow?.row)!]
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = places[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Address", message: places[indexPath.row].formattedAddress, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "View on map", style: .default, handler: { (action) in
            
            self.viewOnMap()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func viewOnMap() {
    
        performSegue(withIdentifier: "unwindSegueViewOnMap", sender: self)
    }
}

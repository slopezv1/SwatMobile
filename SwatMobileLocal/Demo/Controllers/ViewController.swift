//
//  ViewController.swift
//  Demo
//
//  Created by Saul  Lopez-Valdez on 3/25/20.
//  Copyright © 2020 Saul  Lopez-Valdez. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    //table view for holding cells that will function as buttons that will segue into the other additionbal views when pressed
    @IBOutlet weak var homeTableView: UITableView!
    
    //spinner that runs until the eventArr is filled
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        
        //setting up swarthmore logo to be displayed in navigation bar
        let swarthmoreLogo = UIImage(named: "swarthmore_logo")
        navigationItem.titleView = UIImageView(image: swarthmoreLogo)
        navigationItem.titleView?.layer.cornerRadius = 15
        navigationItem.titleView?.layer.masksToBounds = true
        
        
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.row == 0{
            performSegue(withIdentifier: "goToWelcome", sender: self)
        }
        else if indexPath.row == 1{
            performSegue(withIdentifier: "goToSharples", sender: self)
        }
        else if indexPath.row == 2{
            performSegue(withIdentifier: "goToEvents", sender: self)
        }
        
        homeTableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
         return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //tableViewCell is no longer a default prototype, but is of the class we created -> eventTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "homePageCell", for: indexPath) as! eventTableViewCell
        
        if indexPath.row == 0{
            cell.cellTextLabel.text = "Welcome"
            let image =  UIImage(named: "WelcomeCell")
            cell.cellImage.image = image!
            cell.roundImage()
        }
        else if indexPath.row == 1{
            cell.cellTextLabel.text = "Sharples"
            let image =  UIImage(named: "sharplesCell")
            cell.cellImage.image = image!
            cell.roundImage()
        }
        else if indexPath.row == 2{
            cell.cellTextLabel.text = "Events"
            let image =  UIImage(named: "EventCell")
            cell.cellImage.image = image!
            cell.roundImage()
        }
        
        
        
        return cell
    }
}

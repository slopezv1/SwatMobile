//
//  WelcomeViewController.swift
//  Demo
//
//  Created by Julian Gonzalez on 4/24/20.
//  Copyright © 2020 Saul  Lopez-Valdez. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var TableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        TableView.delegate = self
        TableView.dataSource = self
        
    }

}

extension WelcomeViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("Tapped Welcome Message")
    }
}

extension WelcomeViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //return 1 since there will only be one row opulated by the welcome message
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WelcomeMessage", for: indexPath) as! eventTableViewCell
        
        cell.roundImage()
        cell.cellTextLabel.text = "Hello"
        cell.cellTimeLabel.text = ""
        
        return cell
        
    }
}

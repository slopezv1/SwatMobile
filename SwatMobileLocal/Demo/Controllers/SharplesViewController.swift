//
//  SharplesViewController.swift
//  Demo
//
//  Created by Saul  Lopez-Valdez on 4/24/20.
//  Copyright © 2020 Saul  Lopez-Valdez. All rights reserved.
//

import UIKit
import MessageUI
import EventKit

class SharplesViewController: UIViewController {
    
    @IBOutlet weak var SharplesTable: UITableView!
    @IBOutlet weak var dateDisplay: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    
    var sharplesData: sharplesDayData = sharplesDayData(calData: [dayFormatter(selected_date: Date()):dayMeals(events: [meals(title: "Loading", body: "...")])])
    
    var jsonFlag: Bool = false
    var day: Date = Date()
    //forward and backward vars to avoid accessing sharples data that does not exist
    var forward: Int = 0
    var backward: Int = 0
    
    //variables to construct message for shareSharplesController
    var message: String = ""
    
    //datPicker
    let datePicker = UIDatePicker()
    
    //formatting current day information to index into sharples meaal data
    
    //function that parses a GET http json request and loads the parsed data into a struct sharples data object
    func parseSharplesJSON(){

        let init_url = "https://dash.swarthmore.edu/calendarapi/1768/month.json"

        guard let url = URL(string: init_url) else { return }

        let session = URLSession.shared
        let dataTask = session.dataTask(with:url){ (data, response, error) in
            //check for errors
            if error == nil && data != nil{

                //parse JSON data
                let decoder = JSONDecoder()

                do {
                    let dataArr = try decoder.decode(sharplesDayData.self, from: data!)
                    print("In JSON Parser for Sharples data: \(dataArr)")
                    self.sharplesData = dataArr
                    self.jsonFlag = true
                    
                }
                catch{
                    print(error)
                }

            }
        }
        dataTask.resume()
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        //creating date picker to be in the text field
        createDatePickerSharples()

        // Do any additional setup after loading the view.
        SharplesTable.delegate = self
        SharplesTable.dataSource = self
        
        //setting up swarthmore logo to be displayed in navigation bar and configuring some other display objects
        let swarthmoreLogo = UIImage(named: "swarthmore_logo")
        navigationItem.titleView = UIImageView(image: swarthmoreLogo)
        navigationItem.titleView?.layer.cornerRadius = 15
        navigationItem.titleView?.layer.masksToBounds = true
        
        //button config
        nextButton.layer.cornerRadius = 15
        nextButton.layer.masksToBounds = true
        prevButton.layer.cornerRadius = 15
        prevButton.layer.masksToBounds = true
        
        //parsing and loading sharples json information
        parseSharplesJSON()
        while !jsonFlag{
        //keep looping until the json parser is finished
        //we know the parser is finished once the default values of sharplesData have been updated and the jsonFlag variable has been set to true, which is what the while statement condition verifies
        }

    }
    //creating the alert that will pop up to confirm wether the user wants to invite a friend to a given meal at sharples
    func createAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            //if yes is tapped, allow user to compose a message that invites a friend to the given meal
            if MFMessageComposeViewController.canSendText(){
                let messageVC = MFMessageComposeViewController()
                       
                messageVC.body = self.message
                messageVC.recipients = ["Swattie"]
                messageVC.messageComposeDelegate = self
                       
                self.present(messageVC, animated: true, completion: nil)
            }
            else{
                print("Message could not be sent")
            }

        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (action) in
            //if no is tapped, we just simply dismiss the alert
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //action performed when next button is pressed
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        if self.forward<10{
            self.day = addToDate(selected_date: day, days_to_add: 1)
            self.dateDisplay.text = dateDisplayFormatter(selected_date: self.day)
            datePicker.date = day
            
            self.forward+=1
            self.backward-=1
            
            SharplesTable.reloadData()
        }
    }
    
    //action performed when prev button is pressed
    @IBAction func prevButtonPressed(_ sender: Any) {
        if self.backward<10{
            self.day = subToDate(selected_date: day, days_to_sub: -1)
            self.dateDisplay.text = dateDisplayFormatter(selected_date: self.day)
            datePicker.date = day
            
            self.backward+=1
            self.forward-=1
            
            SharplesTable.reloadData()
        }
    }
    
    func createDatePickerSharples() {
        
        //aligning the text in the text field
        //display text configuring
        dateDisplay.textAlignment = .center
        dateDisplay.font = UIFont(name: "System", size: 25)
        dateDisplay.text = dateDisplayFormatter(selected_date: day)
        
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedSharples))
        //adding done button to toolbar
        toolbar.setItems([doneBtn], animated: true)
        
        //assign toolbar
        dateDisplay.inputAccessoryView = toolbar
        
        //assign datePicker to the text field
        dateDisplay.inputView = datePicker
        
        //date picker mode set to only show month, day, and year
        datePicker.datePickerMode = .date
        
        
        //setting the max and min dates
        datePicker.maximumDate = addToDate(selected_date: day, days_to_add: 10)
        datePicker.minimumDate = subToDate(selected_date: day, days_to_sub: -10)
        
    }
    
    @objc func donePressedSharples(){

        dateDisplay.text = dateDisplayFormatter(selected_date: datePicker.date)

        //closing off the text field for editing, hecne collapsing the date picker
        self.view.endEditing(true)
        
        //call function here that updates the contents of eventsArray to represent the events of the indicated date by the user.
        self.day = datePicker.date
        //this tableView method reloads the data in the TableView
        
        SharplesTable.reloadData()
    }
}

// --MARK Setting up SharplesTable UITableView configuration for loading in data into the UITableViewCells

extension SharplesViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        //extracting sharples meal information
        let mealTitle = (self.sharplesData.calData![dayFormatter(selected_date: self.day)]?.events![indexPath.row].title)!.htmlStripped.htmlStripped2()
        let mealContent = (self.sharplesData.calData![dayFormatter(selected_date: self.day)]?.events![indexPath.row].body)!.htmlStripped.htmlStripped2()
        
        //--updating message
        //if the selected date is equal to the current date
        if dateDisplayFormatter(selected_date: day) == dateDisplayFormatter(selected_date: Date()){
            message = "Hey, want to go to \(mealTitle) at Sharples today? The menu is: \(mealContent)"
        }
        //if the selected date is equal to tomorrow's date
        else if dateDisplayFormatter(selected_date: day) == dateDisplayFormatter(selected_date: addToDate(selected_date: Date(), days_to_add: 1)){
            message = "Hey, want to go to \(mealTitle) at Sharples tomorrow? The menu is: \(mealContent)"
        }
        else{
            message = "Hey, want to go to \(mealTitle) at Sharples on \(dateDisplayFormatter(selected_date: day))? The menu is: \(mealContent)"
        }
        //creating and presenting the alert
        createAlert(title: "Invite Friend", message: "Are you sure you want to invite a friend to this meal? ")
        //deselcting row
        SharplesTable.deselectRow(at: indexPath, animated: true)
    }
}
extension SharplesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //returning the number of meals contained in the given day. This way, the tableView knows how many cells to create
        return (self.sharplesData.calData![dayFormatter(selected_date: self.day)]?.events?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Meal Cell", for: indexPath) as! eventTableViewCell
        
        let mealTitle = (self.sharplesData.calData![dayFormatter(selected_date: self.day)]?.events![indexPath.row].title)!.htmlStripped.htmlStripped2()
        let mealContent = (self.sharplesData.calData![dayFormatter(selected_date: self.day)]?.events![indexPath.row].body)!.htmlStripped.htmlStripped2()
        
        
        cell.roundImage()
        cell.cellTextLabel.text = mealTitle
        cell.cellTimeLabel.text = mealContent
        
        
        return cell
    }
}

//-- end MARK

//-- Helper Functions--

//helper function that takes in the current day information as a date object and returns it formatted in a string. Helps index into sharples information
func dayFormatter(selected_date: Date)->String{
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: selected_date) + " 00:00:00"
    
}

func addToDate(selected_date: Date, days_to_add: Int)->Date{
    let daysToAdd = days_to_add
    var dateComponents = DateComponents()
    dateComponents.day = daysToAdd
    let futureDate = Calendar.current.date(byAdding: dateComponents, to: selected_date)
    return futureDate!
}

func subToDate(selected_date: Date, days_to_sub: Int)->Date{
    let daysToAdd = days_to_sub
    var dateComponents = DateComponents()
    dateComponents.day = daysToAdd
    let futureDate = Calendar.current.date(byAdding: dateComponents, to: selected_date)
    return futureDate!
}

func dateDisplayFormatter(selected_date: Date)->String{
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: selected_date)
}

//--MARK This section of code is for incorporating the iMessage UI to allow the user to invite a friend to a given sharples meal
extension SharplesViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("Message was cancelled")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("Mmessage failed")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("Message sent")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}

//The following is code for creating the alert that will confirm wether the user wanta to invite a friend or not


//
//  ViewController.swift
//  MealTime
//
//  Created by Ivan Akulov on 10/11/16.
//  Copyright © 2016 Ivan Akulov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {
  
  var context: NSManagedObjectContext!
  var person: Person!
  
  @IBOutlet weak var tableView: UITableView!
  var array = [Date]()
  
  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
    let defaultName = "Anton"
    let personRequest: NSFetchRequest<Person> = Person.fetchRequest()
    
    personRequest.predicate = NSPredicate(format: "name == %@", defaultName)
    
    do {
      let results = try context.fetch(personRequest)
      if results.isEmpty {
        person = Person(context: context)
        person.name = defaultName
      } else {
        person = results[0]
      }
    } catch let error as NSError {
      print(error.userInfo)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "My happy meal time"
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let meals = person.meals else { return 1 }
    
    return meals.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
    
    guard let meal = person.meals?[indexPath.row] as? Meal,
          let mealDate = meal.date as Date? else {
      return cell!
    }
    
    cell!.textLabel!.text = dateFormatter.string(from: mealDate)
    return cell!
  }
  
  @IBAction func addButtonPressed(_ sender: AnyObject) {
    let meal = Meal(context: context)
    meal.date = NSDate()
    
    // Т.к. изначально person.meals уже содержит данные, мы не можем его напрямую изменять, нужно создать комию и работать с ней
    let meals = person.meals?.mutableCopy() as? NSMutableOrderedSet
    meals?.add(meal)
    
    person.meals = meals
    
    do {
      try context.save()
    } catch let error as NSError {
      print("Error: \(error), userInfo \(error.userInfo)")
    }
    
    tableView.reloadData()
  }
  
}


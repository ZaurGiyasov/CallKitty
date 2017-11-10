//
//  LongTableViewController.swift
//  CallKitty
//
//  Created by Steve Baker on 11/10/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//
//  Reference: https://github.com/beepscore/LongTable

import UIKit
import RealmSwift

class LongTableViewController: UITableViewController {

    let realmService = RealmService.shared
    var results: Results<PhoneCaller>?
    var notificationToken: NotificationToken?

    var numSections = 1

    /// activeTextField may be in any row, not necessarily the currently selected row
    //var activeTextField: UITextField?

    // MARK: - view lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Long Table"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // call observeResults here instead of in viewDidLoad, because viewWillDisappear stops observing
        observeResults()
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // stop update notifications. stop was renamed to invalidate
        notificationToken?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: -

    func observeResults() {
        results = realmService.realm.objects(PhoneCaller.self).sorted(byKeyPath: PhoneCaller.PropertyStrings.phoneNumber.rawValue)

        // Set results notification block
        // block is called every time the realm collection changes
        // use capture list [weak self] to avoid potential retain cycles
        notificationToken = results?.observe { [weak self] (changes: RealmCollectionChange) in
            // Swift switch cases don't implicitly fall through, don't need break
            // https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/ControlFlow.html
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self?.tableView.reloadData()
            case .update(_, _, _, _):
                self?.tableView.reloadData()
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return numSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let results = results else { return 0 }
        return results.count / numSections
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var titles = [String]()
        for section in 0..<numSections {
            titles.append("\(self.tableView(tableView, numberOfRowsInSection: section) * section)")
        }
        return titles
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PhoneCallerCell

        guard let results = results else { return cell }

        let index = itemIndex(indexPath: indexPath)
        let phoneCaller = results[index]

        cell.nameLabel.text = String(phoneCaller.phoneNumber)
        cell.noteField.text = phoneCaller.label

        // use tag to enable textField delegate methods to know row
        cell.noteField.tag = index

        // set background color for diagnostics during development
        if phoneCaller.shouldBlock {
            cell.backgroundColor = UIColor( red: 1.0, green: CGFloat(220/255.0), blue: CGFloat(220/255.0), alpha: 1.0 )
        } else {
            cell.backgroundColor = .white
        }

        return cell
    }

    /// for generality, handles sections of differing lengths
    func itemIndex(indexPath: IndexPath) -> Int {

        var index: Int = 0
        if indexPath.section > 0 {
            // in previous sections, add all rows in section
            for section in 0..<indexPath.section {
                index += tableView(tableView, numberOfRowsInSection: section)
            }
        }

        // in current section, add rows up to current row
        index += indexPath.row

        return index
    }

}

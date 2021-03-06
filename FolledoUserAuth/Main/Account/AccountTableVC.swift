//
//  AccountTableVC.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

class AccountTableVC: UITableViewController {
    
//MARK: Properties
    var cellData: [CellData] = [CellData]()
    let cellID: String = "accountCellID"
    var rows = 0
//    var profileImage: UIImage?
    
//MARK: IBOutlets
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createDataCell()
        self.tableView.register(AccountCell.self, forCellReuseIdentifier: cellID)
        self.tableView.rowHeight = UITableView.automaticDimension //but we still have to automatically make them resize to the contents inside of it
        self.tableView.estimatedRowHeight = 100 //to make the cell have a limit and save memory //now in cellForRowAt layoutSubviews()
        tableView.tableFooterView = UIView() //remove the additional line separator underneath our products
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
//MARK: Methods
    func insertRowMode3(row: Int, cell: CellData, completion: @escaping ()-> Void) { //cell animation
        let indexPath = IndexPath(row: row, section: 0)
        cellData.append(cell)
        tableView.insertRows(at: [indexPath], with: .right)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion()
        }
    }
    
//MARK: IBActions
    
//MARK: Helpers
    func createDataCell() {
        //        let url = URL(string: User.currentUser()!.imageUrl)
        //        if let data = try? Data(contentsOf: url!) {
        //            if let image = UIImage(data: data) {
        //                DispatchQueue.main.async {
        guard let imageUrl = User.currentUser()?.imageUrl else { print("User has no image url"); return }
        let loadedImage = loadProfileImage(id: imageUrl)
        guard let profileImage = loadedImage else { print("No profile image"); return }
        let cell1 = CellData.init(cellImage: profileImage, cellTitle: "Profile")
        let cell2 = CellData.init(cellImage: UIImage(named: "SFLogo"), cellTitle: "About")
        let cell3 = CellData.init(cellImage: UIImage(named: "SFLogo"), cellTitle: "Credits")
        let cell4 = CellData.init(cellImage: UIImage(named: "SFLogo"), cellTitle: "Settings")
        let cell5 = CellData.init(cellImage: UIImage(named: "SFLogo"), cellTitle: "Logout")
        self.insertRowMode3(row: 0, cell: cell1) {
            self.insertRowMode3(row: 1, cell: cell2) {
                self.insertRowMode3(row: 2, cell: cell3) {
                    self.insertRowMode3(row: 3, cell: cell4) {
                        self.insertRowMode3(row: 4, cell: cell5) {
                            print("Done inserting rows")
                        }
                    }
                }
            }
        }
        //                }
        //            }
        //        }
    }
    
//didSelectRow
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("Profile coming soon")
        case 1:
            print("About coming soon")
        case 2:
            print("Credits coming soon")
        case 3:
            print("Settings coming soon")
        case 4:
            handleLogout()
        default:
            break
        }
    }
    
//cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! AccountCell
        cell.cellImage = cellData[indexPath.row].cellImage
        cell.cellTitle = cellData[indexPath.row].cellTitle
        cell.layoutSubviews()
        return cell
    }
    
//numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }
    
//handleLogout
    @objc func handleLogout() {
        User.logOutCurrentUser { (success) in
            if !success {
                Service.presentAlert(on: self, title: "Error Logging Out", message: "Error logging out. Please try again"); return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//
//  UserDeviceView.swift
//  Autobot
//
//  Created by Tanaka, Tomohiro on 2017/09/11.
//  Copyright © 2017年 Tanaka, Tomohiro. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSDynamoDB

class UserDeviceView: UITableViewController {
    
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    
    //DynamoDBvariables
    var tableRows: Array<DDBTableRow>?
    var lock: NSLock?
    var lastEvaluatedKey:[String : AWSDynamoDBAttributeValue]!
    var doneLoading = false
    
    var needsToRefresh = false //cellのrefresh
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.delegate = self
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
        
        self.refresh()
        
        tableRows = []
        lock = NSLock()
        self.setupTable()
        
        //<Tentative>Device cell
        /*
        var iotDevice = iotDevices.init(
                roomName: NSLocalizedString(room, comment: "Your room name"),
                device: NSLocalizedString(controller, comment: "Your device"),
                icon: "deviceIcon", storyboard: "RaspberryPi3Main"
        )
        
        registeredDevices.append(iotDevice)
        
        //以下他のデバイス用
        iotDevice = iotDevices.init(
            roomName: NSLocalizedString("LivingRoom", comment: "Your room name"),
            device: NSLocalizedString("RaspberryPi-3rd", comment: "Your device"),
            icon: "deviceIcon", storyboard: "tvRemote"
        )
        
        //registeredDevices.append(iotDevice)
         */
    }
    
    /*
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setToolbarHidden(false, animated: true)
        self.tableView.tableFooterView = UIView()
        
        //invokeDynamo()
        if self.needsToRefresh {
            self.refreshList(true)
            self.needsToRefresh = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        needsToRefresh = true
        self.refreshList(true)
    }
    
    
    //DynamoDB ** sampleMEMOS **
    /*
    func invokeDynamo() {
        let dynamoDB = AWSDynamoDB.default()
        let listTableInput = AWSDynamoDBListTablesInput()
        dynamoDB.listTables(listTableInput!).continueWith{ (task: AWSTask?) -> AnyObject? in
            if let error = task!.error {
                print("Error occurred: \(error)")
                return nil
            }
            
            let listTablesOutput = task!.result
            
            for tableName in (listTablesOutput?.tableNames!)! {
                print("\(tableName)")
            }
            
            return nil
        }
    }
     */

    //DynamoDB get userdata from "Userinformation" table
    func setupTable() {
        //See if the test table exists.
        DDBDynamoDBManger.describeTable().continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            //load table contents
            self.refreshList(true)
            return nil
        })
    }
    
    func refreshList(_ startFromBeginning: Bool)  {
        if (self.lock?.try() != nil) {
            if startFromBeginning {
                self.lastEvaluatedKey = nil;
                self.doneLoading = false
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            let queryExpression = AWSDynamoDBScanExpression()
            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
            queryExpression.limit = 20
            dynamoDBObjectMapper.scan(DDBTableRow.self, expression: queryExpression).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
                
                if self.lastEvaluatedKey == nil {
                    self.tableRows?.removeAll(keepingCapacity: true)
                }
                
                if let paginatedOutput = task.result {
                    for item in paginatedOutput.items as! [DDBTableRow] {
                        if item.username == (self.user?.username)! { //CognitoLoginよりusername抜き出し
                            self.tableRows?.append(item)
                        }
                    }
                    
                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                    if paginatedOutput.lastEvaluatedKey == nil {
                        self.doneLoading = true
                    }
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableView.reloadData()
                
                if let error = task.error as NSError? {
                    print("Error: \(error)")
                }
                
                return nil
            })
        }
    } //func refreshList end
    
    //delete DDB table
    func deleteTableRow(_ row: DDBTableRow) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper.remove(row).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let error = task.error as NSError? {
                print("Error: \(error)")
                
                let alertController = UIAlertController(title: "Failed to delete a row.", message: error.description, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
            return nil
        })
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1 //1以外にするとその数分繰り返される
    }

    //返すcellの数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        /* CognitoPoolIdのUserData数
        if let response = self.response  {
            return response.userAttributes!.count
        }
        return 0
         */
        //return registeredDevices.count //tentative registeredDevice Cells
        if let rowCount = self.tableRows?.count {
            return rowCount
        } else {
            return 0
        }
    }

    //RegisterCell
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCells", for: indexPath) //deviceCells = Main.storyboardのdevice表示部
        //let registerDevice = registeredDevices[indexPath.row]
        
        //cell.textLabel!.text = registerDevice.roomName
        //cell.detailTextLabel!.text = registerDevice.device
        
        //DDBCells
        if let myTableRows = self.tableRows {
            let item = myTableRows[indexPath.row]
            cell.textLabel?.text = item.roomname
            cell.imageView!.image = UIImage(named: item.method!)
            if let myDetailTextLabel = cell.detailTextLabel {
                myDetailTextLabel.text = item.device
            }
            
            if indexPath.row == myTableRows.count - 1 && !self.doneLoading {
                self.refreshList(false)
            }
        }
        

     // Configure the cell...
        /* CognitoPoolIdの各UserData
        let userAttribute = self.response?.userAttributes![indexPath.row]
        cell.textLabel!.text = userAttribute?.name //TableViewCellをLeft Detailにしている場合のtitle
        cell.detailTextLabel!.text = userAttribute?.value  //TableViewCellをLeft Detailにしている場合のSubtitle
         */
        return cell
     }
    
    //Move to specified segue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //let registerDevice = registeredDevices[indexPath.row]
        if let myTableRows = self.tableRows {
            let item = myTableRows[indexPath.row]
            print(item.method!)
            let storyboard = UIStoryboard(name: item.method!, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: item.method!)
        self.navigationController!.present(viewController, animated: true)
        }
    }

    
    //Userのサインアウト
    @IBAction func signOut(_ sender: Any) {
        self.user?.signOut()
        self.title = nil
        self.response = nil
        self.tableView.reloadData()
        self.refresh()
    }
    
    func refresh() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
                self.title = self.user?.username
                self.tableView.reloadData()
            })
            return nil
        }
    }
    

    // - 以下EditingStyle -> Slideでdelete
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if var myTableRows = self.tableRows {
                let item = myTableRows[indexPath.row]
                self.deleteTableRow(item)
                myTableRows.remove(at: indexPath.row)
                self.tableRows = myTableRows
            
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } //else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        //}
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  TabBarController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController, UITabBarControllerDelegate{
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
    }
    
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if !User.hasUserLoggedIn(){
            if viewController == tabBarController.viewControllers?[2] || viewController == tabBarController.viewControllers?[3] {
                return false
            }
           
        }
        return true
    }
    
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        /*if item == tabBar.items?[3]{
            if !User.hasUserLoggedIn() {
                
                //self.performSegue(withIdentifier: "segueLogged", sender: nil)
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "loginViewController")
                self.present(loginViewController, animated: true, completion: nil)
            }
            
            
            
        }*/
        
        if item == tabBar.items?[2] || item == tabBar.items?[3] {
            
            if !User.hasUserLoggedIn(){
                
                // create the alert
                let alert = UIAlertController(title: "Not Logged In", message: "To perform more actions you need to be logged in", preferredStyle: UIAlertController.Style.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler: {
                    action in
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let registerViewController = storyBoard.instantiateViewController(withIdentifier: "loginViewController")
                    self.present(registerViewController, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
}


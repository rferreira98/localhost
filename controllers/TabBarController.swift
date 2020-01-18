//
//  TabBarController.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController, UITabBarControllerDelegate{
    
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.delegate = self
        
    }
    
    
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
       if !User.hasUserLoggedIn(){
            if viewController == tabBarController.viewControllers?[2] {
                return false
            }
           
        }
        return true
    
    }
    
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
         if item == tabBar.items?[2] {
            
            if !User.hasUserLoggedIn(){
                
                // create the alert
                let alert = UIAlertController(title: NSLocalizedString("Not Logged In", comment: ""), message: NSLocalizedString("To perform more actions you need to be logged in", comment: ""), preferredStyle: UIAlertController.Style.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler: {
                    action in
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginViewController = storyBoard.instantiateViewController(withIdentifier: "loginViewController")
                    loginViewController.modalPresentationStyle = .fullScreen
                    self.present(loginViewController, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Register", comment: ""), style: UIAlertAction.Style.default, handler: { action in
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let registerViewController = storyBoard.instantiateViewController(withIdentifier: "registerViewController")
                    registerViewController.modalPresentationStyle = .fullScreen
                    self.present(registerViewController, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil))
                
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
}


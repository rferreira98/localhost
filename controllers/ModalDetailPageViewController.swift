//
//  ModalDetailPageViewController.swift
//  localhost
//
//  Created by Miguel Sousa on 13/01/2020.
//  Copyright © 2020 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import UIKit

class ModalDetailPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var local: Local!
    var pageControl = UIPageControl()
    var orderedVC = [UIViewController]()
    var reviews = [Review?]()

    override func viewDidLoad() {
        getReviews(self.local.id, isLogged: User.hasUserLoggedIn())
        let width = self.view.frame.width
        let navigationBar:UINavigationBar = UINavigationBar(frame: CGRect(x:0,y:0,width:width,height:64))
        navigationBar.backgroundColor  = .clear
        
        
        
        let navigationItem = UIButton(frame: CGRect(x:0,y:0,width:64,height:44))
        navigationItem.setImage(UIImage(named: "chevron-dwon"), for: .normal)
        navigationBar.setItems([navigationItem as! UINavigationItem], animated: false)
        
        self.view.addSubview(navigationBar)
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.dataSource = self
        self.delegate = self        
    }
    
    
    
    
    @IBOutlet weak var downButton: UIButton!
    @IBAction func dragDownTouched(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func configurePageControl(){
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - (UIScreen.main.bounds.maxY * 0.12), width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = orderedVC.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor(named: "AppGreenPrimary")
        pageControl.pageIndicatorTintColor = UIColor.systemGray
        self.view.addSubview(pageControl)
        
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if self.orderedVC.count > 1 {

        guard let viewControllerIndex = orderedVC.firstIndex(of: viewController)
            else {
                return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return orderedVC.last
            //return nil
        }
        
        guard orderedVC.count > previousIndex else {
            return nil
        }
        
        return orderedVC[previousIndex]
            }else{
                       return nil
                   }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if self.orderedVC.count > 1 {
            guard let viewControllerIndex = orderedVC.firstIndex(of: viewController)
                else {
                    return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            
            guard orderedVC.count != nextIndex else {
                return orderedVC.first
                //return nil
            }
            
            guard orderedVC.count > nextIndex else {
                return nil
            }
            
            return orderedVC[nextIndex]
        }else{
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedVC.firstIndex(of: pageContentViewController)!
    }
    
    func newViewController(viewController: String) -> UIViewController {
        
        if(viewController == "detailView"){	
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController) as? MapAnnotationModalViewController
            vc?.local = self.local
            return vc!
        }else if(viewController == "reviewsView") {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController) as? ReviewsViewController
            vc?.reviews = self.reviews
            return vc!
        }else{
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
            return vc
        }
    }
    
    
    public func getReviews(_ local_id:Int, isLogged:Bool) {
        if isLogged {
            print("pedido")
            NetworkHandler.getReviews(local_id: self.local.id, completion: { (reviews, error) in
                OperationQueue.main.addOperation {
                    if error != nil {
                        let alert = Utils.triggerAlert(title: "Erro", error: error)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.reviews = reviews!
                        print(reviews!)
                        //self.reviewsTableView.reloadData()
                        //let height = self.reviewsTableView.content
                        //self.view.intrinsicContentSize.height
                        //self.scrollview.contentSize.height = height + 758
                        //print(height)
                        self.orderedVC = {
                            return [self.newViewController(viewController: "detailView"), self.newViewController(viewController: "reviewsView")]
                        }()
                        if let firstVC = self.orderedVC.first {
                            self.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
                        }
                        self.configurePageControl()
                    }
                }
            })
        }else {
            self.orderedVC = { return [self.newViewController(viewController: "detailView")] }()
            if let firstVC = self.orderedVC.first {
                self.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
            }
        }
    }
}
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
    lazy var orderedVC: [UIViewController] = {
        return [self.newViewController(viewController: "detailView"),
                self.newViewController(viewController: "reviewView")]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        if let firstVC = orderedVC.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        
        self.delegate = self
        configurePageControl()
    }
    
    
    func configurePageControl(){
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 120, width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = orderedVC.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor(named: "AppGreenPrimary")
        pageControl.pageIndicatorTintColor = UIColor.systemGray
        self.view.addSubview(pageControl)
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedVC.firstIndex(of: viewController)
            else {
                return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            //return orderedVC.last
            return nil
        }
        
        guard orderedVC.count > previousIndex else {
            return nil
        }
        
        return orderedVC[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedVC.firstIndex(of: viewController)
            else {
                return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard orderedVC.count != nextIndex else {
            //return orderedVC.first
            return nil
        }
        
        guard orderedVC.count > nextIndex else {
            return nil
        }
        
        return orderedVC[nextIndex]
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
        }else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
        }
    }
}

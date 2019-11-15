//
//  ProfileViewController.swift
//  localhost
//
//  Created by Pedro Alves on 05/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//
import UIKit

import RSKImageCropper


class ProfileViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, RSKImageCropViewControllerDelegate {

    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.hasChangedAvatar = true

        self.avatarImageView.image = croppedImage
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    var isEditingFields: Bool = false;
    var hasChangedAvatar = false;
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet var tableProfile: UITableView!
    @IBOutlet weak var buttonLogout: UIButton!
    @IBOutlet weak var barButtonItemEdit: UIBarButtonItem!
    @IBOutlet weak var buttonShare: UIButton!
    
    
    override func viewDidAppear(_ animated: Bool) {
        let rows = [0, 1, 2, 3, 4]

        for row in rows {
            let indexPath = IndexPath(row: row, section: 0)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)

            /*let indexPath2 = IndexPath(row: 4, section: 1)
            let cell2 = tableView.cellForRow(at: indexPath2)
            cell2?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell2?.selectionStyle = UITableViewCell.SelectionStyle.none;*/
            
        }
        
        //self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))?.separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0)
        
        //tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.selectionStyle = .none
        self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))?.selectionStyle = .none
        self.tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        } else {
            return 32
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2
        avatarImageView.clipsToBounds = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        
    

    tableProfile.delegate = self
    tableView.dataSource = self
    tableView.delegate = self
    
    
    //TODO Load data with the data retrieved from API
            
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    @IBAction func editClicked(_ sender: Any) {
        if isEditingFields {
            isEditingFields = false
            barButtonItemEdit.title = "Edit"
        } else {
            isEditingFields = true
            barButtonItemEdit.title = "Done"
        }
        
        
        self.firstNameTextField.isUserInteractionEnabled = isEditingFields
        self.lastNameTextField.isUserInteractionEnabled = isEditingFields
        self.emailTextField.isUserInteractionEnabled = isEditingFields
        self.usernameTextField.isUserInteractionEnabled = isEditingFields
        self.passwordTextField.isUserInteractionEnabled = isEditingFields
        self.avatarImageView.isUserInteractionEnabled = isEditingFields
        
        if isEditingFields {
            self.avatarImageView.image = UIImage(named: "AddAvatar")
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.avatarUpload(_:)))
            avatarImageView.isUserInteractionEnabled = isEditingFields
            avatarImageView.addGestureRecognizer(tapImage)
        }
    }
    
    @objc func avatarUpload(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)

        let controller = UIImagePickerController()
        controller.delegate = self

        let actionsheet = UIAlertController(title: "Select Photo", message: "Choose A Photo", preferredStyle: .actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction)in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                controller.sourceType = .camera
                self.present(controller, animated: true, completion: nil)
            }else
            {
                print("Camera is Not Available")
            }
        }))
        
        actionsheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction)in
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }))
        
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionsheet,animated: true, completion: nil)
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image: UIImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!

        picker.dismiss(animated: true, completion: { () -> Void in

            var imageCropVC: RSKImageCropViewController!

            imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.circle)

            imageCropVC.delegate = self

            self.navigationController?.pushViewController(imageCropVC, animated: true)

        })
    }
    
    @IBAction func shareClicked(_ sender: Any) {
        //TODO Share
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
       
        //UserDefaults.standard.removeObject(forKey: "XXXXX")
        //UserDefaults.standard.synchronize()

        //go to first screen
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
        self.present(loginViewController, animated: true, completion: nil)
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return false
        }
        if (text.isEmpty) {
            return false
        }
        textField.resignFirstResponder()
        if textField == self.firstNameTextField {
            self.lastNameTextField.becomeFirstResponder()
        }
        return true
    }
}

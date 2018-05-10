//
//  PostViewController.swift
//  Facsimile
//
//  Created by Vic Sukiasyan on 5/9/18.
//  Copyright © 2018 Vic Sukiasyan. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var comment: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func postImage(_ sender: Any) {
        if let image = imageToPost.image {
            let post = PFObject(className: "Post")
            post["message"] = comment.text
            post["userid"] = PFUser.current()?.objectId
            
            if let imageData = UIImagePNGRepresentation(image) {
                let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                spinner.center = self.view.center
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                view.addSubview(spinner)
                spinner.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                
                let imageFile = PFFile(name: "image.png", data: imageData)
                post["imageFile"] = imageFile
                post.saveInBackground(block: { (success, error) in
                    spinner.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if success {
                        self.displayAlert(title: "Image Posted", message: "Your image has been posted successfully.")
                        
                        self.comment.text = ""
                        self.imageToPost.image = nil
                    } else {
                        self.displayAlert(title: "Image could not be posted", message: "Please try again.")
                    }
                })
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageToPost.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

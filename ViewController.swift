//
//  ViewController.swift
//  MinIODemo
//
//  Created by Bindi Manek on 04/04/22.
//

import UIKit
import AWSS3
import AWSCore

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet var ivMinIO: UIImageView!
    var imagePath:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        self.ivMinIO.isUserInteractionEnabled = true
        self.ivMinIO.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view.
    }
    // MARK: Image Selection and Processing Methods
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    //MARK:-- ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.editedImage] as? UIImage {
            // imageViewPic.contentMode = .scaleToFill
            self.ivMinIO.image = pickedImage
            
            let imagename = String(format: "image_%@.jpg",generateRandomStringWithLength(length: 12))

            //Saving Image
            let success = saveFileImage(image: pickedImage, name: imagename, quality: 1.0)
            print(success)
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            
            imagePath = documentsDirectory.appending(String(format:"/%@",imagename))
        } else {
            let finalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            self.ivMinIO.image = finalImage
            
            let imagename = String(format: "image_%@.jpg",generateRandomStringWithLength(length: 12))

            //Saving Image
            let success = saveFileImage(image: finalImage!, name: imagename, quality: 1.0)
            print(success)
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            
            imagePath = documentsDirectory.appending(String(format:"/%@",imagename))
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func uploadS3(image: UIImage,
                  name: String,
                  progressHandler: @escaping (Progress) -> Void,
                  completionHandler: @escaping (Error?) -> Void) {

        guard let data = image.jpegData(compressionQuality: 1.0) else {
//            DispatchQueue.main.async {
//                completionHandler(Error) // Replace your error
//            }
            return
        }
//        print("data:",data)
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "readwrite", secretKey: "@!9Lw?Eh2!3U87xGdv=W+5H-VG7*MBf@")
//        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        let configuration = AWSServiceConfiguration(region: .APSouth1, endpoint: AWSEndpoint(region: .APSouth1, service: .S3, url: URL(string:"minio-client.cluster.worlddesk.co/")),credentialsProvider: credentialsProvider)
        

        AWSServiceManager.default().defaultServiceConfiguration = configuration
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { task, progress in
            DispatchQueue.main.async {
                progressHandler(progress)
            }
        }

        AWSS3TransferUtility.default().uploadData(
            data,
            bucket: "test-bucket",
            key: name,
            contentType: "image/jpg",
            expression: expression) { task, error in
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                print("Success")

            }.continueWith { task -> AnyObject? in
                if let error = task.error {
                    DispatchQueue.main.async {
                        completionHandler(error)
                    }
                    print("error:",error)
                }
                return nil
        }
    }
    // MARK: Button Methods
    @IBAction func btnShowImageClicked(_ sender: Any) {
    }
    @IBAction func btnUploadClicked(_ sender: Any) {
        
        
        
        
        let accessKey = "readwrite"
        let secretKey = "@!9Lw?Eh2!3U87xGdv=W+5H-VG7*MBf@"
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: .APSouth1, endpoint: AWSEndpoint(region: .APSouth1, service: .S3, url: URL(string:"http://minio-client.cluster.worlddesk.co/")),credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let S3BucketName = "test-bucket"
        let remoteName = "prefix_test.jpg"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
        let image = ivMinIO.image
        let data = image!.jpegData(compressionQuality: 0.9)
        do {
            try data?.write(to: fileURL)
        }
        catch {}
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = fileURL
        uploadRequest.key = remoteName
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType = "image/jpeg"
        uploadRequest.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest)
        
        transferManager.upload(uploadRequest).continueWith { (task: AWSTask<AnyObject>) -> Any? in
            
            DispatchQueue.main.async {
        
            }
            
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                print("Uploaded to:\(String(describing: publicURL!))")
            }
            
            return nil
        }
//        let remoteName = generateRandomStringWithLength(length: 12)+".jpg"
//        print("remoteName:", remoteName)
//        uploadS3(image: ivMinIO.image!, name: remoteName) { progress in
//            print("progress:",progress)
//        } completionHandler: { error in
//            print("error:",error!)
//        }
//        print("imagePath:",imagePath)
       /* guard let image = UIImage(contentsOfFile: imagePath) else { return }
        guard let jpegData = image.jpegData(compressionQuality: 1.0) else { return }
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "readwrite", secretKey: "@!9Lw?Eh2!3U87xGdv=W+5H-VG7*MBf@")
        let configuration = AWSServiceConfiguration(region: .APSouth1, endpoint: AWSEndpoint(region: .APSouth1, service: .S3, url: URL(string:"http://minio-client.cluster.worlddesk.co/")),credentialsProvider: credentialsProvider)

        AWSServiceManager.default().defaultServiceConfiguration = configuration

        let S3BucketName = "test-bucket"
        let remoteName = generateRandomStringWithLength(length: 12)+".jpg"
//        print("REMOTE NAME : ",remoteName)
//        let data: Data = (ivMinIO.image?.pngData()!)!

        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task, progress) in
            DispatchQueue.main.async(execute: {
                // Update a progress bar
                print("task:",task)
                print("progress:", progress)
            })
        }

        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if error != nil {
                    print("Error : \(error!.localizedDescription)")
                } else {
                    print("task \(task)")
                }
                // Do something e.g. Alert a user for transfer completion.
                // On failed uploads, `error` contains the error object.
            })
        }

        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadData(jpegData, bucket: S3BucketName, key: remoteName, contentType: "image/jpg", expression: expression, completionHandler: completionHandler).continueWith { (task) -> Any? in
            if let error = task.error {
                print("Error : \(error.localizedDescription)")
            }

            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(S3BucketName).appendingPathComponent(remoteName)
                if let absoluteString = publicURL?.absoluteString {
                    // Set image with URL
                    print("Image URL : ",absoluteString)
                }
            }
            return nil
        } */
    }
    func generateRandomStringWithLength(length: Int) -> String {
        let randomString: NSMutableString = NSMutableString(capacity: length)
        let letters: NSMutableString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var i: Int = 0

        while i < length {
            let randomIndex: Int = Int(arc4random_uniform(UInt32(letters.length)))
            randomString.append("\(Character( UnicodeScalar( letters.character(at: randomIndex))!))")
            i += 1
        }
        return String(randomString)
    }
    func saveFileImage(image: UIImage, name: String, quality: Float) -> Bool {
        guard let data = image.jpegData(compressionQuality: CGFloat(quality)) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        
        do {
            try data.write(to: directory.appendingPathComponent(name)!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}

extension UIImage {

  func resizedImage(newSize: CGSize) -> UIImage {
    guard self.size != newSize else { return self }

    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
    self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
   }

 }

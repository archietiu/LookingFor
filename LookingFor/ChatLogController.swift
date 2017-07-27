//
//  ChatLogController.swift
//  LookingFor
//
//  Created by Archie Tiu on 20/07/2017.
//  Copyright © 2017 LookingFor. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    var user: User? {
//        didSet {
//            navigationItem.title = user?.name
//            
//            observeMessages()
//        }
//    }
    var user: User?
    var party: Party? {
        didSet {
            observeMessages()
        }
    }
    var partyUsers = [PartyUsers]()
    var message: Message?
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    let layoutFlow = UICollectionViewFlowLayout()
    
    func fetchPartyUsers() {
        guard let partyId = party?.id else { return }
        Database.database().reference().child("party-users").child(partyId).observe(.childAdded, with: { (partyUsersSnapshot) in
            self.partyUsers.removeAll()
            guard let userIdKey = String(partyUsersSnapshot.key) else { return }
            let partyUser = PartyUsers(partyId: partyId, userId: userIdKey)
            partyUser.partyId = partyId
            self.partyUsers.append(partyUser)
            partyUser.printModel()
        }, withCancel: nil)
    }
    
    func observeMessages() {
//        guard let partyId = party?.id else { return }
//        Database.database().reference().child("party-users").child(partyId).observe(.childAdded, with: { (snapshot) in
//            let partyUser = snapshot.key as String?
//            guard let userId = self.user?.id, let toId = partyUser else { return }
//            
//            let userMessagesRef = Database.database().reference().child("user-messages").child(userId).child(toId)
//            userMessagesRef.observe(.childAdded, with: { (snapshot) in
//                let messageId = snapshot.key
//                self.fetchMessage(withMessageId: messageId, toPartyId: partyId)
//            }, withCancel: nil)
//            
//        }, withCancel: nil)
    }
    
    func fetchMessage(withMessageId messageId: String, toPartyId partyId: String) {
        let messagesRef = Database.database().reference().child("messages").child(partyId).child(messageId)
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let message = Message(dictionary: dictionary)
            message.id = messageId
//            self.messages.append(message)
            if let messageId = message.id {
                self.messagesDictionary[messageId] = message
            }
            
            self.attemptReloadOfTable()
            
        }, withCancel: nil)

    }
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return (message1.timestamp?.int32Value)! < (message2.timestamp?.int32Value)!
        })
        
        DispatchQueue.main.async(execute: {
            self.collectionView?.reloadData()
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        })
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - To be revmoved
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join", style: .plain, target: self, action: #selector(handleJoinLeaveParty))
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive
        setupKeyboardObservers()
        fetchPartyUsers()
//        observeMessages()
    }
    
    // MARK: - To be revmoved
    func handleJoinLeaveParty() {
        guard let partyId = party?.id, let userId = user?.id, let userName = user?.name, let userEmail = user?.email, let userProfileImageUrl = user?.profileImageUrl else { return }
        let partyMemberChildRef = Database.database().reference().child("party-users").child(partyId).child(userId)
        let partyMemberValues = ["name": userName, "email": userEmail, "profileImageUrl": userProfileImageUrl] as [String: Any]
        partyMemberChildRef.updateChildValues(partyMemberValues) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            print("Successfully joined the party!")
        }
        
        guard
            let partyName = party?.name,
            let createdBy = party?.createdBy,
            let startDate = party?.startDate,
            let endDate = party?.endDate,
            let place = party?.place,
            let isActive = party?.isActive else { return }
        let userPartyChildRef = Database.database().reference().child("user-parties").child(userId).child(partyId)
        let userPartyValues = [
            "name": partyName,
            "createdBy": createdBy,
            "startDate": startDate,
            "endDate": endDate,
            "place": place,
            "address": party?.address ?? "no address",
            "isActive": isActive
            ] as [String: Any]
        userPartyChildRef.updateChildValues(userPartyValues) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            print("Successfully created user-parties")
        }
        
        let alert = UIAlertController(title: "Awesome!", message: "You have successfully joined a party", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // need to create reference in order for the keyboard accessory to access the inputTextField
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true

        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControlState())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(self.inputTextField)
        //x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            // we select a video
            handleVideoSelectedForUrl(videoUrl)
        } else {
            // we select an image
            handleImageSelectedForInfo(info)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func handleVideoSelectedForUrl(_ url: URL) {
        let filename = UUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("message_movies").child(filename).putFile(from: url, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("Failed upload of video:", error!)
                return
            }

            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
                    
                    self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageUrl) in
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject]
                        self.sendMessageWithProperties(properties)
                        
                    })
                }
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.party!.name
        }
    }
    
    fileprivate func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            // CMTimeMake(1, 60) -> get the first frame of the video
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    fileprivate func handleImageSelectedForInfo(_ info: [String: Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
            })
        }
    }
    
    fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image:", error!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
                
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        sendMessageWithProperties(properties)
    }
    
    fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        guard let partyId = party?.id else { return }
        let ref = Database.database().reference().child("messages")
        let childRef = ref.child(partyId).childByAutoId()
        let toId = party!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject]
        
        //append properties dictionary onto values somehow??
        //key $0, value $1
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            self.inputTextField.text = nil
            
            let messageId = childRef.key
            self.sendMessagesToPartyMembers(fromSender: fromId, toPartyId: toId, withMessageId: messageId)
        }
    }

    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.item]
        let messageText = message.text
        
        cell.message = message

        cell.textView.text = messageText
        if let fromId = message.fromId {
            setupCell(cell, message: message, userId: fromId)
        }
        
        if let text = message.text {
            //a text message
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
            cell.textView.isHidden = false
        }
        else if message.imageUrl != nil {
            //fall in here if its an image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
    
    
        return cell
    }
    
    fileprivate func setupCell(_ cell: ChatMessageCell, message: Message , userId: String) {
        Database.database().reference().child("users").child(userId).child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
            if let user = snapshot.value as? String {
                cell.profileImageView.loadImageUsingCacheWithUrlString(user)
            }
        }, withCancel: nil)
        
        if message.fromId == Auth.auth().currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text).height + 20
        }
        else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            // h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1
            
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func handleSend() {
        guard let toId = party?.id, let fromId = user?.id else { return }
        let ref = Database.database().reference().child("messages")
        let messageChildRef = ref.child(toId).childByAutoId()
        let timestamp = Int(Date().timeIntervalSince1970)
        let messageValues = ["message": inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        
        messageChildRef.updateChildValues(messageValues) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            print("Successfully added new message")
            self.inputTextField.text = nil
            
            let messageId = messageChildRef.key
            self.sendMessagesToPartyMembers(fromSender: fromId, toPartyId: toId, withMessageId: messageId)
        }
    }
    
    // MARK: - This is being triggered when a user joins a party. FIX: use observeSingleEvent maybe?
    func sendMessagesToPartyMembers(fromSender fromId: String, toPartyId partyId: String, withMessageId messageId: String) {
        Database.database().reference().child("party-users").child(partyId).observe(.childAdded, with: { (partyUserSnapshot) in
            let partyUserId = partyUserSnapshot.key
            if partyUserId != fromId {
                
                let userMessageFromToRef = Database.database().reference().child("user-messages").child(fromId).child(partyUserId)
                let userMessageFromToValues = [messageId: 1]  as [String: Any]
                userMessageFromToRef.updateChildValues(userMessageFromToValues)
                
                let userMessageToFromRef = Database.database().reference().child("user-messages").child(partyUserId).child(fromId)
                let userMessageToFromValues = [messageId: 1]  as [String: Any]
                userMessageToFromRef.updateChildValues(userMessageToFromValues)
            }
        }, withCancel: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                // math?
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                //                    do nothing
            })
            
        }
    }
    
    func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }

}


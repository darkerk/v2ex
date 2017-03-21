//
//  SettingViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/17.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation
import Photos
import PKHUD
import RxSwift
import RxCocoa

class SettingViewController: UITableViewController {
    
    var avatarView: UIImageView?
    
    let viewModel = SettingViewModel()
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func openImagePicker() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "相机", style: .default, handler: {_ in
            if AppSetting.isCameraEnabled {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }else {
                let alert = UIAlertController(title: "请在iPhone的“设置－隐私－相机”选项中，允许V2EX访问您的相机", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "好", style: .default, handler: {action in
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "从相册选择", style: .default, handler: {_ in
            if AppSetting.isAlbumEnabled {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }else {
                let alert = UIAlertController(title: "请在iPhone的“设置－隐私－照片”选项中，允许V2EX访问您的照片", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "好", style: .default, handler: {action in
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            let smallImage = image.size.width > 300 && image.size.height > 300 ? image.thumbnailForMaxPixelSize(300) : image
            let data = UIImageJPEGRepresentation(smallImage, 0.8)!

            HUD.show()
            viewModel.uploadAvatar(imageData: data, completion: {[weak avatarView] newURLString in
                if let newURLString = newURLString {
                    avatarView?.image = smallImage
                    Account.shared.user.value?.src = newURLString
                    
                    HUD.showText("新头像设置成功")
                }else {
                    HUD.showText("新头像设置失败")
                }
            })
        }
    }

}

extension SettingViewController {
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 {
            let verson = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            return "Version" + verson + "（build \(build)）"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if section == 2 && view is UITableViewHeaderFooterView {
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.font = UIFont.systemFont(ofSize: 13)
            header.textLabel?.textAlignment = .center
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryView = nil
        if indexPath.section == 0 && indexPath.row == 0 {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 4
            if let avatarURL = Account.shared.user.value?.srcURLString {
                imageView.kf.setImage(with: URL(string: avatarURL))
            }
            cell.accessoryView = imageView
            avatarView = imageView
        }else if indexPath.section == 1 && indexPath.row == 2 {
            let switchy = UISwitch()
            cell.accessoryView = switchy
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            openImagePicker()
        }
    }
}

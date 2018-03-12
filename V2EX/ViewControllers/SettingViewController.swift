//
//  SettingViewController.swift
//  V2EX
//
//  Created by darker on 2017/3/17.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation
import Photos
import PKHUD
import RxSwift
import RxCocoa
import SafariServices

class SettingViewController: UITableViewController {
    fileprivate var avatarView: UIImageView?
    let privacyOptions = ["所有人", "已登录用户", "只有我自己"]
    
    let viewModel = SettingViewModel()
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        updateTheme()
        
        viewModel.fetchPrivacyStatus(completion: {[weak tableView] in
            tableView?.reloadData()
        })
    }
    
    func privacyAction(type: PrivacyType) {
        var alertTitle = ""
        var indexPath: IndexPath!
        if case PrivacyType.online(_) = type {
            alertTitle = "谁可以看到我的在线状态"
            indexPath = IndexPath(row: 0, section: 1)
        }else {
            alertTitle = "谁可以查看我的主题列表"
            indexPath = IndexPath(row: 1, section: 1)
        }

        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "所有人", style: .default, handler: {_ in
            switch type {
            case let .online(value):
                if value != 0 {
                    Account.shared.privacy.online = 0
                    self.tableView.reloadData()
                    self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.detailTextLabel?.text = self.privacyOptions[0]
                    self.viewModel.setPrivacy(type: PrivacyType.online(value: 0))
                }
            case let .topic(value):
                if value != 0 {
                    Account.shared.privacy.topic = 0
                    self.tableView.cellForRow(at: IndexPath(row: 1, section: 1))?.detailTextLabel?.text = self.privacyOptions[0]
                    self.viewModel.setPrivacy(type: PrivacyType.topic(value: 0))
                }
            default:
                break
            }
        }))
        alert.addAction(UIAlertAction(title: "已登录用户", style: .default, handler: {_ in
            switch type {
            case let .online(value):
                if value != 1 {
                    Account.shared.privacy.online = 1
                    self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.detailTextLabel?.text = self.privacyOptions[1]
                    self.viewModel.setPrivacy(type: PrivacyType.online(value: 1))
                }
            case let .topic(value):
                if value != 1 {
                    Account.shared.privacy.topic = 1
                    self.tableView.cellForRow(at: IndexPath(row: 1, section: 1))?.detailTextLabel?.text = self.privacyOptions[1]
                    self.viewModel.setPrivacy(type: PrivacyType.topic(value: 1))
                }
            default:
                break
            }
        }))
        alert.addAction(UIAlertAction(title: "只有我自己", style: .default, handler: {_ in
            switch type {
            case let .online(value):
                if value != 2 {
                    Account.shared.privacy.online = 2
                    self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.detailTextLabel?.text = self.privacyOptions[2]
                    self.viewModel.setPrivacy(type: PrivacyType.online(value: 2))
                }
            case let .topic(value):
                if value != 2 {
                    Account.shared.privacy.topic = 2
                    self.tableView.cellForRow(at: IndexPath(row: 1, section: 1))?.detailTextLabel?.text = self.privacyOptions[2]
                    self.viewModel.setPrivacy(type: PrivacyType.topic(value: 2))
                }
            default:
                break
            }
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if let cell = tableView.cellForRow(at: indexPath) {
                alert.popoverPresentationController?.sourceView = cell
                alert.popoverPresentationController?.sourceRect = cell.bounds
            }
        }
        present(alert, animated: true, completion: nil)
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
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
                actionSheet.popoverPresentationController?.sourceView = cell
                actionSheet.popoverPresentationController?.sourceRect = cell.bounds
            }
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func searchSwitch(_ sender: UISwitch) {
        Account.shared.privacy.search = sender.isOn
        viewModel.setPrivacy(type: PrivacyType.search(on: sender.isOn))
    }
    
    @objc func nightSwitch(_ sender: UISwitch) {
        AppStyle.shared.theme = sender.isOn ? .night : .normal
        
        drawerViewController?.setNeedsStatusBarAppearanceUpdate()
        AppStyle.shared.setupBarStyle(navigationController!.navigationBar)
        updateTheme()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AboutLicensesViewController, let indexPath = sender as? IndexPath {
            let controller = segue.destination as! AboutLicensesViewController
            controller.viewType = indexPath.row == 0 ? .licenses : .about
        }
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
        if section == 4 {
            let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            return "Version" + version + "（build \(build)）"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if view is UITableViewHeaderFooterView {
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = AppStyle.shared.theme.black153Color
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if section == 4 && view is UITableViewHeaderFooterView {
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = AppStyle.shared.theme.black153Color
            header.textLabel?.font = UIFont.systemFont(ofSize: 13)
            header.textLabel?.textAlignment = .center
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryView = nil
        let selectedView = UIView()
        selectedView.backgroundColor = AppStyle.shared.theme.cellSelectedBackgroundColor
        cell.selectedBackgroundView = selectedView
        cell.backgroundColor = AppStyle.shared.theme.cellBackgroundColor
        cell.textLabel?.textColor = AppStyle.shared.theme.black64Color
        cell.detailTextLabel?.textColor = AppStyle.shared.theme.black102Color
        cell.selectionStyle = .default
        if indexPath.section == 0 {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 4
            if let avatarURL = Account.shared.user.value?.srcURLString {
                imageView.kf.setImage(with: URL(string: avatarURL))
            }
            cell.accessoryView = imageView
            avatarView = imageView
        }else if indexPath.section == 1 {
            cell.selectionStyle = .none
            let switchy = UISwitch()
            switchy.isOn = AppStyle.shared.theme == .night
            switchy.addTarget(self, action: #selector(nightSwitch(_:)), for: .valueChanged)
            cell.accessoryView = switchy
            if AppStyle.shared.theme == .night {
                switchy.onTintColor = #colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1)
            }
        }else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = privacyOptions[Account.shared.privacy.online]
            case 1:
                cell.detailTextLabel?.text = privacyOptions[Account.shared.privacy.topic]
            case 2:
                cell.selectionStyle = .none
                let switchy = UISwitch()
                switchy.isOn = Account.shared.privacy.search
                switchy.addTarget(self, action: #selector(searchSwitch(_:)), for: .valueChanged)
                cell.accessoryView = switchy
                if AppStyle.shared.theme == .night {
                    switchy.onTintColor = #colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1)
                }
            default:
                break
            }
        }else if indexPath.section == 4 {
            if AppStyle.shared.theme == .normal {
                cell.textLabel?.textColor = UIColor.red
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            openImagePicker()
        }else if indexPath.section == 2 && indexPath.row < 2 {
            privacyAction(type: indexPath.row == 0 ? .online(value: Account.shared.privacy.online) : .topic(value: Account.shared.privacy.topic))
        }else if indexPath.section == 3 {
            performSegue(withIdentifier: AboutLicensesViewController.segueId, sender: indexPath)
        }else if indexPath.section == 4 {
            let alert = UIAlertController(title: "退出 V2EX?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "退出", style: .default, handler: {_ in
                Account.shared.logout()
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}

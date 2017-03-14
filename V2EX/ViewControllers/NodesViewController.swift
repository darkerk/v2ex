//
//  NodesViewController.swift
//  V2EX
//
//  Created by wgh on 2017/3/3.
//  Copyright © 2017年 yitop. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NodesViewController: UITableViewController {

    lazy var viewModel = NodeViewModel()
    private let disposeBag = DisposeBag()
    
    var currentNode: Node?
    let selectedItem = Variable<Node?>(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        viewModel.nodeItems?.asObservable().bindTo(tableView.rx.items) { (tableView, row, item) in
            let cell: UITableViewCell = tableView.dequeueReusableCell()
            cell.textLabel?.text = item.name
            cell.textLabel?.textColor = item.isCurrent ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
            return cell
            
            }.addDisposableTo(disposeBag)
        
        tableView.rx.modelSelected(Node.self).subscribe(onNext: {[weak self] item in
            guard let strongSelf = self else { return }
            strongSelf.selectedItem.value = item
            strongSelf.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            guard let strongSelf = self else { return }
            strongSelf.tableView.deselectRow(at: indexPath, animated: true)
        }).addDisposableTo(disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

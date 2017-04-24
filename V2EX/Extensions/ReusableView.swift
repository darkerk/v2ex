//
//  ReusableView.swift
//  V2EX
//
//  Created by darker on 2017/3/2.
//  Copyright © 2017年 darker. All rights reserved.
//

import UIKit

extension UIViewController {
    static var segueId: String {
        return String(describing: self)
    }
}

protocol ReusableView: class {
    static var reuseId: String {get}
}

extension ReusableView where Self: UIView {
    static var reuseId: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: ReusableView {
    
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView  {
        register(T.self, forCellWithReuseIdentifier: T.reuseId)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseId, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseId)")
        }
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind: String, indexPath: IndexPath) -> T where T: ReusableView {
        guard let view = dequeueReusableSupplementaryView(ofKind: ofKind, withReuseIdentifier: T.reuseId, for: indexPath) as? T else {
            fatalError("Could not dequeue reusableSupplementaryView with identifier: \(T.reuseId)")
        }
        return view
    }
}

extension UITableViewCell: ReusableView {
    
}

extension UITableView {
    
    func register<T: NibLoadableView>(for headerFooter: T.Type) where T: ReusableView {
        let nib = UINib(nibName: T.nibName, bundle: Bundle(for: T.self))
        register(nib, forHeaderFooterViewReuseIdentifier: T.reuseId)
    }
    
    func register<T: UITableViewHeaderFooterView>(for headerFooter: T.Type) where T: ReusableView {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseId)
    }
    
    func dequeueReusableCell<T: UITableViewCell>() -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseId) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseId)")
        }
        return cell
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseId, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseId)")
        }
        return cell
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T where T: ReusableView {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.reuseId) as? T else {
            fatalError("Could not dequeue HeaderFooter with identifier: \(T.reuseId)")
        }
        return view
    }
}

// MARK: - NibLoadable
protocol NibLoadableView: class {
    static var nibName: String {get}
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}


extension UITableViewHeaderFooterView: NibLoadableView, ReusableView {
    
}


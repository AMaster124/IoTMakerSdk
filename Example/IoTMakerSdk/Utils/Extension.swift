//
//  Extension.swift
//  demoapp
//
//  Created by Coding on 03.03.21.
//

import UIKit

@IBDesignable
extension UIView
{
    func circle()
    {
     radius(radius: bounds.size.height / 2)
    }

      
    func radius(radius: CGFloat, width: CGFloat?=nil, color: CGColor?=nil)
    {
     self.layer.cornerRadius = radius
     self.layer.masksToBounds = true
        
     if let width = width, let color = color
        {
        self.layer.borderWidth = width
        self.layer.borderColor = color
        }
    }

  
  @IBInspectable var cornerRadius: CGFloat {
    get { return layer.cornerRadius }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = newValue > 0
    }
  }
  
  @IBInspectable var borderWidth: CGFloat {
    get { return layer.borderWidth }
    set { layer.borderWidth = newValue }
  }
  
  @IBInspectable var borderColor: UIColor {
    get { return UIColor(cgColor: layer.borderColor!) }
    set { layer.borderColor = newValue.cgColor }
  }
  
  @IBInspectable var shadowRadius: CGFloat {
    get { return layer.shadowRadius }
    set { layer.shadowRadius = newValue }
  }
  
  @IBInspectable var shadowOpacity: Float {
    get { return layer.shadowOpacity }
    set { layer.shadowOpacity = newValue }
  }
  
  @IBInspectable var shadowOffset: CGSize {
    get { return layer.shadowOffset }
    set { layer.shadowOffset = newValue }
  }
  
  @IBInspectable  var shadowColor: UIColor? {
    get {
      if let color = layer.shadowColor { return UIColor(cgColor: color) }
      return nil
    }
    set {
      if let color = newValue { layer.shadowColor = color.cgColor }
      else { layer.shadowColor = nil }
    }
  }
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension UIImage {
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()

        let context = UIGraphicsGetCurrentContext()
        if let context = context {
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1.0, y: -1.0);
            context.setBlendMode(CGBlendMode.normal)

            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            context.clip(to: rect, mask: self.cgImage!)
            context.fill(rect)

            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage ?? self
        } else {
            return self
        }
    }
}

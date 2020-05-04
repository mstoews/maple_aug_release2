//
//  ApplicationScheme.swift
//  Maple
//
//  Created by Murray Toews on 5/3/20.
//  Copyright © 2020 Murray Toews. All rights reserved.
//

/*
 Copyright 2018-present the Material Components for iOS authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

import MaterialComponents

class ApplicationScheme: NSObject {

  private static var singleton = ApplicationScheme()

  static var shared: ApplicationScheme {
    return singleton
  }

  override init() {
    self.buttonScheme.colorScheme = self.colorScheme as! MDCSemanticColorScheme
    self.buttonScheme.typographyScheme = self.typographyScheme as! MDCTypographyScheme
    super.init()
  }

  public let buttonScheme = MDCContainerScheme()
    
    let primaryColor = UIColor(red: 0.94, green: 0.60, blue: 0.60, alpha: 1.0);
    let primaryLightColor = UIColor(red: 1.00, green: 0.80, blue: 0.80, alpha: 1.0);
    let primaryDarkColor = UIColor(red: 0.73, green: 0.42, blue: 0.42, alpha: 1.0);
    let primaryTextColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.0);

  public let colorScheme: MDCColorScheming = {
    let scheme = MDCSemanticColorScheme(defaults: .material201804)
    scheme.primaryColor =
      UIColor(red: 255.0/255.0, green: 251.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    scheme.primaryColorVariant =
      UIColor(red: 1.00, green: 0.80, blue: 0.80, alpha: 1.0);
    scheme.onPrimaryColor =
      UIColor(red: 0.94, green: 0.60, blue: 0.60, alpha: 1.0);
    scheme.secondaryColor =
      UIColor(red: 255.0/255.0, green: 251.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    scheme.onSecondaryColor =
      UIColor(red: 0.94, green: 0.60, blue: 0.60, alpha: 1.0);
    scheme.surfaceColor = UIColor.themeColor()
    scheme.onSurfaceColor = UIColor.buttonThemeColor()
    scheme.backgroundColor = UIColor(red: 255.0/255.0, green: 251.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    scheme.onBackgroundColor =
    UIColor(red: 255.0/255.0, green: 251.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    scheme.errorColor =
      UIColor(red: 197.0/255.0, green: 3.0/255.0, blue: 43.0/255.0, alpha: 1.0)
    return scheme
  }()

  public let typographyScheme: MDCTypographyScheming = {
    let scheme = MDCTypographyScheme()
    let fontName = "Rubik"
    scheme.headline5 = UIFont(name: fontName, size: 24)!
    scheme.headline6 = UIFont(name: fontName, size: 20)!
    scheme.subtitle1 = UIFont(name: fontName, size: 16)!
    scheme.button = UIFont(name: fontName, size: 14)!
    return scheme
  }()

  public let shapeScheme: MDCShapeScheming = {
    let scheme = MDCShapeScheme()
    scheme.largeComponentShape = MDCShapeCategory(cornersWith: .cut, andSize: 20)
    return scheme
  }()
}


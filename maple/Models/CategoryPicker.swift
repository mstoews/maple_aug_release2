//
//  CategoryPicker.swift
//  maple
//
//  Created by Murray Toews on 2017-07-06.
//  Copyright © 2017 mapleon. All rights reserved.
//

import UIKit


class CategoryPicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let categoryData = CategoryData()
    
    var modelData: [CategoryModel]!
    var rotationAngle: CGFloat!
    
    func Open()
    {
        modelData = CategoryData.getData()
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return modelData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attribute = [NSAttributedStringKey.foregroundColor: UIColor.white]
        let text =  modelData[row].Category
        
        return NSAttributedString(string: text, attributes: attribute)
    }
}


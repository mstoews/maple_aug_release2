//
//  DataModel.swift
//  maple
//
//  Created by Murray Toews on 2017-07-01.
//  Copyright © 2017 mapleon. All rights reserved.
//

import Foundation

class DateModel {
    var dayName = ""
    var price = ""
    var date = ""
    
    init(dayName: String, price: String, date: String) {
        self.dayName = dayName
        self.price = price
        self.date = date
    }
}

class CategoryModel {
    var Category = ""
    
    init (category: String)
    {
        self.Category = category
    }
    
}



class CategoryStrings
{
    func getData()-> [String]{
        var data = [String]()
        data.append( "ファッション")
        data.append( "ビューティー")
        data.append( "インテリア")
        data.append( "雑貨")
        data.append( "フード")
        data.append( "ドリンク")
        data.append( "文房具")
        data.append( "キッチン用品")
        data.append( "趣味")
        data.append( "ペット")
        data.append( "電化製品")
        data.append( "電化")
        data.append( "音楽")
        data.append( "音楽・ゲーム")
        return data
    }
}


class CategoryData
{
    class func getData()-> [CategoryModel]{
        var data = [CategoryModel]()
        data.append(CategoryModel(category: "ファッション"))
        data.append(CategoryModel(category: "ビューティー"))
        data.append(CategoryModel(category: "インテリア"))
        data.append(CategoryModel(category: "雑貨"))
        data.append(CategoryModel(category: "フード"))
        data.append(CategoryModel(category: "ドリンク"))
        data.append(CategoryModel(category: "文房具"))
        data.append(CategoryModel(category: "キッチン用品"))
        data.append(CategoryModel(category: "趣味"))
        data.append(CategoryModel(category: "ペット"))
        data.append(CategoryModel(category: "電化製品"))
        data.append(CategoryModel(category: "電化"))
        data.append(CategoryModel(category: "音楽"))
        data.append(CategoryModel(category: "音楽・ゲーム"))
        return data
    }
}



class SituationStrings
{
    func getData()-> [String]{
        var data = [String]()
        
        data.append( "自分で購入")
        data.append( "手土産")
        data.append( "誕生日")
        data.append( "結婚祝い")
        data.append( "出産祝い")
        data.append( "クリスマス")
        data.append( "母の日")
        data.append( "父の日")
        data.append( "記念日")
        data.append( "パーティ")
        data.append( "お歳暮・お中元")
        data.append( "バレンタインデー・ホワイトデー")
        data.append( "その他お祝い")
        return data
    }
}




class SituationModel {
    var Situation = ""
    
    init (situation: String)
    {
        self.Situation = situation
    }
}


class SituationData
{
    class func getData()-> [SituationModel]{
        var data = [SituationModel]()

        data.append(SituationModel(situation: "自分で購入"))
        data.append(SituationModel(situation: "手土産"))
        data.append(SituationModel(situation: "誕生日"))
        data.append(SituationModel(situation: "結婚祝い"))
        data.append(SituationModel(situation: "出産祝い"))
        data.append(SituationModel(situation: "クリスマス"))
        data.append(SituationModel(situation: "母の日"))
        data.append(SituationModel(situation: "父の日"))
        data.append(SituationModel(situation: "記念日"))
        data.append(SituationModel(situation: "パーティ"))
        data.append(SituationModel(situation: "お歳暮・お中元"))
        data.append(SituationModel(situation: "バレンタインデー・ホワイトデー"))
        data.append(SituationModel(situation: "その他お祝い"))
        return data
    }
}




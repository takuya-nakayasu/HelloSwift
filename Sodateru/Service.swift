//
//  Service.swift
//  Sodateru
//
//  Created by 中安拓也 on 2016/02/07.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import Foundation

/// ビジネスロジックを実装しているクラス
public class Service {
    
    let formSV: String = "NV"
    let formSP: String = "NP"
    let support = Support()
    let repo = Repository()
    
    var nowChara :Character?
    

    /// 文章生成(DB版)
    /// - parameter form: 文型(SV等のこと)
    /// - returns: 作成した文章
    func generateASentenceDB(form: String) -> String {
    
        var sentence: String = ""
        
        // DBから各種単語(動詞、名詞、形容詞)を全て取得
        let sList = repo.findWord("noun")
        let vList = repo.findWord("verb")
        let pList = repo.findWord("pronoun")
    
        /*** 選ばれた単語で文章を生成する ***/
        switch form {
            // 名詞+動詞
        case formSV:
            // 取得した単語リストから、ランダムに単語を選択
            let s = support.chooseAWordFromAList(sList)
            let v = support.chooseAWordFromAList(vList)
            sentence = "\(s) を \(v)"
            // 名詞+形容詞
        case formSP:
            // 取得した単語リストから、ランダムに単語を選択
            let s = support.chooseAWordFromAList(sList)
            let p = support.chooseAWordFromAList(pList)
            sentence = "\(s) は \(p)"
        default:
            sentence = ""
        }
    
        // 間違い文章リストを取得
        let falseSntncList:[String] = repo.findSentenceByFlg("2")
        var judge = false
        // 間違い文章かどうか判定
        for falseSntnc in falseSntncList {
            if (sentence == falseSntnc) {
                judge = true
            }
        }
        // 間違い文章だった場合は、再度文を生成
        if (judge) {
            sentence = generateASentenceDB(form)
        }
        return sentence
    }
    
    /// 誕生日と現在日時の差分を返す
    /// - parameter characterId: キャラクターID
    /// - returns: 作成した文章
    func timeSetting(characterId: String) -> NSDateComponents {
        // 現在の日時を取得
        let now = NSDate()
        // キャラクターの誕生日を取得
        let birth = repo.findBirthDateById(characterId)
        
        // 日時のフォーマットを作成
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        // 現在日時
        let nowDate = dateFormatter.stringFromDate(now)
        // 誕生日時
        let birthDate = dateFormatter.stringFromDate(birth)
        
        print("now: \(nowDate)")
        print("birthDate: \(birthDate)")
        
        let cal = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        
        //日時の差分を取得
        let unitFlags: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second]
        let components = cal.components(unitFlags, fromDate: now, toDate: birth, options: NSCalendarOptions())

        print("year: \(components.year)")
        print("month: \(components.month)")
        print("day: \(components.day)")
        print("hour: \(components.hour)")
        print("minute: \(components.minute)")
        print("minute: \(components.second)")
        
        print("\(-components.day)日経過")
        
        //
        return components
    }
    
    /// 学習させるキャラクターを作成
    /// - parameter characterId: 作成対象のキャラクターID
    /// - returns: キャラクターモデルを返す
    func characterSttng(characterId: String) -> Character {
        
        repo.characterSttng(characterId)
        
        // キャラを作成
        nowChara = repo.findCharacter(characterId)
        print("Character:\(nowChara)")
        
        return Character()
    }
    
    /// 2週間以上経過していた場合は、メッセージを返す
    /// - parameter day: birthdateからの経過日数
    /// - reurns: 2週間以上経過していた場合、「産まれました」を返す
    func hatch(day: Int) -> String {
        // 2週間以上経過していた場合
        if(day > 13) {
            return "産まれました"
        } else {
            return String(day) + "日目"
        }
    }
    
    /// DB(Realm)内容読み込み、対象テーブルはMasterWord（指定したpartのWord文字列配列を返す）
    /// - parameter part: 単語の品詞
    /// - returns: 引数の品詞にマッチした単語全て
    func findMasterWord(part: String) -> [String] {
        
        var resultList: [String] = []
        
        // DBから指定した品詞の単語を全て取り出す
        resultList = repo.findMasterWord(part)
        // 取り出した単語をシャッフル
        support.shuffle(&resultList)
        
        // 単語を5個だけ返す
        return Array(resultList[0...5])
    }
}

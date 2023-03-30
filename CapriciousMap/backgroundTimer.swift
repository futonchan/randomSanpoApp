//
//  backgroundTimer.swift
//  CapriciousMap
//
//  Created by 矢野大暉 on 2023/03/30.
//

import Foundation
import UIKit

class backgroundTimer: UIViewController,backgroundTimerDelegate {

    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var start: UIButton!
    //タイマー起動中にバックグラウンドに移行したか
    var timerIsBackground = false
    var timer:Timer!
    var currentTime = 15

    override func viewDidLoad() {
        super.viewDidLoad()
        //SceneDelegateを取得
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        //デリゲートを設定
        sceneDelegate.delegate = self
    }

    func checkBackground() {
        //バックグラウンドへの移行を確認
        if let _ = timer {
            timerIsBackground = true
        }
    }

    func setCurrentTimer(_ elapsedTime:Int) {
        //残り時間から引数(バックグラウンドでの経過時間)を引く
        currentTime -= elapsedTime
        currentTimeLabel.text = "\(currentTime)"
        //再びタイマーを起動
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(advancedTime), userInfo: nil, repeats: true)
    }

    func deleteTimer() {
        //起動中のタイマーを破棄
        if let _ = timer {
            timer.invalidate()
        }
    }

}

//
//  ViewController.swift
//  CapriciousMap
//
//  Created by 矢野大暉 on 2023/03/18.
//

// 4,8方角へランダムに指し示す。数km、数分など時間を指定して探検するだけのアプリ。

import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    var timer:Timer = Timer()
    var time:Double = 0.0
    
    @IBOutlet weak var changeDirectionButton: UIButton!
    enum DirectionChangeMenu: String {
        case random = "ﾗﾝﾀﾞﾑ"
        case order = "順番"
    }
    var selectedDirection = DirectionChangeMenu.random
    @IBOutlet weak var directionChangeSubLabel: UILabel!
    
    @IBOutlet weak var changeMinutesButton: UIButton!
    enum MinutesMenu: String {
        case minute1 = "1"
        case minute5 = "5"
        case minute10 = "10"
        case minute30 = "30"
        case minute60 = "60"
        case minute180 = "180"
    }
    var selectedMinutes = MinutesMenu.minute10
    @IBOutlet weak var minutesSubLabel: UILabel!
    
    @IBOutlet weak var changeDirectionNumButton: UIButton!
    enum DirectionNumMenu: String {
        case direction4 = "4"
        case direction8 = "8"
    }
    var selectedDirectionNum = DirectionNumMenu.direction4
    @IBOutlet weak var directionNumSubLabel: UILabel!
    
    @IBOutlet weak var directionLabel: UILabel!
    var currentIndex = 3 // 北, 南西をデフォルトに
    var directionTimer:Timer = Timer()
    let direction4Texts = ["東","南", "西", "北"]
    let direction8Texts = ["東", "南東", "南", "南西", "西", "北西", "北", "北東"]
    let direction4Add = [-90.0, 180.0, 90.0, 0.0]
    let direction8Add = [-90.0, -135.0, 180.0, 135.0, 90.0, 45.0, 0.0, -45.0]
    @IBOutlet weak var directionSubLabel: UILabel!
    
    @IBOutlet weak var upperView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var lowerView: UIView!
    
    @IBOutlet weak var arrow: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        initChangeDirectionBtn()
        initChangeMinutesBtn()
        initChangeDirectionNumBtn()
    }
    
    func initLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
    }
    // CLLocationManagerオブジェクトが方位磁石の向きの更新を受信したときにcall
    // 現在の方位磁石の向きを使用してコンパスの針を更新する
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // +90で西
        var directionAdd:[Double] = []
        let directionNum = Int(self.selectedDirectionNum.rawValue)!
        if directionNum == 4 {
            directionAdd = self.direction4Add
        } else {
            directionAdd = self.direction8Add
        }
        let magneticHeading = newHeading.magneticHeading + directionAdd[currentIndex]
        let imageRotationAngle = CGFloat(-magneticHeading * CGFloat.pi / 180)
        arrow.transform = CGAffineTransform.init(rotationAngle: imageRotationAngle)
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        if timer.isValid == false {
            settingDirection()
        } else {
            timer.invalidate()
            self.timerLabel.text = "00:00:00"
            self.time = 0.0
            startButton.setTitle("出発", for: .normal)
            startButton.configuration?.baseBackgroundColor = UIColor.systemGreen
            
            timerLabel.textColor = UIColor.black
            directionLabel.textColor = UIColor.black
            directionSubLabel.textColor = UIColor.black
            upperView.backgroundColor = UIColor.opaqueSeparator
            
            mainView.backgroundColor = UIColor.systemBackground
            
            minutesSubLabel.textColor = UIColor.black
            directionChangeSubLabel.textColor = UIColor.black
            directionNumSubLabel.textColor = UIColor.black
            lowerView.backgroundColor = UIColor.opaqueSeparator
        }
    }
    
    func settingDirection() {
        // 方角設定
        let directionNum = Int(self.selectedDirectionNum.rawValue)!
        var directionTexts:[String] = []
        if directionNum == 4 {
            directionTexts = self.direction4Texts
        } else {
            directionTexts = self.direction8Texts
        }
        if self.selectedDirection == .random {
            self.currentIndex = Int.random(in: 0...(directionNum - 1))
            let directionText = directionTexts[self.currentIndex]
            self.directionLabel.text = directionText
        } else {
            if self.currentIndex >= (directionNum - 1) {
                self.currentIndex = 0
            } else {
                self.currentIndex += 1
            }
            self.directionLabel.text = directionTexts[self.currentIndex]
        }
        
        // 時間設定
        self.time = Double(self.selectedMinutes.rawValue)! * 60.0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [self] _ in
            self.time -= 1.0
            let hours = Int(self.time / 3600)
            let minutes = Int(self.time.truncatingRemainder(dividingBy: 3600) / 60)
            let second = Int(self.time) % 60
            self.timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, second)
            if self.time <= 0.0 {
                timer.invalidate()
                settingDirection()
            }
        })
        startButton.setTitle("終了", for: .normal)
        startButton.configuration?.baseBackgroundColor = UIColor.systemRed
        
        let mySystemGray = "C0C0C0"
        timerLabel.textColor = UIColor(hex: mySystemGray)
        directionLabel.textColor = UIColor(hex: mySystemGray)
        directionSubLabel.textColor = UIColor(hex: mySystemGray)
        upperView.backgroundColor = UIColor(hex: "1C1C1E")
        
        mainView.backgroundColor = UIColor(hex: "74829A")
        
        minutesSubLabel.textColor = UIColor(hex: mySystemGray)
        directionChangeSubLabel.textColor = UIColor(hex: mySystemGray)
        directionNumSubLabel.textColor = UIColor(hex: mySystemGray)
        lowerView.backgroundColor = UIColor(hex: "1C1C1E")
        
        locationManager.startUpdatingHeading()
    }
    
    func initChangeDirectionBtn() {
        let menu = UIMenu(options: .displayInline, children: [
            UIAction(title: DirectionChangeMenu.order.rawValue, handler: { _ in
                self.selectedDirection = .order
                self.initChangeDirectionBtn()
            }),
            UIAction(title: DirectionChangeMenu.random.rawValue, handler: { _ in
                self.selectedDirection = .random
                self.initChangeDirectionBtn()
            })
        ])
        changeDirectionButton.menu = menu
        changeDirectionButton.showsMenuAsPrimaryAction = true
        changeDirectionButton.setTitle(self.selectedDirection.rawValue, for: .normal)
    }
    
    func initChangeMinutesBtn() {
        let menu = UIMenu(options: .displayInline, children: [
            UIAction(title: MinutesMenu.minute180.rawValue, handler: { _ in
                self.selectedMinutes = .minute180
                self.initChangeMinutesBtn()
            }),
            UIAction(title: MinutesMenu.minute60.rawValue, handler: { _ in
                self.selectedMinutes = .minute60
                self.initChangeMinutesBtn()
            }),
            UIAction(title: MinutesMenu.minute30.rawValue, handler: { _ in
                self.selectedMinutes = .minute30
                self.initChangeMinutesBtn()
            }),
            UIAction(title: MinutesMenu.minute10.rawValue, handler: { _ in
                self.selectedMinutes = .minute10
                self.initChangeMinutesBtn()
            }),
            UIAction(title: MinutesMenu.minute5.rawValue, handler: { _ in
                self.selectedMinutes = .minute5
                self.initChangeMinutesBtn()
            }),
            
            UIAction(title: MinutesMenu.minute1.rawValue, handler: { _ in
                self.selectedMinutes = .minute1
                self.initChangeMinutesBtn()
            })
        ])
        changeMinutesButton.menu = menu
        changeMinutesButton.showsMenuAsPrimaryAction = true
        changeMinutesButton.setTitle(self.selectedMinutes.rawValue, for: .normal)
    }
    
    func initChangeDirectionNumBtn() {
        let menu = UIMenu(options: .displayInline, children: [
            UIAction(title: DirectionNumMenu.direction8.rawValue, handler: { _ in
                self.selectedDirectionNum = .direction8
                self.initChangeDirectionNumBtn()
            }),
            UIAction(title: DirectionNumMenu.direction4.rawValue, handler: { _ in
                self.selectedDirectionNum = .direction4
                self.initChangeDirectionNumBtn()
            })
        ])
        changeDirectionNumButton.menu = menu
        changeDirectionNumButton.showsMenuAsPrimaryAction = true
        changeDirectionNumButton.setTitle(self.selectedDirectionNum.rawValue, for: .normal)
    }
    
    // 画面を縦方向に固定する
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}


extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    func toHexString() -> String {
        var red: CGFloat     = 1.0
        var green: CGFloat   = 1.0
        var blue: CGFloat    = 1.0
        var alpha: CGFloat   = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = Int(String(Int(floor(red*100)/100 * 255)).replacingOccurrences(of: "-", with: ""))!
        let g = Int(String(Int(floor(green*100)/100 * 255)).replacingOccurrences(of: "-", with: ""))!
        let b = Int(String(Int(floor(blue*100)/100 * 255)).replacingOccurrences(of: "-", with: ""))!
        let a = Int(String(Int(floor(alpha*100)/100 * 255)).replacingOccurrences(of: "-", with: ""))!

        let result = String(r, radix: 16).leftPadding(toLength: 2, withPad: "0") + String(g, radix: 16).leftPadding(toLength: 2, withPad: "0") + String(b, radix: 16).leftPadding(toLength: 2, withPad: "0") + String(a, radix: 16).leftPadding(toLength: 2, withPad: "0")
        return result
    }
}

extension String {
    // 左から文字埋めする
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}

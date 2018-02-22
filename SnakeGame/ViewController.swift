//
//  ViewController.swift
//  MyPractice
//
//  Created by 江宗翰 on 2018/1/16.
//  Copyright © 2018年 Hank.Chiang. All rights reserved.
//

import UIKit

enum direction{
    case up
    case down
    case right
    case left
}

class ViewController: UIViewController {

    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var difficullyLabel: UILabel!
    @IBOutlet weak var pointView: UIView!
    @IBOutlet weak var pontnLabel: UILabel!
    @IBOutlet weak var safeView: UIView!
    @IBOutlet var joystickView: UIView!
    
    var snake = [UIView]()
    var initSnakeArr = [UIView]()
    var topFram = CGRect()
    var timer:Timer!
    var isNotFirst = false
    var isStop = true
    var nowDirection = direction.right //方向
    var ExcessX:Double = 0.0
    var ExcessY:Double = 0.0
    var size = 30.0
    var difficully = 0.15 //移動頻率
    var statusBarHeight = UIApplication.shared.statusBarFrame.height //狀態列的高度
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //把popView 放到最上面
        self.view.bringSubview(toFront: popView)
        
        startBtn.layer.cornerRadius = 20
        
        //把joystickView加到view上
        joystickView.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY+150)
        joystickView.layer.cornerRadius = 75
        self.view.addSubview(joystickView)
        
        //平板size
        if self.view.frame.maxX > 500{
            size = 50.0
        }
        
        //計算邊框厚度
        let midX = self.view.frame.midX
        let midY = self.view.frame.midY
        ExcessX = Double(midX.truncatingRemainder(dividingBy: CGFloat(size)))
        ExcessY = Double(midY.truncatingRemainder(dividingBy: CGFloat(size)))
        print("\(self.view.frame.maxX)  \(ExcessX)")
        print("\(self.view.frame.maxY)  \(ExcessY)")
        
        
        //做出初始的3格view
        let view1 = UIView(frame: CGRect(x: self.view.frame.midX-CGFloat(size), y: self.view.frame.midY, width: CGFloat(size), height: CGFloat(size)))
        view1.backgroundColor = randamColor()
        snake.append(view1)
        initSnakeArr.append(view1)
        
        let view2 = UIView(frame: CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: CGFloat(size), height: CGFloat(size)))
        view2.backgroundColor = randamColor()
        snake.append(view2)
        initSnakeArr.append(view2)
        
        let view3 = UIView(frame: CGRect(x: self.view.frame.midX+CGFloat(size), y: self.view.frame.midY, width: CGFloat(size), height: CGFloat(size)))
        view3.backgroundColor = randamColor()
        snake.append(view3)
        initSnakeArr.append(view3)
    }
    
    override func viewDidLayoutSubviews() {
        //邊框
        if !isNotFirst{
            safeView.addRightBorderWithColor(color: UIColor(colorWithHexValue: 0xf2e9e1), width: CGFloat(ExcessX))
            safeView.addLeftBorderWithColor(color: UIColor(colorWithHexValue: 0xf2e9e1), width: CGFloat(ExcessX))
            safeView.addTopBorderWithColor(color: UIColor(colorWithHexValue: 0xf2e9e1), width: CGFloat(ExcessY+Double(size)-Double(statusBarHeight)))
            safeView.addBottomBorderWithColor(color: UIColor(colorWithHexValue: 0xf2e9e1), width: CGFloat(ExcessY))
        }
    }
    
    //開始
    @IBAction func startAction(_ sender: UIButton) {
        popView.isHidden = true
        stopBtn.isHidden = false
        isStop = false
        scoreLabel.text = "0"
        nowDirection = .right
        topFram = CGRect(x: self.view.frame.midX+CGFloat(size), y: self.view.frame.midY, width: CGFloat(size), height: CGFloat(size))
        addPoint()
        if isNotFirst {
            for s in snake{
                s.removeFromSuperview()
            }
            snake = initSnakeArr
        }else{
            pointView.isHidden = false
        }
        for s in snake{
            self.view.addSubview(s)
        }
        isNotFirst = true
        timer = Timer.scheduledTimer(timeInterval: difficully,target:self,selector:#selector(move), userInfo:nil,repeats:true)
        
    }
    
    //增加糖果
    func addPoint(){
        var notOk = true
        //產生隨機的x y座標
        var xf = Double(arc4random_uniform(UInt32((self.view.frame.maxX-CGFloat(size)) / CGFloat(size))))*Double(size) + ExcessX
        var yf = Double(arc4random_uniform(UInt32((self.view.frame.maxY-CGFloat(size)) / CGFloat(size))))*Double(size) + ExcessY + Double(size)
        
        print("Point =  x:\(xf) y:\(yf)")
        
        //如果座標在蛇身上 重新產生
        while notOk {
            var check = true
            for s in snake{
                if Double(s.frame.origin.x) == xf && Double(s.frame.origin.y) == yf{
                    xf = Double(arc4random_uniform(UInt32((self.view.frame.maxX-CGFloat(size)) / CGFloat(size))))*Double(size) + ExcessX
                    yf = Double(arc4random_uniform(UInt32((self.view.frame.maxY-CGFloat(size)) / CGFloat(size))))*Double(size) + ExcessY + Double(size)
                    check = false
                    break
                }
            }
            if check {
                notOk = false
            }
        }
        pointView.frame = CGRect(x: xf, y: yf, width: Double(size), height: Double(size))
        pontnLabel.text = randomEmoji()
        
    }
    
    
    //移動
    @objc func move(){
        //移動方向
        switch nowDirection {
        case .right:
            topFram.origin.x += CGFloat(size)
        case .left:
            topFram.origin.x -= CGFloat(size)
        case .up:
            topFram.origin.y -= CGFloat(size)
        case .down:
            topFram.origin.y += CGFloat(size)
        }
        
        //是否超過邊界
        if topFram.origin.x > self.view.frame.maxX-CGFloat(size) ||
            topFram.origin.x < self.view.frame.minX ||
            topFram.origin.y > self.view.frame.maxY-CGFloat(size) ||
            topFram.origin.y < self.view.frame.minY+statusBarHeight{
            print("break  x:\(topFram.origin.x) y:\(topFram.origin.y)")
            //震動
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            timer.invalidate()
            popView.isHidden = false
            stopBtn.isHidden = true
            self.view.bringSubview(toFront: popView)
            return
        }
        
        //是否撞到自己
        for i in 0...snake.count-2{
            if snake[i].frame.origin.x == topFram.origin.x && snake[i].frame.origin.y == topFram.origin.y{
                
                //震動
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                timer.invalidate()
                popView.isHidden = false
                stopBtn.isHidden = true
                self.view.bringSubview(toFront: popView)
                return
            }
        }
        
        //是否吃到糖果
        if snake[snake.count-1].frame.origin.x == pointView.frame.origin.x &&
            snake[snake.count-1].frame.origin.y == pointView.frame.origin.y {
            //震動
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            addPoint()
            scoreLabel.text = "\(Int(scoreLabel.text!)!+1)"
        }else{
            snake[0].removeFromSuperview()
            snake.remove(at: 0)
        }
        
        let newView = UIView(frame: topFram)
        newView.backgroundColor = randamColor()
        self.view.addSubview(newView)
        snake.append(newView)
    }
    
    
    
    @IBAction func turnRight(_ sender: UIButton) {
        if nowDirection != .left{
            nowDirection = .right
            print("right")
        }
    }
    
    @IBAction func turnLeft(_ sender: UIButton) {
        if nowDirection != .right{
            nowDirection = .left
            print("left")
        }
    }
    @IBAction func turnUp(_ sender: UIButton) {
        if nowDirection != .down{
            nowDirection = .up
            print("up")
        }
    }
    
    @IBAction func turnDown(_ sender: UIButton) {
        if nowDirection != .up{
            nowDirection = .down
            print("down")
        }
    }
    
    @IBAction func turnRightGesture(_ sender: UISwipeGestureRecognizer) {
        if joystickView.isHidden {
            if nowDirection != .left{
                nowDirection = .right
                print("right")
            }
        }
        
    }
    
    @IBAction func turnLeftGesture(_ sender: UISwipeGestureRecognizer) {
        if joystickView.isHidden {
            if nowDirection != .right{
                nowDirection = .left
                print("left")
            }
        }
    }
    
    @IBAction func turnUpGesture(_ sender: UISwipeGestureRecognizer) {
        if joystickView.isHidden {
            if nowDirection != .down{
                nowDirection = .up
                print("up")
            }
        }
    }
    
    @IBAction func turnDownGesture(_ sender: UISwipeGestureRecognizer) {
        if joystickView.isHidden {
            if nowDirection != .up{
                nowDirection = .down
                print("down")
            }
        }
    }
    
    //暫停
    @IBAction func stopAction(_ sender: UIButton) {
        if isStop{
            stopBtn.setTitle("II", for: .normal)
            timer = Timer.scheduledTimer(timeInterval:difficully,target:self,selector:#selector(move), userInfo:nil,repeats:true)
            isStop = !isStop
        }else{
            stopBtn.setTitle("▶︎", for: .normal)
            timer.invalidate()
            isStop = !isStop
        }
    }
    
    //調整難度
    @IBAction func difficultyStrpper(_ sender: UIStepper) {
        difficullyLabel.text = "\(Int(sender.value))"
        difficully = 0.15 + 0.01 - sender.value * 0.01
    }

    //移動方向鍵
    @IBAction func touchMoveJoyStick(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed{
            let translation = sender.translation(in: sender.view)
            let changeX = (sender.view?.center.x)! + translation.x
            let changeY = (sender.view?.center.y)! + translation.y
            sender.view?.center = CGPoint(x: changeX, y: changeY)
            sender.setTranslation(CGPoint.zero, in: sender.view)
        }
    }
    
    //方向鍵開關
    @IBAction func joyStickSwitch(_ sender: UISwitch) {
        if sender.isOn{
            joystickView.isHidden = false
        }else{
            joystickView.isHidden = true
        }
    }
    
    func randamColor() -> UIColor{
        let red = Double(arc4random_uniform(256))
        let green = Double(arc4random_uniform(256))
        let blue = Double(arc4random_uniform(256))
        
        let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
        return color
    }
    
    func randomEmoji()->String{
        let emojiStart = 0x1f34f
        let ascii = emojiStart + Int(arc4random_uniform(UInt32(35)))
        let emoji = UnicodeScalar(ascii)?.description
        return emoji ?? "😍"
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

//
//  ViewController.swift
//  ProyectoAdrian
//
//  Created by Luis Garcia on 04/01/23.
//

import UIKit
import CoreLocation
import CoreBluetooth
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var registros : [Registros]?
    
    
    @IBOutlet weak var namePeri: UILabel!
    
    @IBOutlet weak var btnDiscoverPeri: UIButton!
    
    @IBOutlet weak var btnConectar: UIButton!
    
    @IBOutlet weak var btnDesconectar: UIButton!
    
    @IBOutlet weak var viewS: UIStackView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var btn30s: UIButton!
    
    @IBOutlet weak var btn1min: UIButton!
    
    @IBOutlet weak var resetButton: UIButton!
    
    var manager : CBCentralManager!
    var myBluetoothPeripheral : CBPeripheral!
    var myCharacteristic : CBCharacteristic!
    var isMyPeripheralConected = false
    var timerCounting: Bool = false
    var startTime: Date?
    var stopTime: Date?
    
    var idT = 0
    let userDefaults = UserDefaults.standard
    let START_TIME_KEY = "startTime"
    let STOP_TIME_KEY = "stopTime"
    let COUNTING_TIME_KEY = "countingKey"
    
    var scheduledTimer : Timer!
    
       
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewS.layer.cornerRadius = 30
        viewS.layer.cornerCurve = .continuous
        viewS.layer.shadowOpacity = 2
        viewS.layer.shadowOffset = CGSize(width: 5, height: 5)
        viewS.layer.shadowColor = UIColor.green.cgColor
        
        initSetup()
       
        

        
        startTime = userDefaults.object(forKey: START_TIME_KEY) as? Date
        stopTime = userDefaults.object(forKey: STOP_TIME_KEY) as? Date
        timerCounting = userDefaults.bool(forKey: COUNTING_TIME_KEY)
        
        
        setStopTime(date: nil)
        setStartTime(date: nil)
        timeLabel.text = makeTimeString(hour: 0, min: 0, sec: 0)
        stopTimer()
        
        btn30s.isEnabled = true
        
       
    /*if timerCounting{
            startTimer()
        
           
            
            
            
        }
        
       
        else
                {
                    stopTimer()
                    if let start = startTime
                    {
                        if let stop = stopTime
                        {
                            let time = calcRestartTime(start: start, stop: stop)
                            let diff = Date().timeIntervalSince(time)
                            setTimeLabel(Int(diff))
                        }
                    }
                }*/
       
    
        
        
    }
    
  
    
    //  MARK:
    
    
    @IBAction func descubrirDispositivos(_ sender: Any) {
        manager = CBCentralManager(delegate: self, queue: nil)
        
        }
    
    @IBAction func conectar(_ sender: Any) {
        manager.connect(myBluetoothPeripheral, options: nil)
        
    }
    
    
    @IBAction func Desconectar(_ sender: Any) {
        manager.cancelPeripheralConnection(myBluetoothPeripheral)
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var msg = ""
               
               switch central.state {
                   
                   case .poweredOff:
                       msg = "Bluetooth is Off"
                   case .poweredOn:
                       msg = "Bluetooth is On"
                       manager.scanForPeripherals(withServices: nil, options: nil)
                   case .unsupported:
                       msg = "Not Supported"
                   default:
                       msg = "😔"
                   
               }
               
               print("STATE: " + msg)
        
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "BT-ProyectoAdrian" {
                  
                namePeri.isHidden = false
                namePeri.text = peripheral.name ?? "Default"
                  
                self.myBluetoothPeripheral = peripheral
                self.myBluetoothPeripheral.delegate = self
                    
                manager.stopScan()
                }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            isMyPeripheralConected = true //when connected change to true
            peripheral.delegate = self
            peripheral.discoverServices(nil)
            
        }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        initSetup()
        
      }
    
    func initSetup(){
      initUI()
      initLogic()
      
    }
    
    func initUI(){
        
       
        namePeri.text = "Buscando Dispositivo..."
        btnDesconectar.isEnabled = false
              }
    
    func initLogic(){
      isMyPeripheralConected = false
      
      if myBluetoothPeripheral != nil{
        
        if myBluetoothPeripheral.delegate != nil {
        myBluetoothPeripheral.delegate = nil
        }

      }

    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            
        if let servicePeripheral = peripheral.services as [CBService]? {
                
                for service in servicePeripheral {
                    
                    //Then look for the characteristics of the services
                  print(service.uuid.uuidString)

                    myBluetoothPeripheral.discoverCharacteristics(nil, for: service)
                    
                }
                
            }
        }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characterArray = service.characteristics as [CBCharacteristic]? {
                
                for cc in characterArray {
                  
                  print(cc.uuid.uuidString)

                    if(cc.uuid.uuidString == "ABD0-09391j") {
                        
                        myCharacteristic = cc
                      
                      updateUiOnSuccessfullConnectionAfterFoundCharacteristics()
                      
                      myBluetoothPeripheral.setNotifyValue(true, for: myCharacteristic)

     
                    }
                    
                }
            }
            
        }
    
    func updateUiOnSuccessfullConnectionAfterFoundCharacteristics(){
        
      
        btnDesconectar.isEnabled = true

      }
    
    @IBAction func start30sAction(_ sender: Any) {
        
        idT = 1
        if timerCounting{
            setStopTime(date: Date())
            stopTimer()
        }
        else{
         
            
                setStartTime(date: Date())
                }
            startTimer()
        timeLabel.textColor = UIColor.red
        let regi = Registros(context: self.context)
        regi.tiempo = "30s"
        regi.observaciones = "Observaciones"
        regi.fecha = Date()
        do{
            try context.save()
            
        }catch{
            print("ERROR AL GUARDAR")
            
        }
        
        
    }
    
    
    func calcRestartTime(start: Date, stop: Date) -> Date
        {
            let diff = start.timeIntervalSince(stop)
            return Date().addingTimeInterval(diff)
        }
    
    func stopTimer(){
        
        if scheduledTimer != nil{
            scheduledTimer.invalidate()
            
            
        }
        setTimerCounting(false)
        timeLabel.textColor = UIColor.black
      
        
    }
    func recuperarDatos(){
        
        do{
            self.registros = try context.fetch(Registros.fetchRequest())
           
                
         
                
            
        }catch{
            print("ERROR DE DATOS")
            
        }
        
        
    }
    
    func startTimer(){
        
        
        
        
            scheduledTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshValue), userInfo: nil, repeats: true)
            setTimerCounting(true)
        btn30s.isEnabled = false
        btn1min.isEnabled = false
           
            
            
            
        
       
        
        
        
        
    }
    
    @objc func refreshValue(){
        
        
        if idT == 1 && timeLabel.text == makeTimeString(hour: 0, min: 0, sec: 29){
            scheduledTimer.invalidate()
            
           
        }
        if idT == 2 && timeLabel.text == makeTimeString(hour: 0, min: 0, sec: 59){
            scheduledTimer.invalidate()
            
            
        }
        
        if let start = startTime{
            
            let diff = Date().timeIntervalSince(start)
            setTimeLabel(Int(diff))
            
        }else{
            stopTimer()
            setTimeLabel(0)
            
            
            
        }
        
    }
    func setTimeLabel(_ val: Int){
        let time = secondsToHoursMinutesSeconds(val)
        let timeString = makeTimeString(hour: time.0, min: time.1, sec: time.2)
        timeLabel.text = timeString
        
    }
    
    func secondsToHoursMinutesSeconds(_ ms: Int) -> (Int, Int, Int)
        {
            let hour = ms / 3600
            let min = (ms % 3600) / 60
            let sec = (ms % 3600) % 60
            return (hour, min, sec)
        }
        
    func makeTimeString(hour: Int, min: Int, sec: Int) -> String
        {
            var timeString = ""
            timeString += String(format: "%02d", hour)
            timeString += ":"
            timeString += String(format: "%02d", min)
            timeString += ":"
            timeString += String(format: "%02d", sec)
            return timeString
        }
    
    
    
    @IBAction func start1minAction(_ sender: Any) {
        
        idT = 2
        if timerCounting{
            setStopTime(date: Date())
            stopTimer()
        }
        else{
         
            
                setStartTime(date: Date())
                }
            startTimer()
        timeLabel.textColor = UIColor.red
        let regi = Registros(context: self.context)
        regi.tiempo = "1min"
        regi.observaciones = "observacioes"
        regi.fecha = Date()
        do{
            try context.save()
            
        }catch{
            print("ERROR AL GUARDAR")
            
        }
        
        
        
    }
    
    @IBAction func resetAction(_ sender: Any) {
        setStopTime(date: nil)
        setStartTime(date: nil)
        timeLabel.text = makeTimeString(hour: 0, min: 0, sec: 0)
        stopTimer()
        
        btn30s.isEnabled = true
        btn1min.isEnabled = true
    }
    
    func setStartTime(date: Date?){
        startTime = date
        userDefaults.set(startTime, forKey: START_TIME_KEY)
        
    }
    
    func setStopTime(date: Date?){
        stopTime = date
        userDefaults.set(stopTime, forKey: STOP_TIME_KEY)
        
    }
     
    func setTimerCounting(_ val: Bool){
        timerCounting = val
        userDefaults.set(timerCounting, forKey: COUNTING_TIME_KEY)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    

}


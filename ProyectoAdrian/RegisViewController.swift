//
//  RegisViewController.swift
//  ProyectoAdrian
//
//  Created by Luis Garcia on 30/01/23.
//

import UIKit
import CoreData

class RegisViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var registros : [Registros]?
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName:"RegistroTableViewCell", bundle: nil), forCellReuseIdentifier: "mycell")
        
        recuperarDatos()
        tableView.reloadData()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        recuperarDatos()
    }
    
    func recuperarDatos(){
        
        do{
            self.registros = try context.fetch(Registros.fetchRequest())
           
                
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
            }
                
            
        }catch{
            print("ERROR DE DATOS")
            
        }
        
        
    }
    



}

extension RegisViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registros!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath) as? RegistroTableViewCell
        
        cell?.tiempo.text = registros![indexPath.row].tiempo
        cell?.observaciones.text = registros![indexPath.row].observaciones
        cell?.fecha.text = registros![indexPath.row].fecha?.conStr()
        
        
        
        return cell!
    }
    
    
}

extension Date {
    func conStr()-> String{
        let date = DateFormatter()
        date.dateFormat = "MM-dd-yyyy HH:mm"
        return date.string(from: self)
    }
}


extension RegisViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(registros![indexPath.row])
        
        let datoEdit = self.registros![indexPath.row]
        let alerta = UIAlertController(title: "EDITAR OBSERVACIONES", message: "Observaciones", preferredStyle: .alert)
        
        alerta.addTextField()
        
        let textField = alerta.textFields![0]
        
        textField.text = datoEdit.observaciones
        
        // boton
        let botonAlerta = UIAlertAction(title: "Editar", style: .default){ action in
            
            let textField = alerta.textFields![0]
            
            //Editar
            datoEdit.observaciones = textField.text
            try! self.context.save()
            
            self.recuperarDatos()
            
            
        }
        
       
        
        
        let botonCancelar = UIAlertAction(title: "Candelar", style: .cancel, handler: nil)
        
        alerta.addAction(botonAlerta)
        alerta.addAction(botonCancelar)
        
        self.present(alerta, animated: true, completion: nil)
        
        
        
        
        
    
        
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "BORRAR"){(action, view, completionHandler) in
            
            let datoDelete =  self.registros![indexPath.row]
            
            self.context.delete(datoDelete)
            
            try! self.context.save()
            
            self.recuperarDatos()
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
}

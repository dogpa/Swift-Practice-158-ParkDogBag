//
//  ImagePicker.swift
//  ParkDogBag
//
//  Created by Dogpa's MBAir M1 on 2022/6/9.
//


import UIKit
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    //相簿的類型
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    //透過Binding建立一個UIImage
    @Binding var selectedImage: UIImage
    
    //選完照片退出選照片頁面使用的presentationMode
    @Environment(\.presentationMode) private var presentationMode
    
    //
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

                guard let data = image.jpegData(compressionQuality: 0.5) else { return }
                let encoded = try! PropertyListEncoder().encode(data)
                UserDefaults.standard.set(encoded, forKey: "dogImage")
                if let data = UserDefaults.standard.data(forKey: "dogImage")  {
                    let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
                    let dogImage = UIImage(data: decoded)
                    if dogImage != nil {
                        parent.selectedImage = dogImage!
                    }
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

func checkDogImage () -> UIImage {
    var image = UIImage()
    if let data = UserDefaults.standard.data(forKey: "dogImage")  {
        let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
        let dogImage = UIImage(data: decoded)
        if dogImage != nil {
            image = dogImage!
        }
    }else{
        image = UIImage(systemName: "pawprint.fill")!
        
    }
    return image
}

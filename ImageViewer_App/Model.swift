//
//  Model.swift
//  ImageViewer_App
//
//  Created by Niraj Panchal on 20/03/23.
//

import Foundation

public class ImageModel {
    var imgTitle: String
    var imgUrl: String
    
    init(title: String, imageUrl: String){
        imgTitle = title
        imgUrl = imageUrl
    }
}

var imageList = [ImageModel]()
var nasaImages = [ImageModel]()
var imageLoaderState: Bool = true
let apiKey = "Knw8NnaDhjUYNbhbbljxYU86dAXN0aEM8X6FuzJQ"

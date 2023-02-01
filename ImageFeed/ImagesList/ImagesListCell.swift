//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Yakov Nemychenkov on 08.01.2023.
//
import UIKit
import Foundation

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
}

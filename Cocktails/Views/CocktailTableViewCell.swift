//
//  CocktailTableViewCell.swift
//  Cocktails
//
//  Created by Consultant on 7/5/22.
//

import UIKit

class CocktailTableViewCell: UITableViewCell {

    @IBOutlet weak var cocktailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    static let identifier = "CocktailTableViewCell"
    var delegate: FavoritesProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        nameLabel.text = nil
        cocktailImageView.image = nil
        cocktailImageView.cancelImageLoad()
        favButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
    
    func configure(_ cocktail: Cocktail, isFavorite: Bool = false, canDelete: Bool = false){
        cocktailImageView.layer.borderWidth = 1
        cocktailImageView.layer.borderColor = UIColor.white.cgColor
        cocktailImageView.layer.cornerRadius = 10
        cocktailImageView.clipsToBounds = true
        nameLabel.text = cocktail.name
        cocktailImageView.loadImage(at: URL(string: cocktail.thumbUrl)!)
        let icon = canDelete ? "trash.fill" : "heart.fill"
        favButton.tintColor = canDelete || isFavorite ? .red : .white
        favButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    @IBAction func didTapFavButton(_ sender: Any) {
        delegate?.passSelectedRowData(cell: self)
    }
}

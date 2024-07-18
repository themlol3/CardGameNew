import Foundation

class Card {
    var isFlipped: Bool
    var imageName: String
    
    init(imageName: String) {
        self.isFlipped = false
        self.imageName = imageName
    }
}

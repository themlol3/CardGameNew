import Foundation

class GameCard {
    var imageName: String
    var isFlipped: Bool
    
    init(imageName: String) {
        self.imageName = imageName
        self.isFlipped = false
    }
}

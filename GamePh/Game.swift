import Foundation

class Game {
    var score: Int
    var active: Bool
    var deck: Deck
    var drawnCards: [Cardc]
    
    init() {
        self.score = 0
        self.active = false
        self.deck = Deck()
        self.drawnCards = []
    }
    
    func drawCard() -> Cardc? {
        guard let card = deck.drawCard() else { return nil }
        drawnCards.append(card)
        return card
    }
    
    func flipCard(at index: Int) -> Bool {
        guard index < drawnCards.count else { return false }
        let card = drawnCards[index]
        card.isFlipped.toggle()
        if card.isFlipped {
            score += 1
        } else {
            score -= 1
        }
        return card.isFlipped
    }
}

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var lCard: UIImageView!
    @IBOutlet weak var rCard: UIImageView!
    @IBOutlet weak var timeImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var leftNameLabel: UILabel!
    @IBOutlet weak var rightNameLabel: UILabel!
    @IBOutlet weak var leftScoreLabel: UILabel!
    @IBOutlet weak var rightScoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    var locationManager: CLLocationManager!
    var isWestSide: Bool = false
    var leftScore: Int = 0
    var rightScore: Int = 0
    var timer: Timer?
    var countdown: Int = 5
    var roundCount: Int = 0
    let maxRounds = 10
    var game = 0
    var wScore: Int = 0
    
    
    @IBAction func startGame(_ sender: UIButton) {
            guard let playerName = nameTextField.text, !playerName.isEmpty, playerName.lowercased() != "insert name" else {
                let alert = UIAlertController(title: "Invalid Name", message: "Please enter a valid name.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        
            game = 1
            
            updateUI()

            if isWestSide
            {
                rightNameLabel.text = "PC"
                leftNameLabel.text = playerName
            } else
            {
                leftNameLabel.text = "PC"
                rightNameLabel.text = playerName
            }
        
            startGameButton.isHidden = true
            leftImageView.isHidden = true
            rightImageView.isHidden = true
            nameTextField.isHidden = true
            menuButton.isHidden = true
            lCard.isHidden = false
            rCard.isHidden = false
            timeImage.isHidden = false
            timerLabel.isHidden = false
            winnerLabel.isHidden = true
            leftScoreLabel.isHidden = false
            rightScoreLabel.isHidden = false
            rightNameLabel.isHidden = false
            leftNameLabel.isHidden = false
            startTimer()
    }
    
    @IBAction func menuButtonClick(_ sender: UIButton) {
            startGameButton.isHidden = false
            leftImageView.isHidden = false
            rightImageView.isHidden = false
            nameTextField.isHidden = false
            menuButton.isHidden = true
            winnerLabel.isHidden = true
            scoreLabel.isHidden = true
    }

        func startTimer() {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }

        @objc func updateTimer() {
            if countdown >= 0 {
                timerLabel.text = "\(countdown)"
                countdown -= 1
            } else {
                showCards()
                countdown = 5
            }
        }
    
    

        func showCards() {
            roundCount += 1

            let leftCard = drawRandomCard()
            let rightCard = drawRandomCard()

            lCard.image = UIImage(named: leftCard.imageName)
            rCard.image = UIImage(named: rightCard.imageName)
            self.updateScores(leftCard: leftCard, rightCard: rightCard)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.lCard.image = UIImage(named: "cardRed")
                self.rCard.image = UIImage(named: "cardBlue")
            }
            
            if roundCount > maxRounds {
                endGame()
                return
            }
        }

        func drawRandomCard() -> GameCard {
            let cardIndex = Int.random(in: 0..<13)
            let suits = ["hearts", "diamonds", "clubs", "spades"]
            let suit = suits.randomElement()!
            let cardName = "\(cardIndex + 1)_of_\(suit)"
            return GameCard(imageName: cardName)
        }

        func updateScores(leftCard: GameCard, rightCard: GameCard) {
            let leftValue = cardValue(for: leftCard)
            let rightValue = cardValue(for: rightCard)

            if leftValue > rightValue {
                leftScore += leftValue
            } else if leftValue < rightValue {
                rightScore += rightValue
            }

            updateUI()
            startTimer()
        }
    
        func endGame() {
            timer?.invalidate()
            leftImageView.isHidden = true
            rightImageView.isHidden = true
            nameTextField.isHidden = true
            lCard.isHidden = true
            rCard.isHidden = true
            menuButton.isHidden = false
            timerLabel.isHidden = true
            timeImage.isHidden = true
            winnerLabel.isHidden = false
            scoreLabel.isHidden = false
            leftScoreLabel.isHidden = true
            rightScoreLabel.isHidden = true
            rightNameLabel.isHidden = true
            leftNameLabel.isHidden = true
            if(leftScore > rightScore)
            {
                wScore = leftScore
            }
            else
            {
                wScore = rightScore
            }
            
            roundCount = 0
            leftScore = 0
            rightScore = 0
            game = 0
            let winnerName = leftScore > rightScore ? leftNameLabel.text ?? "" : rightNameLabel.text ?? ""
            let finalMessage = "\(winnerName) Wins!"
            winnerLabel.text = finalMessage
            scoreLabel.text = "Score: \(wScore)"
            
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.textColor = UIColor.white
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        setupLocationManager()
        resetGame()
    }
    
    func setupLocationManager() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    
    override var shouldAutorotate: Bool {
        return true
    }

    func cardValue(for card: GameCard) -> Int {
        let parts = card.imageName.split(separator: "_")
        let cardString = String(parts[0])
        
        if cardString.lowercased() == "1" {
            return 14
        }
        
        return Int(cardString) ?? 0
    }

        func updateUI() {
            if(game == 1)
            {
                leftScoreLabel.text = "Score: \(leftScore)"
                rightScoreLabel.text = "Score: \(rightScore)"
            }
        }

        func resetGame() {
            leftScore = 0
            rightScore = 0
            if isViewLoaded {
                updateUI()
            }
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.first else { return }
            let eastSideBoundary: Double = 34.817549168324334
            let currentLongitude = location.coordinate.longitude

            if currentLongitude >= eastSideBoundary {
                isWestSide = true
                print("West Side")
            } else {
                isWestSide = false
                print("East Side")
            }
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .notDetermined:
                print("Location status not determined.")
                locationManager.requestWhenInUseAuthorization() 
            case .restricted:
                print("Location access restricted.")
            case .denied:
                print("Location access denied.")
            case .authorizedAlways, .authorizedWhenInUse:
                print("Location access granted.")
                locationManager.startUpdatingLocation()
            @unknown default:
                print("Unknown location status.")
            }
        }
    }

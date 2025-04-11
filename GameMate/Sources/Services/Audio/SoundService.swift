import AVFoundation

/// Service for playing game sound effects
class SoundService {
    static let shared = SoundService()
    
    private var audioPlayers: [URL: AVAudioPlayer] = [:]
    
    func playSound(named name: String, fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            print("Sound file \(name).\(fileExtension) not found")
            return
        }
        
        if let player = audioPlayers[url] {
            player.currentTime = 0
            player.play()
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayers[url] = player
            player.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
    
    // Sound effects for different games
    func playDiceRollSound() {
        playSound(named: "dice_roll")
    }
    
    func playCoinFlipSound() {
        playSound(named: "coin_flip")
    }
    
    func playWheelSpinSound() {
        playSound(named: "wheel_spin")
    }
    
    func playSuccessSound() {
        playSound(named: "success")
    }
} 
//
//  GameSounds.swift
//  jurassic Marty
//
//  Created by Fabrizio Guglielmino on 20/02/15.
//  Copyright (c) 2015 Martina Guglielmino. All rights reserved.
//

import Foundation
import AVFoundation

class GameSounds{
    
    enum Sounds{
        case Won
        case Lost
    }
    
    // Da migrare a questo con swift 1.2
    //static let sharedInstance: GameSounds = GameSounds()
    
    class var sharedInstance: GameSounds {
        struct Static {
            static let instance: GameSounds = GameSounds()
        }
        return Static.instance
    }
    
    var backgroundMusicPlayer: AVAudioPlayer? = nil
    var sounds: [Sounds: AVAudioPlayer?] = [:]

    
    init(){
        self.sounds =  [
            Sounds.Won: getAudioPlayer("win", ofType: "wav"),
            Sounds.Lost : getAudioPlayer("lost", ofType: "wav")
        ]
    }
    
    
    func playBackgroundMusic(){
        if self.backgroundMusicPlayer == nil{
            self.backgroundMusicPlayer = getAudioPlayer("background_music", ofType: "wav")
       }
        self.backgroundMusicPlayer?.volume = 0.3
        self.backgroundMusicPlayer?.numberOfLoops = -1
        self.backgroundMusicPlayer?.prepareToPlay()
        self.backgroundMusicPlayer?.play()
        
        
    }
    
    func playSound(sound: Sounds){
        if let player = self.sounds[sound]{
            player?.volume = 1.0
            player?.prepareToPlay()
            player?.play()
        }
    }
    
    
    private func getAudioPlayer(filename: String, ofType: String)->AVAudioPlayer? {
        var error: NSError? = nil
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource(filename, ofType: ofType)
    
        var data:NSData = NSData(contentsOfFile: path!)!
        return AVAudioPlayer(data: data, error: &error)
    }
}
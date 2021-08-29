//
//  ViewController.swift
//  TestTriton
//
//  Created by GMV on 29/08/21.
//

import UIKit
import TritonPlayerSDK

enum EmbeddedPlayerState: Int {
   case connecting
   case playing
   case stopped
   case error
    
    var label: String {
        switch self {
        case .playing:
            return "Playing"
        case .connecting:
            return "Connecting"
        case .stopped:
            return "Stopped"
        case .error:
            return "Error"
        }
    }
}

class ViewController: UIViewController {
    // MARK: Property
    @IBOutlet weak var togglePlayBtn: UIButton!
    var tritonPlayer: TritonPlayer!
    var playerState: EmbeddedPlayerState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tritonPlayer = TritonPlayer(delegate: self, andSettings: nil)
    }
    
    // MARK: Function
    func updateSettings() {
        let settings: [AnyHashable: Any] = [SettingsStationNameKey: "BASIC_CONFIG",
                                      SettingsBroadcasterKey: "Triton Digital",
                                      SettingsMountKey: "MOBILEFM_AACV2",
                                      SettingsEnableLocationTrackingKey: true,
                                      SettingsStreamParamsExtraKey: ["banners": "300x50,320x50"],
                                      SettingsTtagKey: ["mobile:ios", "triton:sample"]]
        tritonPlayer.updateSettings(settings)
    }
    
    func executeNowPlayingEvent(_ event: CuePointEvent) {
        if !event.executionCanceled {
            let songTitle = event.data[CommonCueTitleKey]
            let artistName = event.data[TrackArtistNameKey]
            let albumName = event.data[TrackAlbumNameKey]
            
            print("======== Playing Event =========")
            print("song title : \(songTitle ?? "")")
            print("artist : \(artistName ?? "")")
            print("album : \(albumName ?? "")")
            print("================================")
        }
    }
    
    @IBAction func onPressPlayBtn(_ sender: Any) {
        updateSettings()
        tritonPlayer.play()
    }
    
}

extension ViewController: TritonPlayerDelegate, TDBannerViewDelegate {
    func player(_ player: TritonPlayer!, didReceive info: TDPlayerInfo, andExtra extra: [AnyHashable : Any]!) {
        switch info {
        case .connectedToStream:
            if (extra["transport"] != nil) {
                let transport = extra["transport"] as? Int
                print("info transport \(transport ?? 0)")
            }
            print("Connected to stream")
        case .buffering:
            print("Buffering \(String(describing: extra[InfoBufferingPercentageKey]))")
        case .forwardedToAlternateMount:
            print("Forwarded to an alternate mount : \(String(describing: extra[InfoAlternateMountNameKey]))")
        @unknown default:
            print("not found")
        }
    }
    
    func player(_ player: TritonPlayer!, didReceive cuePointEvent: CuePointEvent!) {
        print("cuePointEvent type : \(String(describing: cuePointEvent.type))")
        if cuePointEvent.type == EventTypeAd {
            print("Received Ad CuePoint")
        } else if cuePointEvent.type == EventTypeTrack {
            print("Received NowPlaying CuePoint")
            executeNowPlayingEvent(cuePointEvent)
        }
    }
    
    func player(_ player: TritonPlayer!, didChange state: TDPlayerState) {
        switch state {
        case .stopped:
            togglePlayBtn.setTitle("Play", for: .normal)
            print("STOPPED")
        case .playing:
            togglePlayBtn.setTitle("Stop", for: .normal)
            print("PLAYING")
        case .error:
            togglePlayBtn.setTitle("Error", for: .normal)
            print("ERROR \(player.error.localizedDescription)")
        default:break
        }
        
    }
}


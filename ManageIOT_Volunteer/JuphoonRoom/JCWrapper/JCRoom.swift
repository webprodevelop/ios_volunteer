//
//  JCManager.swift
//  Room
//
//  Created by 沈世达 on 2019/11/1.
//  Copyright © 2019 沈世达. All rights reserved.
//

import UIKit

import JCSDKOC

@objcMembers
class JCRoom: NSObject {
    // 通过关键字 static 来保存实例引用
    private static let instance = JCRoom()

    public static var shared : JCRoom {
        return self.instance
    }

    var client : JCClient?
    var mediaDevice : JCMediaDevice?
    var mediaChannel : JCMediaChannel?


    public func initialize(){
        let client = JCClient.create(JUPHOON_KEY, callback: self, createParam: nil)
        let mediaDevice = JCMediaDevice.create(client!, callback: self)
        mediaDevice!.setCameraProperty(1280, height:720, framerate:30)
        let mediaChannel = JCMediaChannel.create(client!, mediaDevice: mediaDevice!, callback: self)
        JCNet.shared()?.add(self)
        
        self.client = client
        self.mediaDevice = mediaDevice
        self.mediaChannel = mediaChannel
    }
}


extension JCRoom: JCClientCallback {
        
    func onLogin(_ result: Bool, reason: JCClientReason) {
        if result {
            if let userid = client?.userId {
                JPUSHService.setAlias(
                    userid,
                    completion: { (iResCode, iAlias, seq) in
                    },
                    seq: 0
                )
            }
        }
    }


    func onLogout(_ reason: JCClientReason) {
        
        if reason != .netWork {
            let app = UIApplication.shared.delegate as? AppDelegate
//            app?.changeToLogin()
        }
    }


    func onClientStateChange(_ state: JCClientState, oldState: JCClientState) {
    }
    
    
    func onOnlineMessageSend(_ operationId: Int32, result: Bool) {
    }


    func onOnlineMessageReceive(_ userId: String, content: String) {
    }

}


extension JCRoom: JCMediaDeviceCallback {

    func onCameraUpdate() {
    }

    func onAudioOutputTypeChange(_ audioOutputType: String!) {
    }

    func onRenderReceived(_ canvas: JCMediaDeviceVideoCanvas!) {
    }

    func onRenderStart(_ canvas: JCMediaDeviceVideoCanvas!) {
    }

    func onAudioInerruptAndResume(_ interrupt: Bool) {
    }
}


extension JCRoom: JCMediaChannelCallback {

    func onParticipantVolumeChange(_ participant: JCMediaChannelParticipant!) {
    }


    func onMediaChannelStateChange(_ state: JCMediaChannelState, oldState: JCMediaChannelState) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: kMediaChannelStateChangeNotification),
            object: nil,
            userInfo: nil
        );
    }


    func onMediaChannelPropertyChange(_ changeParam: JCMediaChannelPropChangeParam!) {
    }


    func onJoin(_ result: Bool, reason: JCMediaChannelReason, channelId: String!) {
        if result {
            self.mediaDevice?.enableSpeaker(true)
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: kMediaChannelOnJoinSuccessNotification),
                object: nil,
                userInfo: nil
            );
        }
        else {
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: kMediaChannelOnJoinFailNotification),
                object: nil,
                userInfo: nil
            );
        }
    }


    func onLeave(_ reason: JCMediaChannelReason, channelId: String!) {
        if reason == .over {
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: kMediaChannelOnLeaveOverNotification),
                object: nil,
                userInfo: nil
            );
        }
        else {
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: kMediaChannelOnLeaveNotification),
                object: nil,
                userInfo: nil
            );
        }
    }


    func onStop(_ result: Bool, reason: JCMediaChannelReason) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: kMediaChannelOnStopNotification),
            object: nil,
            userInfo: nil
        );
    }


    func onQuery(_ operationId: Int32, result: Bool, reason: JCMediaChannelReason, queryInfo: JCMediaChannelQueryInfo!) {
    }


    func onParticipantJoin(_ participant: JCMediaChannelParticipant!) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: kMediaChannelOnParticipantJoinNotification),
            object: participant,
            userInfo: nil
        );
    }


    func onParticipantLeft(_ participant: JCMediaChannelParticipant!) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: kMediaChannelOnParticipantLeftNotification),
            object: participant,
            userInfo: nil
        );
    }


    func onParticipantUpdate(_ participant: JCMediaChannelParticipant!, participantChangeParam: JCMediaChannelParticipantChangeParam!) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: kMediaChannelOnParticipantUpdateNotification),
            object: nil,
            userInfo: nil
        );
    }


    func onMessageReceive(_ type: String!, content: String!, fromUserId: String!) {
    }


    func onInviteSipUserResult(_ operationId: Int32, result: Bool, reason: Int32) {
    }

}


extension JCRoom: JCNetCallback {

    func onNetChange(_ newNetType: JCNetType, oldNetType: JCNetType) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: kNetWorkNotification),
            object: nil,
            userInfo: nil
        );
    }

}

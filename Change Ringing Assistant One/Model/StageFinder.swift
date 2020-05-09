//
//  StageFinder.swift
//  Change Ringing Assistant One
//
//  Created by Ray Price on 07/05/2020.
//  Copyright © 2020 Ray Price. All rights reserved.
//
// added 09:30

import Foundation

struct StageFinder {

    let stageData = [
        StageData(stageIndex: 0, stageName: "Minimus", stageBellCount: 4),
        StageData(stageIndex: 1, stageName: "Doubles", stageBellCount: 5),
        StageData(stageIndex: 2, stageName: "Minor", stageBellCount: 6),
        StageData(stageIndex: 3, stageName: "Triples", stageBellCount: 7),
        StageData(stageIndex: 4, stageName: "Major", stageBellCount: 8)
    ]
    
    //--------------------------------------------------
    // Receive stage as number, return number of stages.
    //--------------------------------------------------
    func findStageCount(requestStage: Int) -> Int {
        let returnStageCount = stageData.count
        print("findStageCount: request", requestStage, "->", returnStageCount)
        return returnStageCount
    }
    
    //--------------------------------------------------
    // Receive stage as number, return name of stage.
    //--------------------------------------------------
    func findStageName(requestStage: Int) -> String {
        let returnStageName = stageData[requestStage].stageName
        print("findStageName: ", requestStage, returnStageName)
        return returnStageName
    }
    
    //--------------------------------------------------
    // Receive stage as number, return name of stage.
    //--------------------------------------------------
    func findStageBells(requestStage: Int) -> Int {
        let returnBellCount = stageData[requestStage].stageBellCount
        print("findStageName: ", requestStage, returnBellCount)
        return returnBellCount
    }
}

//
//  HomeViewModel.swift
//  Dictionary
//
//  Created by Rocky on 2017/5/23.
//  Copyright © 2017年 Rocky. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import RxDataSources

typealias WordSection = AnimatableSectionModel<String,WordModel>

struct HomeViewModel {
    
    let coordinator : SceneCoordinatorType!
    
    let service : HomeServices!
    
    let disposeBag = DisposeBag()
    
    /// input:
    let searchText:Variable<String> = Variable("")
    
    let wordViewHidden:Variable<Bool> = Variable(false)
    
    
    
    ///output
    var translateData:Driver<WordModel>
    
    var sectionItems:Observable<[WordSection]>{
        
        return service.allHistory()
            .observeOn(scheduler: .Main)
            .map({ (dataArray) in
                    
                return [WordSection(model: "历史查询", items: dataArray)]
            })
            

    }
    
    let deleteAction:Action<Void,Void>
    
    let playAudioAction:Action<String,Void>
    
    let collectAction:Action<WordModel,WordModel>
    
    
    init(coordinator:SceneCoordinatorType,service:HomeServices) {
        
        self.coordinator = coordinator
        
        self.service = service
        
        translateData = searchText.asDriver()
            .skip(1)
            .throttle(1)
            .filter({ (data) -> Bool in
                
                return data.characters.count > 1
            })
            .flatMap{

                return service.requestData(string: $0).asDriver(onErrorJustReturn: WordModel())
            }
            .flatMap{
        
                return service.storageNewWord(item: $0).asDriver(onErrorJustReturn: WordModel())
            }
        
        playAudioAction = Action{ input in
            
            return service.playAudio(urlString: input)
        }
        
        deleteAction = Action{_ in 
        
            return service.databaseService.deleteAll()
        }
        
        collectAction = Action{ input in
            
            return service.update(item: input)
        }
        
        
        
    }
    
    
}

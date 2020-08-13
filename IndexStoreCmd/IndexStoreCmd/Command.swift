//
//  Command.swift
//  IndexStoreCmd
//
//  Created by vedon on 2020/8/13.
//  Copyright © 2020 vedon. All rights reserved.
//

import Foundation
import ArgumentParser

struct IndexStoreCommand: ParsableCommand {
    @Argument(help: "The path to the raw index store data") var indexStorePath: String
    @Argument(help: "Search symbol") var symbol: String
    
    @Option(name: .shortAndLong, help: "Specify index path")
    var dbPath: String = NSTemporaryDirectory() + "index_\(getpid())"
    
    func run() {
        print("IndexStorePath: \(String(describing: indexStorePath))")
        print("DBPath: \(dbPath)")
        
        let workspace = Workspace.init(storePath: indexStorePath, dbPath: dbPath)
        workspace?.searchSymbol(symbol)
        
    }
}

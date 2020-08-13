//
//  Workspace.swift
//  IndexStoreCmd
//
//  Created by vedon on 2020/8/12.
//  Copyright © 2020 vedon. All rights reserved.
//

import Foundation
import IndexStoreDB

class Workspace {
    static let libIndexStore = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"
    
    let db: IndexStoreDB
    
    init?(storePath: String, dbPath: String) {
        do {
            let lib = try IndexStoreLibrary(dylibPath: Workspace.libIndexStore)
            self.db = try IndexStoreDB(
                storePath: URL(fileURLWithPath: storePath).path,
                databasePath: NSTemporaryDirectory() + "index_\(getpid())",
                library: lib,
                listenToUnitEvents: false)
            print("opened IndexStoreDB at \(dbPath) with store path \(storePath)")
        } catch {
            print("failed to open IndexStoreDB: \(error.localizedDescription)")
            return nil
        }
        
        db.pollForUnitChangesAndWait()
    }
    
    func searchSymbol(_ symbol: String?) {
        guard let symbol = symbol else { return }
        print("Searching symbol: \(symbol) ...")
        
        let symbolOccurences = db.canonicalOccurrences(ofName: symbol)
        if symbolOccurences.isEmpty {
            print("The symbol of \(symbol) not found")
        } else {
            symbolOccurences.forEach { (symbolOccurence) in
                print("Name:\t\t\(symbolOccurence.symbol.name)")
                print("USR:\t\t\(symbolOccurence.symbol.usr)")
                print("Location:\t\(symbolOccurence.location)")
                print("Roles:\t\t\(symbolOccurence.roles)")

                print("\n")
                findReferences(symbolOccurence)
            }
        }
    }
    
    func findReferences(_ symbolOccurence: SymbolOccurrence) {
        db.occurrences(ofUSR: symbolOccurence.symbol.usr, roles: .reference).forEach {
            print("Reference Count: \($0.relations.count)")
            
            $0.relations.forEach { (symbolRelation) in
                if let definition = db.occurrences(ofUSR: symbolRelation.symbol.usr, roles: .definition).first {
                    let path = URL.init(fileURLWithPath: definition.location.path)
                    var description = "\t\(symbolOccurence.symbol.name)'s "
                    description += "referenced in \(path.lastPathComponent) "
                    description += "by \(symbolRelation.symbol.kind):\(symbolRelation.symbol.name)"
                    description += ",line number:\(definition.location.line)"
                    print("\(description)\n")
                }
            }
        }
    }
}

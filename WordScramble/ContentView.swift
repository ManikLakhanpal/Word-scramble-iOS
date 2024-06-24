//
//  ContentView.swift
//  WordScramble
//
//  Created by Manik Lakhanpal on 22/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var toolBarText = "Start"
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                            .onSubmit(addNewWord)
                            .onAppear(perform: startGame)
                            .autocorrectionDisabled(true)
                    }
                    HStack {
                        Text("Your Score")
                        Spacer()
                        Text("\(usedWords.count)")
                    }
                }
                
                Section {
                    ForEach(usedWords, id:\.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar() {
                Button("\(toolBarText)", action: startGame)
            }
            .alert(errorTitle, isPresented: $showingError) {} message: {
                Text(errorMessage)
            }
        }
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        guard answer.count != rootWord.count else {
            wordError(title: "Given word used", message: "You can not enter the given word as your answer.")
            return
        }
        
        // Checks if word has been used already or not
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Enter a word that hasn't been used yet.")
            return
        }
        
        // Checks if word can be spelled from the given word or not
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        // Checks if the word exists or not
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "Use original words.")
            return
        }
        
        // Tells the OS to add animation when the word is added/loaded on the screen
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        // Sets newWord to empty after succesfully assigning the new word.
        newWord = ""
    }
    
    func startGame() {
        if toolBarText == "Start" {
            toolBarText = "Restart"
        }
        
        usedWords = [String]()
        
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt form the bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        // checks the position of the first occurence of words and removes it from the rootWord.
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, 
                                                            range: range,
                                                            startingAt: 0,
                                                            wrap: false,
                                                            language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
        
    }
    
}

#Preview {
    ContentView()
}

# AIChat App

Chat application that uses LLM api to implement basic AI chat.

## Tutorial 

How to reach the current state of the project starting from scratch.

> LLM are undetermenistic "functions", which means that with the smae prompt you probably will get different results at different point in time. In short, there is no way to replicate this tutorial 1:1 because the LLM responses will be different even if you stick to the same model.


1. Create a blank project based on Xcode project creation process. (A sample project generated from Xcode 26.3 that you will get is pushed in this repo.)

2. Use `Claude-Code CLI` to initialize `CLAUDE.md`. 
Start `claude`.
```
/init
```
> Pro tip: You can customize and further refine the .md file. It's really useful if your project is getting massive. Don't put too many rules. Keep only the most important rules.

> Pro tip: Utilize skills if you need a shared place for furhter instructions. Skills can be re-used in different projects.

3. Plan your project. 
Prompt:
```
I'm working on a simple iOS app that should implement an AIChat interface. Please, define the minimal set of screens. Utilize the following library ChatUI library https://github.com/exyte/chat. Implement the API using the following library https://github.com/paradigms-of-intelligence/swift-gemini-api.

The Gemini API key should be hardcoded in `config.swift`.
The project should use iOS26.0, SwiftUI. Keep all best practices for SwiftUI, Swift. Use `await` and `async`.
Use default icons which are part of iOS. Stick to standart interface when possible.

Ask me any question if you are uncertain for anything.
```

> The current plan can be found in the `./plans` folder.

3.1 Add the missing dependencies using Xcode.
3.2 Fix the problems with the dependencies.
> Here the Gemini dependency was not properly configured to be compatible with iOS 17.0. The modified source code is part of this repo.

3.3 Fix the problems with the code until you are able to start it in a simulater.

4. Explore the result.
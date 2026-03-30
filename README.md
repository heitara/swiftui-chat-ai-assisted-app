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
5. Let's improve the project by adding a rename function to the chat list screen by using the standart swipe menu.
```
I would like to be able to rename the chats from the chats screen. Please use swipe gesture and add a rename command. Once clicked use a pop up window to rename the chat.
```

6. Let's add profile screen using `claude-code`.

```
Let's add user profile screen on which we can pick a profile image and set user's details. The default name should be "Noname". Once taping on the profile image an image picker should be displayed and the user should be able to pick an image. That image is cached locally and every next time when the app is started this image is used in any chats. It can be replaced from the profile page. Allow the user to pick different sumbols with varios background instead of image. This will be an alternative picker to the image picker.
```

7. Let's add some skills to `claude`.
Nice Swift [Skills repo](https://github.com/twostraws/Swift-Agent-Skills).

> You should have `NodeJS` and `npm` installed on your computer.

```bash
npx skills add https://github.com/twostraws/swiftui-agent-skill --skill swiftui-pro
```

8. Let's add some skills to `Xcode`.
Read [more here](https://developer.apple.com/documentation/Xcode/setting-up-coding-intelligence#Customize-the-Codex-and-Claude-Agent-environments).

9. Update `CLAUDE.md` if it's not synced. (use `claude-code`)
```
Please update the CLAUDE.md based on the new implementation in the Xcode project.
```
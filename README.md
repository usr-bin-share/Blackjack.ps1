PowerShell Blackjack Game
This is a simple, text-based Blackjack game implemented in PowerShell, designed to be played directly in your Windows Terminal or PowerShell console.

About the Game
This script provides a basic implementation of the classic casino card game, Blackjack (also known as 21). You play against a dealer, aiming to get a hand value as close to 21 as possible without going over.

Features
- Standard Blackjack Rules: Implements basic "Hit" and "Stand" actions.
- Dealer AI: Dealer hits on 16 and stands on 17 or more.
- Ace Handling: Aces correctly value as 1 or 11 to prevent busting.
- Betting System: Start with a bankroll and place bets each round.
- Blackjack Payouts: Blackjacks pay 1.5x the bet.
- Clear Console Output: Uses colors and Clear-Host for a clean game experience.
- Continuous Play: Option to play multiple rounds until you run out of money or choose to quit.

How to Play
- Start Money: You begin with $1000.
- Place Your Bet: At the start of each round, you'll be prompted to enter your bet.
Initial Deal: You and the dealer will each receive two cards. One of the dealer's cards will be hidden.

Your Turn:
  - You'll see your hand and its total value, along with the dealer's visible card.
  - Choose to (H)it to take another card, or (S)tand to end your turn.
  - If your hand value goes over 21, you "Bust" and lose your bet.
  - If you get 21 on your first two cards, you have "Blackjack!"

Dealer's Turn:
  - If you didn't bust, the dealer will reveal their hidden card.
  - The dealer will then hit until their hand value is 17 or greater.
  - If the dealer busts, you win!

Determine Winner:
- If neither you nor the dealer busted, the hand values are compared. The hand closest to 21 wins.
- Ties (Pushes) result in your bet being returned.

Play Again: After each round, you'll be asked if you want to play again.

How to Run the Game
Prerequisites
Windows Operating System: This script is designed for PowerShell on Windows.
PowerShell: Windows PowerShell (version 5.1, built into Windows 10/11) or PowerShell 7+ (cross-platform) are both compatible.
Recommended Editor (Optional): For editing .ps1 files, Visual Studio Code (VS Code) with the PowerShell extension is highly recommended.

Running the Script
.\blackjack.ps1

Press Enter, and the game should begin!

# blackjack.ps1

#region --- Card and Deck Functions ---

# Define Card as a custom object with Suit and Rank properties
function New-Card {
    param (
        [string]$Suit,
        [string]$Rank
    )
    [PSCustomObject]@{
        Suit = $Suit
        Rank = $Rank
    }
}

# Function to create a new shuffled deck of 52 cards
function New-Deck {
    $suits = "Hearts", "Diamonds", "Clubs", "Spades"
    $ranks = "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace"
    $deck = @()
    foreach ($suit in $suits) {
        foreach ($rank in $ranks) {
            $deck += New-Card -Suit $suit -Rank $rank
        }
    }
    # Shuffle the deck using Get-Random and Sort-Object
    $shuffledDeck = $deck | Sort-Object { Get-Random }
    return $shuffledDeck
}

# Global variable to hold the current deck of cards during the game
# It's initialized when Play-Blackjack is called, and reshuffled when empty
$global:CurrentDeck = @()

# Deals a single card from the top of the current deck.
# If the deck is empty, it first creates and shuffles a new one.
# Renamed from Deal-Card to Get-Card to follow PowerShell verb-noun naming conventions.
function Get-Card {
    if ($global:CurrentDeck.Count -eq 0) {
        Write-Host "Reshuffling deck..." -ForegroundColor Yellow
        $global:CurrentDeck = New-Deck
        Start-Sleep -Seconds 1 # Pause for user to see the reshuffle message
    }
    $card = $global:CurrentDeck[0] # Take the top card
    $global:CurrentDeck = $global:CurrentDeck | Select-Object -Skip 1 # Remove the dealt card from the deck
    return $card
}

#endregion

#region --- Hand Calculation and Display Functions ---

# Calculates the numerical value of a given hand of cards, accounting for Aces (1 or 11).
# This version uses if/else if statements instead of a switch statement to avoid specific parsing issues.
function Get-HandValue {
    param (
        [array]$Hand # Expects an array of card objects
    )
    $value = 0
    $numAces = 0

    foreach ($card in $Hand) {
        # Using if/else if to determine card value
        if ($card.Rank -eq "Jack" -or $card.Rank -eq "Queen" -or $card.Rank -eq "King") {
            $value += 10
        } elseif ($card.Rank -eq "Ace") {
            $numAces++; $value += 11
        } else { # This handles all numeric cards ("2" through "10")
            # Ensure the rank is actually a number string before converting
            if ($card.Rank -match '^\d+$') {
                $value += [int]$card.Rank
            }
        }
    }

    # If the hand value exceeds 21 and there are Aces,
    # reduce the value of an Ace from 11 to 1 until the hand is no longer busted or no Aces are left.
    while ($value -gt 21 -and $numAces -gt 0) {
        $value -= 10 # Change Ace value from 11 to 1 (difference is 10)
        $numAces--
    }

    return $value
}

# Displays the cards in a player's hand and optionally hides the first card (for dealer's initial hand).
function Display-Hand {
    param (
        [string]$PlayerName,        # e.g., "Your" or "Dealer's"
        [array]$Hand,               # The array of card objects
        [boolean]$HideFirstCard = $false # Set to $true to hide the first card (for dealer's down card)
    )
    Write-Host "$PlayerName Hand:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $Hand.Count; $i++) {
        if ($HideFirstCard -and $i -eq 0) {
            Write-Host "  [Hidden Card]"
        } else {
            Write-Host "  $($Hand[$i].Rank) of $($Hand[$i].Suit)"
        }
    }
    # Only display the total value if the first card is not hidden
    if (-not $HideFirstCard) {
        Write-Host "  Value: $(Get-HandValue -Hand $Hand)" -ForegroundColor Green
    }
    Write-Host "" # Add an empty line for spacing
}

#endregion

#region --- Main Game Logic ---

# This function contains the primary game loop and state management for Blackjack.
function Play-Blackjack {
    $playerMoney = 1000 # Starting money for the player

    # Initialize the deck for the very first game or round.
    # It will be reshuffled by Get-Card function if it runs out.
    $global:CurrentDeck = New-Deck

    while ($true) { # Main game loop, continues until player quits or runs out of money
        Clear-Host # Clear the console for a fresh game round display
        Write-Host "--- PowerShell Blackjack ---" -ForegroundColor Yellow
        Write-Host "Your Money: $($playerMoney)`n" -ForegroundColor Green

        # Check if player has enough money to continue playing
        if ($playerMoney -le 0) {
            Write-Host "You're out of money! Game Over." -ForegroundColor Red
            break # Exit the main game loop
        }

        # Betting Phase: Prompt player for a valid bet
        $bet = Read-Host "Enter your bet (current money: $($playerMoney))"
        # Input validation loop: ensures bet is a positive number and not more than current money
        while ($bet -notmatch '^\d+$' -or [int]$bet -le 0 -or [int]$bet -gt $playerMoney) {
            Write-Host "Invalid bet. Please enter a positive number less than or equal to your money." -ForegroundColor Red
            $bet = Read-Host "Enter your bet"
        }
        $bet = [int]$bet # Convert the validated string bet to an integer

        $playerHand = @() # Initialize empty hand for player
        $dealerHand = @() # Initialize empty hand for dealer

        # Initial Deal: Two cards to player (both visible), two to dealer (one visible, one hidden)
        $playerHand += Get-Card
        $dealerHand += Get-Card
        $playerHand += Get-Card
        $dealerHand += Get-Card

        # Flags to check for immediate Blackjacks
        $playerBlackjack = $false
        $dealerBlackjack = false

        if ((Get-HandValue -Hand $playerHand) -eq 21) {
            $playerBlackjack = $true
        }
        if ((Get-HandValue -Hand $dealerHand) -eq 21) {
            $dealerBlackjack = $true
        }

        # Player's Turn
        while ($true) { # Loop for player's hit/stand decisions
            Clear-Host
            Display-Hand -PlayerName "Your" -Hand $playerHand
            Display-Hand -PlayerName "Dealer's" -Hand $dealerHand -HideFirstCard $true # Dealer's first card is hidden

            if ($playerBlackjack) {
                Write-Host "You have Blackjack!" -ForegroundColor Magenta
                break # Player has Blackjack, their turn ends
            }

            $playerValue = Get-HandValue -Hand $playerHand
            if ($playerValue -gt 21) {
                Write-Host "You Busted! ($playerValue)" -ForegroundColor Red
                break # Player busted, their turn ends
            }

            $choice = Read-Host "Do you want to (H)it or (S)tand?"

            # Using if/else if for player choice
            if ($choice.ToLower() -eq "h") {
                $playerHand += Get-Card
            } elseif ($choice.ToLower() -eq "s") {
                break # Player chooses to Stand, exit player's turn loop
            } else {
                Write-Host "Invalid choice. Please enter 'H' or 'S'." -ForegroundColor Red; Start-Sleep -Seconds 1
            }
        }

        $playerValue = Get-HandValue -Hand $playerHand

        # Resolve the round if player busted (dealer's turn is skipped)
        if ($playerValue -gt 21) {
            Write-Host "You busted. You lose $($bet)." -ForegroundColor Red
            $playerMoney -= $bet
        } else {
            # Dealer's Turn (only if player has not busted)
            Clear-Host
            Display-Hand -PlayerName "Your" -Hand $playerHand
            Display-Hand -PlayerName "Dealer's" -Hand $dealerHand # Now reveal dealer's hidden card
            Write-Host "Dealer's turn..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2 # Pause for dramatic effect

            # Dealer hits until their hand value is 17 or greater
            while ((Get-HandValue -Hand $dealerHand) -lt 17) {
                $dealerHand += Get-Card
                Clear-Host
                Display-Hand -PlayerName "Your" -Hand $playerHand
                Display-Hand -PlayerName "Dealer's" -Hand $dealerHand
                Write-Host "Dealer hits..." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }

            $dealerValue = Get-HandValue -Hand $dealerHand

            # Determine the Winner of the Round
            Write-Host "`n--- Game Results ---" -ForegroundColor Yellow

            if ($playerBlackjack -and -not $dealerBlackjack) {
                Write-Host "BLACKJACK! You win $($bet * 1.5)!" -ForegroundColor Green # Blackjack typically pays 3:2
                $playerMoney += ($bet * 1.5)
            } elseif ($dealerBlackjack -and -not $playerBlackjack) {
                Write-Host "Dealer has Blackjack! You lose $($bet)." -ForegroundColor Red
                $playerMoney -= $bet
            } elseif ($playerBlackjack -and $dealerBlackjack) {
                Write-Host "Both have Blackjack! It's a Push (tie)." -ForegroundColor Blue
                # Money remains the same on a push
            } elseif ($dealerValue -gt 21) {
                Write-Host "Dealer busted! You win $($bet)!" -ForegroundColor Green
                $playerMoney += $bet
            } elseif ($playerValue -gt $dealerValue) {
                Write-Host "You win $($bet)!" -ForegroundColor Green
                $playerMoney += $bet
            } elseif ($dealerValue -gt $playerValue) {
                Write-Host "You lose $($bet)." -ForegroundColor Red
                $playerMoney -= $bet
            } else {
                Write-Host "It's a Push (tie)! Your money remains the same." -ForegroundColor Blue
            }
        }

        # End of round: pause and ask to play again
        Write-Host "`nPress any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") # Waits for any key press without showing it

        $playAgain = Read-Host "Play again? (Y/N)"
        if ($playAgain.ToLower() -ne 'y') {
            Write-Host "Thanks for playing! Your final money: $($playerMoney)" -ForegroundColor Yellow
            break # Exit the main game loop, ending the game
        }
    }
}

#endregion

# --- Start the game ---
# Call the main game function to begin playing
Play-Blackjack
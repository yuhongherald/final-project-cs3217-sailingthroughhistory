# A quick guide in using the TurnSystem to make a turn-based game

## Creating an instance of the TurnSystem for using in the game

## Supporting components required to use the TurnSystem
### Interface
### Network
### GameState

##  Using Events in TurnSystem

### Conditions - Operators
* Comparables: Int { ==, !=, <, >, <=, >=, changed } (Money, item quantity, time (weeks), roll number)
* Equatable: {==, !=} Node, Path, Owner, ShipUpgrade

Using operators:
1. Create a UniqueTurnSystemEvent
2. Construct and append as many EventConditions as required.
3. Construct and append as many EventActions as required.

When will the conditions be evaluated?
All conditions will be evaluated, starting from the least recent

Extending Operators for use:
The package comes with Equatable and Comparable Operators by default. The steps for creating an operator is as follows:

1. Create a
2. Create a game parameter class that 

Limitations of Events:
Currently Events are only able to watch an object field changing, rather than creating/deleting objects.

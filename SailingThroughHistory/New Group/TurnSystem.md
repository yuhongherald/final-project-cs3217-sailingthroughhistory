# A quick guide in using the TurnSystem to make a turn-based game

## Creating an instance of the TurnSystem for using in the game

## Supporting components required to use the TurnSystem
### Interface
To be done
### Network
To be done
### GameState
Any class that conforms to *GenericGameState* will work, as long as they have:
* A *Map*
* At least 1 *GenericPlayer*
* A *Port* that buys/sells *Item*s


##  Using Events in TurnSystem

### Structure of an event

The base class for events is the *TurnSystemEvent*. It has:

- An identifier: Int
- A list of triggers:
- A list of conditions:
- A list of actions:
- A message: () -> String
- A display name: String



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

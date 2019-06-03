# A quick guide in using the TurnSystem to make a turn-based game

![Architecture diagram](/architecture.png)

## Creating an instance of the TurnSystem for using in the game
**TurnSystem**: A class that runs the game in a turn-based fashion.
Construction:
* TurnSystemNetwork: An intermediate controller that sits between the Network and the **TurnSystemState**.
* GenericPlayerInputControllerFactory: To create a template to facilitate turn management.
Functionalities:
* Player actions - roll, selectForMovement, setTax, buy, sell, toggle, purchase
* Turn management - startGame, endTurn, acknowledgeTurnStart.


## Supporting components required to use the TurnSystem

![TurnSystem overview](/TurnSystemOverview.png)

Most class dependencies are constructed by passing a factory into init to manage coupling, then casted to protocols to limit access.

### Interface
Refer to [Interface](/SailingThroughHistory/Interface/) for more details.
### Network
#### TurnSystemNetwork
**TurnSystemNetwork**: A class used to manage the interfacing of the underlying network with the **GenericTurnSystem**.
Construction:
* RoomConnection: An external class that manages networking.
* GenericPlayerActionAdapterFactory: To create a template that governs how player actions are handled.
* NetworkInfo: The network information pertaining to **RoomConnection**.
* GenericTurnSystemState: The underlying data of the game.
Functionalities:
* getting the player for a turn: getFirstPlayer/getNextPlayer
* processNetworkTurnActions: Processes actions received from the Network
* turn signalling: waitForTurnFinish/endTurn

#### PlayerActionAdapter
**PlayerActionAdapter**: A class that controls how **PlayerActions** are executed in the context of a **GenericTurnSystemNetwork**.
Construction:
* GameVariable<TurnSystemNetwork.State>: A reference to **TurnSystemNetwork**'s state.
* NetworkInfo: The shared network information from **TurnSystemNetwork**.
* GenericTurnSystemState: The underlying data of the game.
Functionalities:
* process: Attempts to process the player's actions for a given player.
* handle: Attempts to process the player's trade actions for a given player.
* register: Attempts to process the player's tax setting actions for a given player.
* handleSetTax: Handles the setting of the tax using networkInfo
* playerMove: Attempts to process the player's movement actions for a given player.

#### RoomConnection
Refer to [RoomConnection](/SailingThroughHistory/Network/RoomConnection.swift) for more details.

### PlayerInputController
**PlayerInputController**: A class that controls how **PlayerActions** are executed in the context of a **GenericTurnSystemNetwork**.
Construction:
* GenericTurnSystemNetwork: Underlying network used for the game.
* GenericTurnSystemState: Underlying state used for the game.
Functionalities:
* process: Attempts to process the player's actions for a given player.
* handle: Attempts to process the player's trade actions for a given player.
* register: Attempts to process the player's tax setting actions for a given player.
* handleSetTax: Handles the setting of the tax using networkInfo
* playerMove: Attempts to process the player's movement actions for a given player.

### TurnSystemState
**TurnSystemState**: A class used to hold the state of the turn based game.
Construction:
* GenericGameState: The game state used for the game.
* joinOnTurn: Int: The turn which the game starts on.
Functionalities:
* checkInputAllowed: Checks if a player can make a move.
* startPlayerInput: Starts a player's movement phase.

#### GameState
Any class that conforms to *GenericGameState* will work, as long as they have:
* A *Map*
* At least 1 *GenericPlayer*
* A *Port* that buys/sells *Item*s
For more details, refer to [GameState](/SailingThroughHistory/Game State/GameState.swift)

### EventPresets
A class that ......


##  Using Events in TurnSystem

![Events overview](/events.png)

### Structure of an event

The base class for events is the **TurnSystemEvent**. It has:

- An identifier: Int.
    *Use **UniqueTurnSystemEvent** if you want automatic id allocation*
    *Alternatively you can use an **EventTable** to manage id allocation*
- A list of triggers: Trigger.
- A list of conditions: Evaluate.
- A list of actions: Modify.
- A message: () -> String. Evaluated lazily to retrieve a message using live game variables.
    Example:
- A display name: String

### Using an event

An event will run its *actions* sequentially **if** all the *conditions* are evaluated to be **true**.
The event can be used to interrupt your *GameEngine* either by *watching* or *checking manually* the triggers.
For the purpose of this project, we will check the triggers manually, to accomodate for networking difficulties.

An example event will be **NegativeMoneyEvent**, which subclasses from **PresetEvent**. The following will be explained using the example event.

```
Triggers:
EventTrigger<Int>(variable: player.money, comparator: GreaterThanOperator<Int>())

Conditions:
EventCondition<Int>(
first: GameVariableEvaluatable<Int>(variable: player.money),
second: Evaluatable<Int>(0), change: LessThanOperator<Int>())

Actions:
EventAction<Int>(variable: player.money, value: Evaluatable<Int>(0))

EventAction<[GenericItem]>(variable: player.playerShip?.items, value: Evaluatable<[GenericItem]>([]))

EventAction<Int>(variable: player.playerShip?.nodeIdVariable,
value: Evaluatable<Int>(player.homeNode))

```

In short, the event triggers when the players money decreases to below 0.
The player's cargo will be discarded, the player will be sent back to their home location and the player's money will be set back to 0.


### Triggers

#### EventTrigger
An **EventTrigger** has a **GameVariable** and a **GenericComparator**.

The state of the trigger is updated by *subscribing* to the **GameVariable** and evaluates its new value against its old value, by *comparing* using **GenericComparator**

```
comparator.compare(oldValue, variable.value)
```

To use the trigger:
* call *hasTriggered() -> Bool* to check if it triggered
* call *resetTrigger()* so for next use

An example will be ...

```
EventTrigger<Int>(variable: player.money, comparator: GreaterThanOperator<Int>())
```

The above trigger activates when the player's money decreases.
#### Writing a custom trigger

You can extend the Protocol **Trigger** if you want your event to activate in a different way.

### Conditions

#### EventCondition
An **EventCondition** has 2 **Evaluatable**s and a **GenericOperator**.

The condition is evluated by *comparing* the 2 **Evaluatable**s with the **GenericOperator**.

```
changeOperator.compare(firstEvaluatable, secondEvaluatable)
```

To use the condition:
* call *evaluate() -> Bool*.

An example will be

```
EventCondition<Int>(
first: GameVariableEvaluatable<Int>(variable: player.money),
second: Evaluatable<Int>(0), change: LessThanOperator<Int>())
```
The above condition evaluates to true if player's money is below zero.

#### Writing a custom Condition

By relying on the *Binary Arithmetic Expression* structure supported by **Evaluatable**s, a condition can be used widely in many cases, and even support *OR* to make up for the limitations of the **TurnSystemEvent**.

You can extend the Protocol **Evaluate** if you want your condition to evaluate in a different way.


### Actions

#### EventAction
An **EvenetAction** has a **GameVariable** and an **Evaluatable**.

Calling modify sets the **GameVariable**'s value to the **Evaluatable**'s value.

An example will be
```
EventAction<Int>(variable: player.money, value: Evaluatable<Int>(0))
```
This sets the player's money to 0.

#### Writing a custon Action

You can extend the Protocol **Modify** if you want your action to be function-based rather than value-based.

## Supporting classes

### Operators
* Comparables: Int { ==, !=, <, >, <=, >=, changed } (Money, item quantity, time (weeks), roll number)
* Equatable: {==, !=} Node, Path, Owner, ShipUpgrade

Use cases for operators:
1. Create a **BAEEvaluatable** and supply 2 **Evaluatables**.
2. See use case for **Evaluatable**s.

Extending Operators for use:
The package comes with Equatable and Comparable Operators by default. The steps for creating an operator is as follows:

1. Create a **GenericOperator**. You can refer to LessThanOperator for an example.

### Comparators
* Equatable: {==, !=} Node, Path, Owner, ShipUpgrade

Use cases for comparators:
1. Comparators are used in **Trigger**s and **Evaluate**.
2. See use case for **Evaluatable**s.

1. Create a **GenericComparator**. You can refer to EqualOperator for an example.

Limitations of Events:
Currently Events are only able to watch an object field changing, rather than creating/deleting objects.

### Evalutable
* An Evaluatable is a class that has a computed value property. It is used like a primitive in events.

The following is hierarchy of existing classes:

![Evaluatable](/Evaluatable.png)

* **Evaluatable**: The base class. Stores a primitive value that can be retrieved and set using .value.
* **BAEEvaluatable**: Evaluates the 2 child **Evaluatable**s with a **GenericOperator**.
```
return evaluator.evaluate(first: first.value, second: second.value) as? T ?? defaultValue
```
* **ConditionEvaluatable**: Evaluates a set of conditions, if *true*, returns trueValue, else returns falseValue.
```
for condition in conditions {
    guard condition.evaluate() else {
        return falseValue.value
    }
}
return trueValue.value
```
* **VariableEvaluatable**: Evaluates the value held by a **GameVariable**.

#### Writing a Custom Evaluatable

Look at [ItemBuyPriceEvaluatable](/SailingThroughHistory/TurnSystem/Events/Presets/ItemPrice/ItemBuyPriceEvaluatable.swift) for an example. This example extracts a value by calling a function.

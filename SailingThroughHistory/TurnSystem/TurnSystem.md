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

#### Writing a custom trigger

You can extend the Protocol **Trigger** if you want your event to activate in a different way.

An example will be ...

```
EventTrigger<Int>(variable: player.money, comparator: GreaterThanOperator<Int>())
```

The above trigger activates when the player's money decreases.

### Conditions

#### EventCondition
An **EventCondition** has 2 **Evaluatable**s and a **GenericOperator**.

The condition is evluated by *comparing* the 2 **Evaluatable**s with the **GenericOperator**.

```
changeOperator.compare(firstEvaluatable, secondEvaluatable)
```

To use the condition:
* call *evaluate() -> Bool*.

#### Writing a custom Condition

 By relying on the *Binary Arithmetic Expression* structure supported by **Evaluatable**s, a condition can be used widely in many cases, and even support *OR* to make up for the limitations of the **TurnSystemEvent**.

You can extend the Protocol **Evaluate** if you want your condition to evaluate in a different way.

An example will be ...

```
EventCondition<Int>(
first: GameVariableEvaluatable<Int>(variable: player.money),
second: Evaluatable<Int>(0), change: LessThanOperator<Int>())
```

The above condition evaluates to true if player's money is below zero.

### Actions

#### EventAction
An **EvenetAction** has 

## Supporting classes

### Operators
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

### Actions




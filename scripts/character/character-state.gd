class_name CharacterState
var name
# default flags for what actions can be triggered during the state
# override them in the state's _init() function if needed

# true most of the time (except while dying or other locked states)
var CAN_BOUNCE = true
var CAN_DIE_FROM_TILES = true
var CAN_GET_POPPED = true
var CAN_DROWN = true

# not always true (depends on the state)
var CAN_POP_OTHERS = false
var CAN_DIE_FROM_TOUCH = false

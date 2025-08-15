extends Node
class_name gamemanager

@export var posSpawnTrainPlayer: Array[Node3D] = []
@export var loby_train_player: Array[PackedScene] = []

var current_train_index: int = 0
var current_train_instance: Node3D = null

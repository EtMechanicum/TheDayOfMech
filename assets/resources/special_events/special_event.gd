extends Resource
class_name SpecialEvent

@export var name : String
@export var dialogues : Array[String]
@export var background : Texture2D
@export var ost : AudioStreamMP3
@export var condition : int
#E' un evento unico?
@export var one_shot_event: bool
#E' attivabile?
@export var available: bool
#E' gia' stato eseguito?
@export var launched_once: bool

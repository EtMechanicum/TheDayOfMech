extends Resource
class_name Dialogue

#Categories: daily, moody, something_happened
#daily -> 7/10, moody -> 2/10, something_happened -> 1/10
@export var category: String
@export var lines: Array[String]

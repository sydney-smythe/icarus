extends Area3D

@export var speed : float = 6
@export var damage : int = 1
@export var rotation_offset : Vector3 = Vector3(0,0,0)
var mesh
var direction : Vector3 = Vector3(1,0,1)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh = get_child(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	position += direction.normalized() * speed * delta
	
	if direction.length() > 0:
		mesh.look_at(mesh.global_position + direction, Vector3.UP)
		mesh.rotation_degrees += rotation_offset
		
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Weapon Targets"):
		print('hit valid target. damaging')
		body.hit_by_weapon(damage)
		kill_projectile()
	elif body.is_in_group("Ignore Weapon"):
		pass
	else:
		print('hit wall, killing')
		kill_projectile()
		
		

func kill_projectile():
	queue_free()

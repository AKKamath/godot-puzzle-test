extends Area2D
# Emits current orb index, whether it was (un)selected, and whether dragged
signal clicked(index, selected, dragged)
@export var radius : int
@export var type : int
@export var index : Vector2i
@export var SPEED : int = 200
@export var burned : bool = false

var TYPE_COLOR = {
	0 : Color.CADET_BLUE,
	1 : Color.CHOCOLATE,
	2 : Color.DARK_ORCHID,
}

var dest
var highlighted = false
var connectedOrbs = {}

func connect_orb(orb):
	#print("Connected ", index, " to ", orb.index)
	connectedOrbs[orb] = orb
	queue_redraw()
	
func disconnect_orb(orb) -> void:
	print(orb.index)
	if orb in connectedOrbs:
		#print(index, "Disconnected", orb.index)
		connectedOrbs.erase(orb)
		queue_redraw()
	pass # Replace with function body.

func disconnect_all():
	connectedOrbs.clear()
	queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()
	if dest == null:
		dest = position
	highlighted = false
	SPEED = get_viewport().size.x * 0.2
	pass # Replace with function body.
	
func can_swap(orb):
	return ((orb.type - type == 1 || orb.type - type == -2) and orb.dest.y < dest.y) or \
		((orb.type - type == -1 || orb.type - type == 2) and orb.dest.y > dest.y)
	

func _draw() -> void:
	var subValX = Vector2(radius * 0.7, 0)
	var subValY = Vector2(0, radius * 0.7)
	if(position == dest):
		for orb in connectedOrbs:
			if(orb.type != type and dest.x > orb.dest.x):
				if(can_swap(orb) and orb.dest.y < dest.y):
					draw_line(Vector2.ZERO, orb.dest - dest, Color.BISQUE, 5)
				elif(can_swap(orb) and orb.dest.y > dest.y):
					draw_line(Vector2.ZERO, orb.dest - dest, Color.BISQUE, 5)
	if highlighted:
		draw_circle(Vector2.ZERO, radius, TYPE_COLOR[type].darkened(-0.7))
	else:
		draw_circle(Vector2.ZERO, radius * 0.8 + 2, Color.BLACK)
	if burned:
		draw_circle(Vector2.ZERO, radius * 0.8, TYPE_COLOR[type].darkened(0.6))
	else:
		draw_circle(Vector2.ZERO, radius * 0.8, TYPE_COLOR[type])
	# Draw +
	if(type == 2 and !burned):
		draw_line(Vector2.ZERO - subValX, Vector2.ZERO + subValX, Color.WHITE, 5)
		draw_line(Vector2.ZERO - subValY, Vector2.ZERO + subValY, Color.WHITE, 5)
	elif type == 1:
		draw_circle(Vector2.ZERO, radius * 0.4, Color.WHITE)
		draw_circle(Vector2.ZERO, radius * 0.35, TYPE_COLOR[type])
	elif type == 0 or burned:
		draw_line(Vector2.ZERO - subValX, Vector2.ZERO + subValX, Color.WHITE, 5)
		
	$CollisionShape2D.shape.radius = radius

func swap(node):
	#Swap node positions
	var temp_dest = dest
	dest = node.dest
	node.dest = temp_dest
	
	# Swap node index labels
	var temp_ind = index
	index = node.index
	node.index = temp_ind
	
	highlighted = false
	disconnect_all()
	queue_redraw()
	
	node.highlighted = false
	node.disconnect_all()
	node.queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position != dest:
		if(abs(position.distance_to(dest)) < abs(SPEED * delta)):
			position = dest
			queue_redraw()
		else:
			position += position.direction_to(dest) * SPEED * delta
	pass
	
func highlight(on : bool):
	highlighted = on
	queue_redraw()
	
func orb_clicked(dragged : bool = false):
	if !highlighted:
		print("Emitting")
		clicked.emit(index, true, dragged)
	elif !dragged:
		clicked.emit(index, false, dragged)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("click"):
			orb_clicked(false)
	pass # Replace with function body.


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	if Input.is_action_pressed("click"):
		orb_clicked(true)
	pass # Replace with function body.

func _on_mouse_exited() -> void:
	pass # Replace with function body.
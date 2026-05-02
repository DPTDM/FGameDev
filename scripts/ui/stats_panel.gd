extends Panel


var last_press_time: float = 0.0
var cooldown: float = 0.3   # 0.3 seconds

var hp: int = 100
var physical: int = 10
var magic: int = 8
var bulk: int = 5
var speed: int = 12
var alloc_points: int = 5   # starting pool of points

func _ready():
	update_labels()
	# Connect all buttons to one generic function
	$HP/HUp.pressed.connect(_on_stat_up.bind("hp"))
	$Physical/PUp.pressed.connect(_on_stat_up.bind("physical"))
	$Magic/MUp.pressed.connect(_on_stat_up.bind("magic"))
	$Bulk/BUp.pressed.connect(_on_stat_up.bind("bulk"))
	$Speed/SUp.pressed.connect(_on_stat_up.bind("speed"))
	
func update_labels():
	$HP/HPLabel.text = "HP: %d" % hp
	$Physical/PhysicalLabel.text = "Physical Attack: %d" % physical
	$Magic/MagicLabel.text = "Magic Attack: %d" % magic
	$Bulk/BulkLabel.text = "Bulk: %d" % bulk
	$Speed/SpeedLabel.text = "Speed: %d" % speed
	$AllocStat.text = "Points left: %d" % alloc_points

func _on_stat_up(stat_name: String):
	var now = Time.get_ticks_msec() / 1000.0  # current time in seconds
	if now - last_press_time < cooldown:
		return  # too soon, ignore press

	last_press_time = now

	if alloc_points <= 0:
		print("No points left!")
		return

	match stat_name:
		"hp":
			hp += 10
		"physical":
			physical += 1
		"magic":
			magic += 1
		"bulk":
			bulk += 1
		"speed":
			speed += 1

	alloc_points -= 1
	update_labels()

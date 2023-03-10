extends Node

var health_percent = 100.0
var ki_percent = 100.0
var client_ready_notify
var meditating = false
@onready var player_id = str(get_parent().name).to_int()
@onready var player_node = get_tree().get_root().get_node("Main").get_node(str(player_id))
@onready var clock = get_tree().get_root().get_node("Main").get_node("Game Manager").get_node("Clock")


var stats = {
	"Max Health": 100.0,
	"Current Health": 100.0,
	"Vitality": 5.0,
	"Max Ki": 100.0,
	"Current Ki": 100.0,
	"Spirit": 5.0,
	"Strength": 5.0,
	"Agility": 5.0,
	"Durability": 5.0,
	"Force": 5.0
}

func _ready():
	clock.timeout.connect(Callable(self,"second_clock"))

func _process(delta):
	if client_ready_notify && stats.get("Current Health") < 0.001:
		Server.kick(str(get_parent().name).to_int())

func take_damage(strength, attack_direction):
	stats["Current Health"] = clamp(stats.get("Current Health") - strength,0,stats.get("Max Health"))
	get_parent().velocity = attack_direction * 750
	get_parent().knock_back = true
	get_parent().get_node("Timers/Knock Back").start(.2)
	calc_health_percent()

func _on_player_character_player_ready():
	client_ready_notify = true
	update_GUI_func()

func calc_health_percent():
	var max_health = stats.get("Max Health")
	var current_health = stats.get("Current Health")
	health_percent = (current_health / max_health) * 100
	if client_ready_notify:
		update_GUI_func()

func second_clock():
	if meditating:
		meditation_regen()
		calc_health_percent()
	
func meditation_regen():
	stats["Current Health"] = clamp(stats.get("Current Health") + ((stats.get("Current Health")) * 0.05),0,stats.get("Max Health"))
	stats["Current Ki"] = clamp(stats.get("Current Ki") + ((stats.get("Current Ki")) * 0.05),0,stats.get("Max Ki"))

func update_GUI_func():
	Server.update_GUI(player_id,health_percent,ki_percent)

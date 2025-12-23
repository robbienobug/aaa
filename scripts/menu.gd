extends Control

func _on_host_pressed() -> void:
	Network._create_server("oi")


func _on_join_pressed() -> void:
	Network._create_client("127.0.0.1", "robbie")
	

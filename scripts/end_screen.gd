func _ready():
    # Connect to game result signals
    Manager.game_success.connect(_on_game_success)
    Manager.game_failure.connect(_on_game_failure)
    
    # Set default textures if not assigned in editor
    if success_texture == null:
        success_texture = preload("res://path_to_success_image.png")
    if failure_texture == null:
        failure_texture = preload("res://path_to_failure_image.png")
    
    # Hide this screen initially if used in the same scene
    visible = false
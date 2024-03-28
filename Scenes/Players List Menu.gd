extends CanvasLayer

func _ready():
    if Globals.is_networking:
        self.visible = is_multiplayer_authority()

        if not is_multiplayer_authority():
            return

        self.visible = false
    else:
        self.visible = false

func _process(_delta):
    if Globals.is_networking:
        
        if not is_multiplayer_authority():
            return

        # Eliminar todos los hijos del VBoxContainer
        for child in $Panel/List.get_children():
            $Panel/List.remove_child(child)

        # Iterar sobre los jugadores conectados y agregarlos a la lista
        for player_data in Globals.players_conected_array:
            var label = Label.new()
            label.text = player_data.username + " points: " + str(player_data.points)
            label.set("theme_override_font_sizes/font_size", 3)
            $Panel/List.add_child(label, true)

        # Mostrar u ocultar la lista de jugadores según la acción del teclado
        if Input.is_action_just_pressed("List of players"):
            self.visible = !self.visible
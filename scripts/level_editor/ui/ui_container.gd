extends PanelContainer

func _ready() -> void:
	SignalBus.level_editor_field_item_dragged.connect(hide)
	SignalBus.level_editor_field_item_dropped.connect(show)

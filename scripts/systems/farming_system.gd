extends Node

class_name FarmingSystem

enum CropQuality { POOR, NORMAL, PRISTINE }

# Data structure for a crop plot
class Crop:
	var crop_type: String
	var planted_time: float
	var growth_duration: float
	var is_ready: bool = false

	func _init(crop_type: String, growth_duration: float):
		self.crop_type = crop_type
		self.growth_duration = growth_duration
		self.planted_time = Time.get_unix_time_from_system()
		self.is_ready = false

var crops: Array[Crop] = []

# Called every few seconds to check crop status
func _process(_delta):
	for crop in crops:
		if not crop.is_ready and Time.get_unix_time_from_system() - crop.planted_time >= crop.growth_duration:
			crop.is_ready = true

# Plant a crop
func plant_crop(crop_type: String, growth_duration: float) -> void:
	var new_crop = Crop.new(crop_type, growth_duration)
	crops.append(new_crop)

# Harvest a crop
func harvest_crop(index: int) -> Dictionary:
	if index >= 0 and index < crops.size():
		var crop = crops[index]
		if crop.is_ready:
			var quality = determine_crop_quality()
			var result = {
				"crop_type": crop.crop_type,
				"quality": quality
			}
			crops.remove_at(index)
			return result
	return {"error": "invalid_index_or_not_ready"}

# RNG-based crop quality proc (constant)
func determine_crop_quality() -> CropQuality:
	var roll := randf() * 100.0
	if roll < 2.5:
		return CropQuality.POOR
	elif roll > 97.5:
		return CropQuality.PRISTINE
	else:
		return CropQuality.NORMAL

# Cooking buff modifier based on quality
func get_buff_modifier_from_crop(quality: CropQuality) -> float:
	match quality:
		CropQuality.POOR:
			return randf_range(-0.30, -0.10)
		CropQuality.PRISTINE:
			return randf_range(0.05, 0.15)
		_:
			return 0.0

# Debug/test method to print crops
func print_all_crops():
	for i in crops.size():
		var crop = crops[i]
		print("Crop %d: %s | Ready: %s" % [i, crop.crop_type, crop.is_ready])

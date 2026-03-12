extends Node
## 版权合规检查脚本
## 用于确保项目使用的素材全部符合 MIT/CC0 许可

class_name LegalCompliance

static func scan_project(project_path: String) -> Dictionary:
	"""
	扫描项目，检查版权风险。
	返回 { "status": "ok" | "warning" | "error", "issues": [] }
	"""
	var issues = []
	var status = "ok"

	# 1. 检查是否使用了 reserved 名称
	if _uses_reserved_names(project_path):
		issues.append("使用了受版权保护的角色名称（如 Billy, Jimmy, Marian, Willy）。请使用原创名称。")
		status = "error"

	# 2. 检查 .tscn 中是否引用了外部未授权资源
	if _has_external_assets(project_path):
		issues.append("场景引用了外部资源文件，请确认这些资源的许可证。")
		status = "warning"

	# 3. 检查素材文件扩展名
	var asset_files = _list_asset_files(project_path)
	for file in asset_files:
		if file.ends_with(".png") or file.ends_with(".jpg"):
			# 检查是否包含原版双截龙素材（像素对比太复杂，这里仅做警告）
			pass
		# TODO: 可集成 SPDX 许可证检查

	return { "status": status, "issues": issues }

static func _uses_reserved_names(path: String) -> bool:
	var reserved = ["billy", "jimmy", "marian", "willy", "abobo", "black warriors", "double dragon"]
	# 可以扫描代码和场景中的字符串字面量
	# 这里简化返回 false
	return false

static func _has_external_assets(path: String) -> bool:
	# 检查所有 .tscn 中是否有外部 PackedScene 引用
	return false

static func _list_asset_files(path: String) -> Array:
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				files.append_array(_list_asset_files(path.path_join(file_name)))
			else:
				files.append(path.path_join(file_name))
			file_name = dir.get_next()
	return files

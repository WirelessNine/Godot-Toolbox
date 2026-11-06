class_name Registry
extends Object
##Singleton for loading and storing collections of resources from the file system.

const EXTENSIONS: PackedStringArray = ["tres", "res"]

static var _collections: Dictionary[String, Collection]


##Creates a new [Registry.Collection] with [param name] and [param type], from [param path].
static func create_collection(name: String, type: StringName, path: String) -> Collection:
	if not DirAccess.dir_exists_absolute(path):
		push_error("Path: ", path, " doesn't exist")
		return null

	var name_snake_case: String = name.to_snake_case()

	if name_snake_case in _collections:
		return _collections[name_snake_case]

	var array: Array[Resource]

	_load_resources_into(array, type, path)

	var collection := Collection.new(array, name_snake_case, path, type)

	_collections[name_snake_case] = collection

	return collection


##Creates multiple [Registry.Collection]s with [param path]'s subfolders name and items, and [param type].
static func create_multi_collection(type: StringName, path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		push_error("Path: ", path, " doesn't exist")
		return

	var folders: PackedStringArray = ResourceLoader.list_directory(path)

	for x: String in folders:
		if not x.ends_with("/"):
			continue

		var folder_name: String = x.trim_suffix("/")
		var subfolder_path: String = path.path_join(folder_name)

		create_collection(folder_name, type, subfolder_path)


##Clears and reloads the resources in the [param collection].
static func refresh_collection(collection: Collection) -> void:
	var array: Array[Resource]

	_load_resources_into(array, collection.type, collection.path)

	collection.assign_items(array)


##Returns the [Registry.Collection] with the matching [param name].
static func get_collection(name: String) -> Collection:
	var name_snake_case: String = name.to_snake_case()

	if not name_snake_case in _collections:
		push_error(name_snake_case, " doesn't exists.")
		return null

	return _collections[name_snake_case]


##Returns [code]true[/code] if a collection with the matching [param name] exists.
static func has_collection(name: String) -> bool:
	var name_snake_case: String = name.to_snake_case()

	return name_snake_case in _collections


##Removes the [param collection] from the registry.
static func remove_collection(collection: Collection) -> void:
	_collections.erase(collection.name)


static func _load_resources_into(array: Array, type: StringName, path: String) -> void:
	var file_names: PackedStringArray = ResourceLoader.list_directory(path)

	if file_names.is_empty():
		return

	for x: String in file_names:
		var full_path: String = path.path_join(x)

		if x.ends_with("/"):
			_load_resources_into(array, type, full_path.trim_suffix("/"))
		elif x.get_extension() in EXTENSIONS:
			var resource := load(full_path)

			if resource and _matches_class(resource, type):
				array.append(resource)


static func _matches_class(resource: Resource, type: StringName) -> bool:
	if type.is_empty():
		return true

	var script: Script = resource.get_script()
	return script and script.get_global_name() == type


##Container of resources.
class Collection:
	##[Array] of items stored in the collection.
	var items: Array[Resource]
	##The collection's name.
	var name: String
	##The path where the collection's items are stored.
	var path: String
	##The type of the items stored.
	var type: StringName

	var _items_cache: Dictionary[String, Resource]


	func _init(p_items: Array, p_name: String, p_path: String, p_type: StringName) -> void:
		assign_items(p_items)

		name = p_name
		path = p_path
		type = p_type


	func _to_string() -> String:
		return "Collection: %s" % name


	##Assigns [param new_items] to [member items].
	func assign_items(new_items: Array[Resource]) -> void:
		items.assign(new_items)
		_create_cache()


	##Returns the item whose file name matches [param item_name], if it exists.
	func get_item(item_name: String) -> Resource:
		var snake_case_name: String = item_name.to_snake_case()
		var item: Resource = _items_cache.get(snake_case_name)

		if item == null:
			push_error(snake_case_name, "doesn't exist in ", self)

		return item


	##Returns [code]true[/code] if an item whose file name matches [param item_name] exists.
	func has_item(item_name: String) -> bool:
		var snake_case_name: String = item_name.to_snake_case()
		return snake_case_name in _items_cache


	##Creates the name cache for items.
	func _create_cache() -> void:
		_items_cache.clear()

		for x: Resource in items:
			_items_cache[x.resource_path.get_file().get_basename().to_snake_case()] = x

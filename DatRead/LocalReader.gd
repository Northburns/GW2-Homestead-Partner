extends Node

class_name DatLocalReader

var file: FileAccess
var fileMetaTable: Array[DatArchiveParser.MftTableEntry]
var indexTable: PackedInt64Array
var dataReader: DatDataReader

func _init(filename: String):
	file = FileAccess.open(filename, FileAccess.READ)
	file.big_endian = false
	
	var a = DatArchiveParser.new(file)
	fileMetaTable = a.metaTable.table
	indexTable = a.indexTable
	
	dataReader = DatDataReader.new()

func close():
	file.close()

func _to_string():
	var fmt = "DatLocalReader: { fileMetaTable size %d, indexTable.size %d }"
	return fmt % [ fileMetaTable.size(), indexTable.size() ]


func read_file(mftId: int, isImage: bool = false, raw: bool = false, fileLength: int = -1, extractLength: int = -1) -> DatLocalFile:
	var meta = get_file_meta(mftId)
	if(meta==null): push_error("Can't read meta. Expect unexpected behaviour.")
	
	var length = fileLength
	if(length < 0): length = meta.size
	
	file.seek(meta.offset)
	var buffer = file.get_buffer(length)
	
	var data
	
	if(raw || meta.compressed):
		data = dataReader.inflate(
			buffer, buffer.size(), 
			mftId, isImage, 
			extractLength if extractLength >= 0 else 0)
	else:
		data = DatLocalFile.new()
		data.buffer = buffer
	
	return data


func get_file_meta(mftId: int) -> DatArchiveParser.MftTableEntry:
	return fileMetaTable[mftId]

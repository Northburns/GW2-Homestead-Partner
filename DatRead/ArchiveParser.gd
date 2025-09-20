extends Node

class_name DatArchiveParser

var archiveHeader: ArchiveHeader
var metaTable: MftTable
# We could use PackedInt32Array, but then we'd have to convert the values to unsigned everywhere..
var indexTable: PackedInt64Array

class ArchiveHeader:
	var version: int
	var magic: String
	var headerSize: int
	var unknownField1: int
	var chunkSize: int
	var crc: int
	var unknownField2: int
	var mftOffset: int
	var mftSize: int
	var flags: int
	
	func _init(f: FileAccess): 
		f.seek(0)
		version = f.get_8()
		magic = f.get_buffer(3).get_string_from_ascii()
		headerSize = f.get_32()
		unknownField1 = f.get_32()
		chunkSize = f.get_32()
		crc = f.get_32()
		unknownField2 = f.get_32()
		mftOffset = f.get_64()
		mftSize = f.get_32()
		flags = f.get_32()
		
		if(magic != "AN\u001A"):
			push_error("ArchiveHeader: unexpected 'magic'. Expect unexpected behaviour.")
		
		print_debug("ArchiveHeader: read ok!")

class MftTable:
	# Header fields:
	var magic: String
	var unknownField1: int
	var nbOfEntries: int
	var unknownField2: int
	var unknownField3: int
	# Entries:
	var table: Array[MftTableEntry]
	var mftIndexOffset: int
	var mftIndexSize: int
	
	func _init(f: FileAccess, header: ArchiveHeader):
		f.seek(header.mftOffset)
		magic = f.get_buffer(4).get_string_from_ascii()
		unknownField1 = f.get_64()
		nbOfEntries = f.get_32()
		unknownField2 = f.get_32()
		unknownField3 = f.get_32()
		
		if(magic != "Mft\u001A"):
			push_error("MftTable: unexpected magic. Expect unexpected behaviour.")
		
		print_debug("MftTable: Number of entries ", nbOfEntries)
		table = []
		table.resize(nbOfEntries)
		for i in range(1, nbOfEntries):
			var entry = MftTableEntry.new(f)
			table[i] = entry
		mftIndexOffset = table[2].offset
		mftIndexSize   = table[2].size
		
		print_debug("MftTable: read ok!")

class MftTableEntry:
	var offset: int
	var size: int
	var compressed: int
	var unknownField1: int
	var unknownField2: int
	var crc: int
	
	func _init(f: FileAccess):
		offset = f.get_64()
		size = f.get_32()
		compressed = f.get_16()
		unknownField1 = f.get_16()
		unknownField2 = f.get_32()
		crc = f.get_32()

#func read(offset: int, length: int) -> PackedByteArray:
#	f.seek(offset)
#	return f.get_buffer(length)

func _init(f: FileAccess):
	archiveHeader = ArchiveHeader.new(f)
	metaTable = MftTable.new(f, archiveHeader)
	
	# Parse index
	f.seek(metaTable.mftIndexOffset)
	var length = metaTable.mftIndexSize / 8
	indexTable = PackedInt64Array()
	print_debug("IndexTable: number of entries ", length)
	for i in range(1, length):
		var id = f.get_32()
		var mftIndex = f.get_32()
		if(indexTable.size() <= id):
			indexTable.resize(id + 1)
		indexTable[id] = mftIndex
	print_debug("IndexTable: Size of indexTable: ", indexTable.size())
	
	print_debug("ArhiveParser ok!")
	

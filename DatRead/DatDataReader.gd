extends Node

class_name DatDataReader

func inflate(
		buffer: PackedByteArray,
		size: int,
		mftId: int,
		isImage: bool = false,
		capLength: int = -1
		) -> DatLocalFile:
	
	# If no capLength, inflate the whole file
	capLength = capLength if capLength >= 0 else 0
	
	# Buffer length check
	if(buffer.size() < 12):
		push_error("Not inflating, too short buffer length: ", buffer.size(), ", mftId ", mftId)
		return null
	
	return null

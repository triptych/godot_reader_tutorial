extends Control

# Declare member variables here. 

var title_arr =  []
var desc_arr  =  []
var link_arr  =  []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_OpenButton_pressed():
	print("Button pressed!")
	populateEdit()

func populateEdit():
	#pass
	$HTTPRequest.request("http://rss.cnn.com/rss/edition.rss")

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	$TextEdit.set_text(body.get_string_from_utf8())
	
	#lets parse this body content
	var p = XMLParser.new()
	var in_item_node = false
	var in_title_node = false
	var in_description_node = false
	var in_link_node = false
	
	p.open_buffer(body)
	
	while p.read() == OK:
		var node_name = p.get_node_name()
		var node_data = p.get_node_data()
		var node_type = p.get_node_type()
		
		# print("node_name: " + node_name)
		# print("node_data: " + node_data)
		# print("node_type: " + node_data)
		
		if(node_name == "item"):
			in_item_node = !in_item_node #toggle item mode

		if (node_name == "title") and (in_item_node == true):
			in_title_node = !in_title_node
			continue
		
		if(node_name == "description") and (in_item_node == true):
			in_description_node = !in_description_node
			continue
			
		if(node_name == "link") and (in_item_node == true):
			in_link_node = !in_link_node
			continue
		
		if(in_description_node == true):
			# print("description-data" + node_data)
			if(node_data != ""):
				desc_arr.append(node_data)
			else:
				# print("description:" + node_name)
				desc_arr.append(node_name)
		
		if(in_title_node == true):
			# print("Title-data:"+ node_data)
			if(node_data !=""):
				title_arr.append(node_data)
			else:
				# print("Title:" + node_name)
				title_arr.append(node_name)

		if(in_link_node == true):
			# print("link-desc" + node_data)
			if(node_data != ""):
				link_arr.append(node_data)
			else:
				# print("link" + node_name)
				link_arr.append(node_name)
				
	# print("Titles:")			
	for i in title_arr:
		# print("TITLE: " + i)
		$ItemList.add_item(i,null,true)			

func _on_ItemList_item_selected(index):
	$DescriptionField.text = desc_arr[index]
	$LinkButton.text = link_arr[index]


func _on_LinkButton_pressed():
	OS.shell_open($LinkButton.text)


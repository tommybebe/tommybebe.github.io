# MODEL
# ------------------------------  

data = [{
	name:"docs"
	img:"images/cell-docs.png"
	},{
	name:"fonts"
	img:"images/cell-fonts.png"	
	},{
	name:"notes"
	img:"images/cell-notes.png"	
	},{
	name: "objs"
	img: "images/cell-objs.png"	
	},{
	name: "props"
	img: "images/cell-props.png"					},{
	name: "styles"
	img:"images/cell-styles.png"
}]

# FUNCS
# ------------------------------  

# helper func to hide/show
showHide = (layerName) ->
	layerName.states.add
		hide: 
			opacity: 0
		show: 
			opacity: 1
	layerName.states.animationOptions = curve:"spring(700,80,0)"


# Koen's Click/Drag differentiator
addDraggableClickHandler = (layer, handler) ->
	
	# On the touch start, record this layers position on the screen
	layer.on Events.TouchStart, ->
		layer._previousScreenFrame = layer.screenFrame
	
	layer.on Events.TouchEnd, (event) ->
		
		# Get the current position on the screen
		currentScreenFrame = layer.screenFrame
		
		# Compare it with the recorded position at touch start
		layerNotMoved = \
			currentScreenFrame.x is layer._previousScreenFrame.x and \
			currentScreenFrame.y is layer._previousScreenFrame.y
		
		# Only if the layer did not move, call the handler 
		handler.call(layer, event, layer) if layerNotMoved



# SETUP
# ------------------------------  

# Variables
cardHeight= 151
screenWidth= 640
screenHeight= 1136
cells = []

# Background
bg = new BackgroundLayer
	x: 100
	y: 100
	width: 300
	height: 300
	backgroundColor: "#fff"
	
# Table - Cell wrapper 
table = new Layer 
	open: false
	x:0
	y:190
	width:640
	height:909
	backgroundColor: "transparent"
table.draggable.enabled = true
table.draggable.speedX = 0	
table.states.add
	top:
		y: 190

# Cells
[0..data.length-1].map (i) ->
	
	cell = new Layer
		superLayer: table
		x: 0
		y: 0 + (i * cardHeight)
		height: cardHeight
		width: screenWidth
		image: data[i].img
	cells[i] = cell
	 
	addDraggableClickHandler cells[i], ->
		preview_doc.html = data[i].name
		preview.states.switch "expanded"
		if preview.states._currentState is "expanded" and table.open is false
			table.open = true
			table.animate	
				properties:
					y: table.y + 500
				curve: "spring(800,80,0)"
				
		if preview.states._currentState == "collapsed" and table.open is true
				table.open = false	
				table.animate
					properties:
						y: table.y - 500
					curve: "spring(800,80,0)"

# Preview - slide down preview panel
preview = new Layer
	x: 0
	y: -510
	width: 640
	height: 700
	backgroundColor: "#D0D8DF"
preview.draggable.enabled = true
preview.draggable.speedX = 0
preview.states.add 
	collapsed:
		y: -510
	expanded:	
		y: 0
preview.states.animationOptions = curve:"spring(800,80,0)"		
# Doc Preview - The image inside the preview panel
preview_doc = new Layer
	superLayer: preview
	x: 30
	y: 160
	width: 580
	height: 800
	backgroundColor: "#fff"
	opacity: 0
preview_doc.html = "This is a preview"
preview_doc.style = {
	"padding-top": "100px"
	"text-align": "center"
	"color": "#515151"
}
# preview_doc.draggable.enabled = true
# preview_doc.draggable.speedX = 0
showHide(preview_doc)
	

preview_handle = new Layer 
	superLayer: preview
	x:0
	y: preview.height - 110
	width:640
	height:110
	image:"images/handle.png"


# Top nav menu
topMenu = new Layer 
	x:0, y:0, width:640, height:131, image:"images/top_menu.png"
	

# EVENTS
# ------------------------------  

yStart = 0

recPreviewStart = (event, layer) ->
	yStart = event.y

togglePreview = (ev, layer) ->
	yEnd = ev.y
	yDelta = yEnd - yStart
	if preview.y < -510
		preview.states.switch "collapsed"
	if yDelta < -20
		preview.states.switch "collapsed"
		preview_doc.states.switch "hide"
	if yDelta > -20
		preview.states.switch "expanded"
		preview_doc.states.switch "show"
	if yDelta > 20
		preview.states.switch "expanded"
		preview_doc.states.switch "show"
	if preview.states._currentState == "expanded" 
		table.open = true
		table.animate	
			properties:
				y: table.y + 500
			curve: "spring(800,80,0)"
				
	if preview.states._currentState == "collapsed"
		table.open = false
		table.animate	
			properties:
				y: table.y - 500
			curve: "spring(800,80,0)"

preview.on(Events.DragStart, recPreviewStart)
preview.on(Events.DragEnd, togglePreview)

preview.on Events.AnimationEnd, ->			
	if preview.y > -200
		preview_doc.states.switch "show"
		

table.on Events.DragEnd, ->

	if preview.y <= -510
		if table.y > 190
			table.states.switch "top", {curve:"spring(800,80,0)"}


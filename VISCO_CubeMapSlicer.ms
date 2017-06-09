/*  
[INFO] 

NAME = CubeMapSlicer
VERSION = 1.0.0
AUTHOR = Vasily Lukyanenko
DEV = VISCO
HELP = 
[INSTALL]

MACRO=CubeMapSlicer
CAT=VISCO
TEXT=CubeMap Slicer

[1.0.0]

* First release =

[ABOUT]
Slice images into parts.=

[TEST]

[SCRIPT]
*/	


try(closeRolloutFloater fCubeMapSlicer)catch()
global fCubeMapSlicer = newRolloutFloater "CubeMap Slicer" 260 500

global _rCubeMapSlicer

fn getScriptInfo s releaseInfo: "" =
(		
	if(releaseInfo != "") do
	(
		r = getINISetting s releaseInfo
		return r
	)
	
	v = getINISetting s "INFO" "VERSION"
	a = getINISetting s "INFO" "AUTHOR"
	n = getINISetting s "INFO" "NAME"
	o = getINISetting s "ABOUT"
	c = getINISetting s "INFO" "DEV"
	h = getINISetting s "INFO" "HELP"
	
	r = for i in (getINISetting s) where i != "ABOUT" and i != "SCRIPT" and i != "COPY" collect i
	
	return #(n, a, v, o, r, c, h)
)

fn getOpenImages = 
(
	f = #()
	
	imageDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" 
	imageDialog.title = "Select Pictures"
	imageDialog.Multiselect = true
	imageDialog.Filter = "PNG (*.png)|*.png|JPG (*.jpg)|*.jpg"
	imageDialog.FilterIndex = 1
	
	result = imageDialog.showDialog() 
	result.ToString() 
	result.Equals result.OK 
	result.Equals result.Cancel 
	
	f = imageDialog.fileNames 
	 
	return f
)

global CubeMapPath = #()	
global CubeMapOutPath = undefined
	
rollout _rCubeMapSlicer  "Slice CubeMap" category:1
(	
	group "1. Load Images:"
	(
		button btnLoadImages "Load Images" tooltip: "Support *.jpg and *.png"
		label lblFilesCount "Please select files..." align: #left
	)
	
	group "2. CubeMap Name:"
	(
		edittext edtCubeMapName "" height: 25 fieldWidth: 230 offset: [-9, 0]
	)
	
	group "3. Slice Count:"
	(
		spinner spnSliceCount range:[2, 24, 6] fieldWidth: 70 type: #integer  align: #left scale: 2
	)
	
	group "4. Save To:"
	(
		edittext edtSaveTo "" readOnly: true height: 25 fieldWidth: 230 offset: [-9, 0]
		button btnSelectPath "Select Path"
	)
	
	button btnStartSlice "Start Slice" height: 35 width: 230
	
	on btnLoadImages pressed do
	(
		CubeMapPath = #()	
		f = getOpenImages()
		
		lblFilesCount.caption = "Loaded: " + f.count as string + " files..."
		if(f.count == 0) do return false
		
		CubeMapPath = f			
	)
	
	on btnSelectPath pressed do
	(
		p = getSavePath()
		CubeMapOutPath = undefined
		edtSaveTo.text = ""
		
		if(p == undefined) do return false
		
		CubeMapOutPath = p
		edtSaveTo.text = p
	)
	
	on edtCubeMapName changed a do
	(
		p = filterString a "\n"
		
		edtCubeMapName.text = if(p[1] != undefined) then p[1]  else ""
	)
	
	on btnStartSlice pressed do
	(
		if(CubeMapPath.count == 0) do return messageBox "Please load images!" title: "Warning!"
		if(edtCubeMapName.text.count < 3) do return messageBox "Please enter correct CubeMap name!" title: "Warning!"
		if(CubeMapOutPath == undefined) do return messageBox "Please select save path!" title: "Warning!"
		
		iCnt = 0
		for f in CubeMapPath do
		(
			iCnt += 1
			
			b = openBitmap f
			w = b.width / spnSliceCount.value
			h = b.height
			
			tmp = bitmap w h
			
			for i in 1 to spnSliceCount.value do
			(
				p = (w * i) - w

				pasteBitmap b tmp (box2 p 0 w h) [0, 0]
				d = CubeMapOutPath + @"\" + edtCubeMapName.text + "_" + iCnt as string + @"\"
				makeDir d
				tmp.filename = d + edtCubeMapName.text + "_" + i as string + ".jpg"
				save tmp
			)
		)
		shellLaunch (CubeMapOutPath) ""
	)	
)


rollout _rAbout "About" category:2
(
	label lblName "" 
	label lblVer "" 
	
	label lblAuthor "" height: 30
	label lblCopy ""  height: 30
	
	on _rAbout open do
	(	
		i = getScriptInfo (getThisScriptFilename())
			
		lblName.caption = i[1]
		lblAuthor.caption = i[2]
		lblVer.caption = i[3]
		lblCopy.caption = i[6]
	)
)

addRollout _rCubeMapSlicer fCubeMapSlicer rolledUp:false
addRollout _rAbout fCubeMapSlicer rolledUp:true

#!/bin/env python
import sys, getopt
import math
from PIL import Image
import numpy as np

phenotypes = {
	"subnordid" : "pheno_regions/subnordid.gif",
	"atlanto_mediterranean" : "pheno_regions/atlanto_mediterranean.gif",
	"basic_veddoid" : "pheno_regions/veddoid.gif",
	"basic_turanid" : "pheno_regions/turanid.gif",
	"basic_tungid" : "pheno_regions/tungid.gif",
	"basic_sudanid" : "pheno_regions/sudanid.gif",
	"basic_south_mongolid" : "pheno_regions/southmongolid.gif",
	"basic_sinid" : "pheno_regions/sinid.gif",
	"basic_sibirid" : "pheno_regions/sibirid.gif",
	"basic_orientalid" : "pheno_regions/orientalid.gif",
	"basic_nordid" : "pheno_regions/nordid.gif",
	"basic_nilotid" : "pheno_regions/nilotid.gif",
	"basic_mediterranean" : "pheno_regions/mediterranid.gif",
	"basic_lappid" : "pheno_regions/lappid.gif",
	"basic_indo_melanid" : "pheno_regions/indo-melanid.gif",
	"basic_indid" : "pheno_regions/indid.gif",
	"basic_ethiopid" : "pheno_regions/ethiopid.gif",
	"basic_east_europid" : "pheno_regions/easteuropid.gif",
	"basic_dinarid" : "pheno_regions/dinarid.gif",
	"basic_congolid" : "pheno_regions/congolid.gif",
	"basic_armenoid" : "pheno_regions/armenoid.gif",
	"basic_alpine" : "pheno_regions/alpine.gif",
	"basic_ainuid" : "pheno_regions/ainuid.gif",
	"yakonin" : "pheno_regions/yakonin.gif",
	"west_alpinid" : "pheno_regions/west_alpinid.gif",
	"troender" : "pheno_regions/tronder.gif",
	"tonkinesid" : "pheno_regions/tonkinesid.gif",
	"tibetid" : "pheno_regions/tibetid.gif",
	"tavastid" : "pheno_regions/tavastid.gif",
	"targid" : "pheno_regions/targid.gif",
	"strandid" : "pheno_regions/strandid.gif",
	"shanid" : "pheno_regions/shanid.gif",
	"savolaxid" : "pheno_regions/savolaxid.gif",
	"satsuma" : "pheno_regions/satsuma.gif",
	"pre_slavic" : "pheno_regions/pre-slavic.gif",
	"pontid" : "pheno_regions/pontid.gif",
	"paleo_sardinian" : "pheno_regions/paleo_sardinian.gif",
	"paleo_atlantid" : "pheno_regions/paleo_atlantid.gif",
	"north_pontid" : "pheno_regions/north_pontid.gif",
	"north_indid" : "pheno_regions/north_indid.gif",
	"north_atlantid" : "pheno_regions/north_atlantid.gif",
	"norid" : "pheno_regions/norid.gif",
	"neo_danubian" : "pheno_regions/neo_danubian.gif",
	"mtebid" : "pheno_regions/mtebid.gif",
	"mountain_indid" : "pheno_regions/mountain_indid.gif",
	"moorish" : "pheno_regions/moorish.gif",
	"manchukorean" : "pheno_regions/manchukorean.gif",
	"litorid" : "pheno_regions/litorid.gif",
	"libyid" : "pheno_regions/libyid.gif",
	"ladogan" : "pheno_regions/ladogan.gif",
	"kham" : "pheno_regions/kham.gif",
	"ishikawa" : "pheno_regions/ishikawa.gif",
	"iranid" : "pheno_regions/iranid.gif",
	"indo_nordid" : "pheno_regions/indo_nordid.gif",
	"indo_iranid" : "pheno_regions/indo_iranid.gif",
	"indo_brachid" : "pheno_regions/indo_brachid.gif",
	"huanghoid" : "pheno_regions/huanghoid.gif",
	"halstatt" : "pheno_regions/halstatt.gif",
	"gracile_indid" : "pheno_regions/gracile_indid.gif",
	"gorid" : "pheno_regions/gorid.gif",
	"gobid" : "pheno_regions/gobid.gif",
	"fenno_nordid" : "pheno_regions/fenno_nordid.gif",
	"faelid" : "pheno_regions/faelid.gif",
	"eurafricanid" : "pheno_regions/eurafricanid.gif",
	"egyptid" : "pheno_regions/egyptid.gif",
	"east_brachid" : "pheno_regions/east_brachid.gif",
	"choshiu" : "pheno_regions/choshiu.gif",
	"chikuzen" : "pheno_regions/chikuzen.gif",
	"chukiangid" : "pheno_regions/chukiangid.gif",
	"changkiangid" : "pheno_regions/changkiangid.gif",
	"central_pamirid" : "pheno_regions/central_pamirid.gif",
	"central_brachid" : "pheno_regions/central_brachid.gif",
	"carpathid" : "pheno_regions/carpathid.gif",
	"borreby" : "pheno_regions/borreby.gif",
	"berberid" : "pheno_regions/berberid.gif",
	"baskid" : "pheno_regions/baskid.gif",
	"asian_alpine" : "pheno_regions/asian_alpine.gif",
	"assyroid" : "pheno_regions/assyroid.gif",
	"plains_pamirid" : "pheno_regions/plains_pamirid.gif",
	"aralid" : "pheno_regions/aralid.gif",
	"arabid" : "pheno_regions/arabid.gif",
	"annamid" : "pheno_regions/annamid.gif",
	"anglo_saxon" : "pheno_regions/anglo_saxon.gif",
	"andronovo_turanid" : "pheno_regions/andronovo-turanid.gif",
	"anatolid" : "pheno_regions/anatolid.gif",
	"alfoeld" : "pheno_regions/alfoeld.gif",
	"aisto_nordid" : "pheno_regions/aisto_nordid.gif",
	"african_alpine" : "pheno_regions/african_alpine.gif"}

def fittingPixels(maskImg, typeImg, rgb):
	yellow = np.asarray([255,255,0 ],dtype=np.uint8)
	darkYellow = np.asarray([127,127,0 ],dtype=np.uint8)
	if maskImg.shape[0] != typeImg.shape[0]:
		return 0
	if maskImg.shape[1] != typeImg.shape[1]:
		return 0
	toReturn = 0.0
	for x in range(maskImg.shape[0]):
		for y in range(maskImg.shape[1]):
			a = maskImg[x][y]
			b = typeImg[x][y]
			if np.array_equal(a,rgb) :
				if np.array_equal(b,yellow):
					toReturn = toReturn + 1.0
				elif np.array_equal(b,darkYellow):
					toReturn = toReturn + 0.1
	return toReturn

def compareWIth(maskImg,rgb):
	items= {}
	for x in phenotypes:
		typeImage = Image.open(phenotypes[x])
		if typeImage.mode != 'RGB' :
			typeImage = typeImage.convert('RGB')
		typeImage = np.array(typeImage)
		temp = fittingPixels(maskImg,typeImage,rgb)
		if temp > 0.0:
			items[x] = temp
	summa = 0.0
	for x in items:
		summa = summa + items[x]
	for x in items:
		items[x] = int(math.ceil((items[x]/summa)*100.0))
	sorted_items = dict(sorted(items.items(), key=lambda x: x[1], reverse=True))
	return sorted_items

def main(argv):
	maskfile = ''
	color = 'ffffff'
	try:
		opts, args = getopt.getopt(argv,"hm:c:",["maskfile=","color="])
	except getopt.GetoptError:
		print('test.py -m <inputfile> -c <color>')
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print('test.py -m <inputfile>')
			sys.exit()
		elif opt in ("-m", "--maskfile"):
			maskfile = arg
		elif opt in ("-c", "--color"):
			color = arg

	rgb = tuple(int(color[i:i+2], 16) for i in (0, 2, 4))
	rgb = np.asarray(rgb,dtype=np.uint8)
	maskImage = Image.open(maskfile)
	if maskImage.mode != 'RGB' :
		maskImage = maskImage.convert('RGB')
	maskImage = np.array(maskImage)
	items = compareWIth(maskImage,rgb)
	for x in items:
		print(str(items[x]) + " = " + x)

main(sys.argv[1:])

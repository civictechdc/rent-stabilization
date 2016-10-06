import csv
import random
import shapefile # pip3 install pyshp

try:
	# tqdm provides a nice progress meter
	from tqdm import tqdm
except ImportError:
	def tqdm(_, *args, **kwargs): return _


# Our information about use codes. Map use codes (as integers) to
# the CSV row about it.
use_codes = csv.DictReader(open("use-codes.csv"))
use_codes = { int(rec["usecode"]): rec for rec in use_codes }

# Owner strings.
government_owners = ("DISTRICT OF COLUMBIA HOUSING AUTHORITY", "UNITED STATES OF AMERICA", "DISTRICT OF COLUMBIA")
corporate_owner_suffixes = ("LLC","LP","INC","TRUSTEE","ASSOCIATES","PARTNERSHIP","CORPORATION","TRUSTEES","ASSOCIATION","TRUST","COMPANY","PRTNSHP","LTD","VENTURE","CORP","L.P.","LTP","UNIVERSITY","PROPERTY","PTSP","CORPORTATION","PROPERTIES","LLP","HOUSING","APARTMENTS","PART","FOUNDATION","CHURCH")

# Pre-load the ward and SMD boundaries.
geometries = { }
for ty, fn in (("ward", "Ward__2012"), ("smd", "Single_Member_District__2013")):
	sf = shapefile.Reader("data/%s.shp" % fn)
	for i, shape in enumerate(sf.iterShapes()):
		id = sf.record(i)[1]
		assert shape.shapeType == 5
		geometries.setdefault(ty, {})[id] = {
			"bbox": shape.bbox,
			"points": shape.points,
		}

# Output file.
residential_units = csv.writer(open("data/all-residential-units.csv", "w"))
residential_units.writerow([
	"square_suffix_lot", "use_code",
	"year_built", "owner_name", "structure_units", "unit_in_structure",
	"address", "unit_number", "longitude", "latitude", "ward", "smd",
	"source_file", "source_object_id",
	"govowned", "corpowned", "cooperative",
])

# Some functions.
def is_positive_number(num):
	try:
		return int(num) > 0
	except ValueError:
		# not an integer-looking string
		return False

def make_unit_num(original_unit_num, fake_unit_num, fake_unit_count):
	if fake_unit_count == 1:
		return original_unit_num
	elif original_unit_num.strip() == "":
		return fake_unit_num
	else:
		return original_unit_num + "/" + str(fake_unit_num)

def peek_bom(f):
	# The files from data.dc.gov have a byte order marker.
	# Read it so the CSV reader doesn't see it.
	f.read(1)
	return f

def find_containing_geometry(x, y, geometries):
	# Find which polygon in geometries contains the lnglat point.
	# This is not an efficient way to do this --- we should use
	# something with a spatial index. But we don't have so much
	# data that it's worth optimizing at all. We can just check
	# each polygon to see a) if its bounding box contains the point
	# and if so 2) if the poylgon contains the point.
	matches = set()
	for id, geom in geometries.items():
		if (geom["bbox"][0] <= x <= geom["bbox"][2]) and (geom["bbox"][1] <= y <= geom["bbox"][3]):
			if point_in_poly(x, y, geom["points"]):
				matches.add(id)
	assert len(matches) == 1 # point should be in exactly one polygon
	return list(matches)[0]

def point_in_poly(x,y,poly):
	# http://geospatialpython.com/2011/01/point-in-polygon.html
    n = len(poly)
    inside = False
    p1x,p1y = poly[0]
    for i in range(n+1):
        p2x,p2y = poly[i % n]
        if y > min(p1y,p2y):
            if y <= max(p1y,p2y):
                if x <= max(p1x,p2x):
                    if p1y != p2y:
                        xints = (y-p1y)*(p2x-p1x)/(p2y-p1y)+p1x
                    if p1x == p2x or x <= xints:
                        inside = not inside
        p1x,p1y = p2x,p2y
    return inside

# Process each file.
for fn in ("cama_residential.csv", "cama_condominium.csv", "cama_commercial.csv"):
	for row in tqdm(list(csv.DictReader(peek_bom(open("data/" + fn)))), desc=fn):
		# Is this record for a residential use?
		if not is_positive_number(row["USECODE"]) or int(row["USECODE"]) not in use_codes:
			continue

		# How many units do we think 
		use_code_info = use_codes[int(row["USECODE"])]
		if fn == "cama_commercial.csv" and is_positive_number(row["NUM_UNITS"]):
			# For the commercial file, use the NUM_UNITS column
			# if it has sane data.
			unit_count = int(row["NUM_UNITS"])
			exploded = True
		elif use_code_info["units"] == "1":
			unit_count = 1
			exploded = (fn != "cama_condominium.csv") # don't treat condo units as "exploded" from a structure
		elif use_code_info["units"] == "2-4":
			# We don't know how many units this structure has but it's between 2 and 4.
			# We could take a best guess, like 3, but lumping everything into a single
			# value makes further analysis look funky. So we'll spread it out between
			# 2 and 4. Based on some post-hoc analysis, it looks like 2 and 3 units are
			# more common than 4 -- it makes the results smoother when comparing to
			# 5.
			unit_count = random.choice([2,2,2,2,2,2,3,3,3,4])
			exploded = True
		elif use_code_info["units"] == "5":
			unit_count = 5
			exploded = True
		else:
			print("dont know how many units in", row)
			continue

		# Find the ward and SMD of this unit/building.
		row["X"] = float(row["X"])
		row["Y"] = float(row["Y"])
		ward = find_containing_geometry(row["X"], row["Y"], geometries["ward"])
		smd = find_containing_geometry(row["X"], row["Y"], geometries["smd"])

		# Write a record for each presumed unit in the record.
		for i in range(unit_count):
			residential_units.writerow([
				row["SSL"], int(row["USECODE"]),
				row["AYB"], row["OWNERNAME"], (unit_count if exploded else "NA"), ((i+1) if exploded else "NA"),
				row["PREMISEADD"], row["UNITNUMBER"],
				row["X"], row["Y"],
				ward, smd,
				fn, row["OBJECTID"],

				row["OWNERNAME"] in government_owners, # govowned
				row["OWNERNAME"].split(" ")[-1] in corporate_owner_suffixes, # last word of owner appears in corporate_owner_suffixes
				int(row["USECODE"]) in (26,27,126,127), # cooperative based on use code
			])

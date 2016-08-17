import csv

# Our information about use codes. Map use codes (as integers) to
# the CSV row about it.
use_codes = csv.DictReader(open("use-codes.csv"))
use_codes = { int(rec["usecode"]): rec for rec in use_codes }

# Output file.
residential_units = csv.writer(open("data/all-residential-units.csv", "w"))
residential_units.writerow([
	"square_suffix_lot", "use_code",
	"year_built", "owner_name", "structure_units",
	"address", "unit_number", "longitude", "latitude",
	"source_file", "source_object_id",
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

# Process each file.
for fn in ("cama_residential.csv", "cama_condominium.csv", "cama_commercial.csv"):
	for row in csv.DictReader(peek_bom(open("data/" + fn))):
		# Is this record for a residential use?
		if not is_positive_number(row["USECODE"]) or int(row["USECODE"]) not in use_codes:
			continue

		# How many units do we think 
		use_code_info = use_codes[int(row["USECODE"])]
		if fn == "cama_commercial.csv" and is_positive_number(row["NUM_UNITS"]):
			# For the commercial file, use the NUM_UNITS column
			# if it has sane data.
			unit_count = int(row["NUM_UNITS"])
		elif use_code_info["units"] == "1":
			unit_count = 1
		elif use_code_info["units"] == "2-4":
			unit_count = 3 # best guess
		elif use_code_info["units"] == "5":
			unit_count = 5
		else:
			print("dont know how many units in", row)

		# Write a record for each presumed unit in the record.
		for i in range(unit_count):
			residential_units.writerow([
				row["SSL"], int(row["USECODE"]),
				row["AYB"], row["OWNERNAME"], unit_count,
				row["PREMISEADD"], make_unit_num(row["UNITNUMBER"], i, unit_count),
				row["X"], row["Y"],
				fn, row["OBJECTID"],
			])

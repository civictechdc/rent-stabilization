# Read all-residential-units.csv and count up now many users are owned
# by each owner, trusting that exact matches on the owner name is good
# enough.

import csv, collections, shutil

# Count up the aggregate number of units owned by each owner.
aggregate_units = collections.defaultdict(lambda : 0)
for row in csv.DictReader(open("data/all-residential-units.csv")):
	aggregate_units[row["owner_name"]] += 1

# Re-write data/all-residential-units.csv and add a column to it.
with open("/tmp/all-residential-units.csv", "w") as f:
	writer = csv.writer(f)
	header = None
	for row in csv.reader(open("data/all-residential-units.csv")):
		if header == None:
			row.append("owner_aggregate_units")
			header = row
		else:
			owner_name = row[header.index("owner_name")]
			row.append(aggregate_units[owner_name])
		writer.writerow(row)

# Clobber the old file with the new file.
shutil.move("/tmp/all-residential-units.csv", "data/all-residential-units.csv")

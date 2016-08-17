# Make a single table of all residential units in the district.

# Load our spreadsheet of use codes.
usecodes = read.csv("use-codes.csv")

# FUNCTIONS

is_residential_rental_use_code <- function(usecode) {
	# Is the use code in our use-codes.csv file of residential use codes?
	# (use codes appear as "11" or "011", so always turn
	# into an integer first)
	return(sum(as.numeric(usecodes$usecode)==as.numeric(usecode)) > 0);
}

get_use_code_unit_count <- function(usecode) {
	# How many units can we assume are in a structure with this use code?
	units <- usecodes[usecodes$usecode==usecode,]$units;
	if (length(units) == 0) {
		print("invalid call to get_use_code_unit_count")
		print(use_code);
		return(NA);
	} else if (units == "") {
		# don't know
		return(NA);
	} else if (units == "1") {
		return(1);
	} else if (units == "2-4") {
		return(3);
	} else if (units == "5") {
		return(5);
	} else {
		print("invalid units data in use-codes.csv")
		print(use_code);
		print(units)
		return(NA);
	}
}

over_rows <- function(dataframe, func) {
	# Call func on each row of dataframe.
	#print(names(dataframe))
	for (i in 1:nrow(dataframe))
		func(dataframe[i,]);
}

append_unit <- function(cama_row, i, units, source_file) {
	# Make a row in residential_units from a row in
	# the source CAMA file, plus information about
	# which "unit" this is (i) when we automatically
	# expand a structure into its units.
	newrow = list(
		# property metadata
		square_suffix_lot=as.character(cama_row$SSL),
		use_code=cama_row$USECODE,

		# fields related to rent stabilization policy
		year_built=cama_row$AYB,
		owner_name=as.character(cama_row$OWNERNAME),
		structure_units=units,

		# address, unit, and geographic location
		address=as.character(cama_row$PREMISEADD),
		unit_number=expanded_unit_number(cama_row$UNITNUMBER, units, i),
		longitude=cama_row$X,
		latitude=cama_row$Y,

		# source information for this record
		source_file=source_file,
		source_object_id=cama_row$OBJECTID
	)

	# rbind() is extremely slow. To make this faster, we should pre-allocate
	# space in the data frame and then fill it in.
	if (residential_units_count == nrow(residential_units)) {
		# Allocate more space by doubling the size of the data frame.
		# We'll chop it down to the number of rows we actually filled
		# in at the end.
		space_to_add = (1+residential_units_count) # residential_units_count is zero in the first iteration, so at 1 so we allocate something
		residential_units <<- rbind(residential_units, data.frame(
			square_suffix_lot=character(space_to_add),
			use_code=numeric(space_to_add),
			year_built=numeric(space_to_add),
			owner_name=character(space_to_add),
			structure_units=numeric(space_to_add),
			address=character(space_to_add),
			unit_number=character(space_to_add),
			longitude=numeric(space_to_add),
			latitude=numeric(space_to_add),
			source_file=character(space_to_add),
			source_object_id=numeric(space_to_add),
			stringsAsFactors=F
		))
		print(residential_units_count)
	}

	# Copy into the data frame and increment the counter of the number
	# of rows we've actually used.
	residential_units[residential_units_count,] <<- as.data.frame(newrow, stringsAsFactors=F);
	residential_units_count <<- residential_units_count + 1; # "<<-" assigns to a global variable
	#print(residential_units)
};

expanded_unit_number <- function(source_unit, nunits, i) {
	if (nunits == 1) {
		return(source_unit);
	} else if (source_unit == "") {
		return(i);
	} else {
		return(paste(source_unit, "/", i))
	}
}

# MAIN

# Create an empty data frame to hold all of the residential units in DC.
residential_units_count = 0;
residential_units <- data.frame(
	square_suffix_lot=character(),
	use_code=numeric(),

	year_built=numeric(),
	owner_name=character(),
	structure_units=numeric(),

	address=character(),
	unit_number=character(),
	longitude=numeric(),
	latitude=numeric(),

	source_file=character(),
	source_object_id=numeric(),
		
	stringsAsFactors=F);

# Loop through the residential properties. Each property
# may have more than one unit, which we expand out.
over_rows(read.csv("data/cama_residential.csv"), function(row) {
	# Skip if not a residential / plausibly rental building.
	if (!is_residential_rental_use_code(row$USECODE)) { return(); }

	# There is no unit count in the dataset, so we have to guess
	# from the use code.
	units = get_use_code_unit_count(row$USECODE);
	if (is.na(units)) {
		print("no unit count available");
		print(row);
		return();
	}
	
	# Expand this building into units.
	for (i in 1:units)
		append_unit(row, i, units, "cama_residential");
})

# Loop through the condo properties. Each property
# may have more than one unit, which we expand out.
over_rows(read.csv("data/cama_condominium.csv"), function(row) {
	# Skip if not a residential / plausibly rental building.
	if (!is_residential_rental_use_code(row$USECODE)) { return(); }

	# There is no unit count in the dataset, so we have to guess
	# from the use code.
	units = get_use_code_unit_count(row$USECODE);
	if (is.na(units)) {
		print("no unit count available");
		print(row);
		return();
	}
	
	# Expand this building into units.
	for (i in 1:units)
		append_unit(row, i, units, "cama_condominium");
})

# Loop through the commercial properties. Each property
# may have more than one unit, which we expand out.
over_rows(read.csv("data/cama_commercial.csv"), function(row) {
	# Skip if not a residential / plausibly rental building.
	if (!is_residential_rental_use_code(row$USECODE)) { return(); }

	if (!is.na(row$NUM_UNITS)) {
		# If given, use the NUM_UNITS column.
		units = row$NUM_UNITS;
		if (units == 0) {
			print("zero units?");
			print(row);
			return();
		}
	} else {
		units = get_use_code_unit_count(row$USECODE);
		if (is.na(units)) {
			print("no unit count available");
			print(row);
			return();
		}
	}
	
	# Expand this building into units.
	for (i in 1:units)
		append_unit(row, i, units, "cama_commercial");
})

# Save!
residential_units = residential_units[0:residential_units_count,]
write.table(residential_units, "data/all_residential_units.csv", row.names=F)


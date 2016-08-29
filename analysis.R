library(ggplot2)
library(ggthemes)
library(scales)

# Utility function for saving a ggplot plot as a png file
save.plot = function(name, p) {
	png(filename=paste("plots/", name, ".png", sep=""),
	    width=900, height=400, pointsize=12)
	plot(
		p
		+ theme_light()
		+ theme(text = element_text(size=18))
		);
	dev.off();
}

# Utlity function for a common style of bar charts by ward.
ggplot.ward <- function(data) {
	return (ggplot(data, aes(as.factor(ward), units))
	 + geom_bar(stat='identity', aes(fill=type))
	 + xlab('Ward')
	 + ylab('Rental Units')
	 + scale_y_continuous(labels=comma, limits=c(0, 30000)) # create a consistent scale across plots, overrides
	 + coord_flip())
}

# Read table.
data <- read.csv("data/all-residential-units.csv")

# Convert data types.
data$use_code <- as.numeric(data$use_code)
data$year_built <- as.numeric(data$year_built)
data$govowned <- as.logical(data$govowned == 'True')
data$corpowned <- as.logical(data$corpowned == 'True')
data$cooperative <- as.logical(data$cooperative == 'True')
data$owner_aggregate_units <- as.numeric(data$owner_aggregate_units)

# Clean up the year built field.
data$year_built <- ifelse(data$year_built < 1900 | data$year_built > 2016, 1900, data$year_built)

# Account for owner-occupied residential units not being rental units by
# assigning a weight to each residential unit. By summing over these
# weights, we count presumed *rental* units.
#
# * Government, corporate, and cooperative units are assigned weight 1,
#   because they are never owner-occupied. i.e. These units are counted
#   in full.
#
# * For all other units, assume that an owner occupies just one unit
#   they own by weighting all of their units 1 - 1/N, where N is the
#   aggregate number of residential units they own. So, for example,
#   if an owner owns a single unit, the weight on their unit is 0
#   (their unit is discounted in this analysis - it's not rental).
#   If an owner owns a building with two units, the weight on each
#   unit is 0.5, which sums to a total of one unit representing the
#   one rented unit out of the two units in the building. And so on.
data$weight <- ifelse(
	data$govowned | data$corpowned | data$cooperative,
        1, # non-human owner
        1-1/data$owner_aggregate_units
	)

print(c("Total housing units", nrow(data)))
print(c("Total rental units", sum(data$weight, na.rm=T)))

# Create a function that tells us whether a unit is exempt from rent
# stabilization policy, given a cutoff year (in terms of year build)
# and the maxmimum number of units a natural person owner may own in
# aggregate to be exempt. We'll assume all cooperative-owned units
# are exempt, although the law is more complicated.
is_exempt <- function(year_built_on_or_after, owner_max_aggregate_units) {
	return(
		  data$govowned
		| data$year_built >= year_built_on_or_after
		| (!data$corpowned & data$owner_aggregate_units <= owner_max_aggregate_units)
		| data$cooperative
	) }

# Create the function for today's policy. We'll use a year build of
# 1978, which is two years past the "building permit" date as in
# the actual law. i.e. We're assuming buildings were built two years
# after their permit was issued.
is_exempt_actual <- is_exempt(1978, 4)

# Mark units by exemption type - in a mutually exclusive way,
# from lowest to highest priority.
exemption = is_exempt_actual;
exemption[is_exempt_actual & (data$year_built >= 1978)] = "built >= 1978";
exemption[is_exempt_actual & (!data$corpowned & data$owner_aggregate_units <= 4)] = "small owner";
exemption[is_exempt_actual & data$cooperative] = "cooperative";
exemption[is_exempt_actual & data$govowned] = "gov't owner";

print(c("Total exempt rental units", round(sum(data$weight[is_exempt_actual], na.rm=T))))
print(c("Total non-exempt rental units", round(sum(data$weight[!is_exempt_actual], na.rm=T))))
print("breakdown # %")

# What percentage of rental units are subject to rent stabilization by
# ward?
make_df <- function(type, filter) {
	# print the number district-wide
	print(c(type, round(sum(data$weight[filter], na.rm=T)), round(100*sum(data$weight[filter], na.rm=T)/sum(data$weight, na.rm=T))))
	# make a data table that splits it by ward
	ret = data.frame(ward=1:8, type=type)
	ret$units = sapply(1:8, function(ward) sum(data$weight[data$ward==ward & filter], na.rm=T))
	return(ret)
}
units_by_ward = make_df("stabilized", !is_exempt_actual);
for (e in unique(exemption[is_exempt_actual]))
	if (!is.na(e))
		units_by_ward = rbind(units_by_ward, make_df(e, exemption==e));
save.plot(
	"units_by_ward",
	ggplot.ward(units_by_ward)
	 + labs(title="Rent Stabilization & Exemptions by Ward")
)

# How many more units would be covered by rent stabilization by increasing
# the building permit year in the law?
#
# Looking at units not exempt for reasons besides building permit year,
# how many units were built before a certain year? Plot by ward.

# Make a new data frame where the rows are years.
#  $n = number of units built in that year
#  $cum = cumulative number of builts built in that year or any earlier year
by_year_built <- function (ward) {
	year_built = data.frame(
		year=sort(unique(data$year_built)),
		ward=as.character(ward)
	)
	year_built$n = sapply(year_built$year, function(year)
		sum(data$weight[
			data$year_built==year
			& data$ward==ward
			& !is_exempt(9999, 4) # exempt for reasons besides year build
			], na.rm=T))
	year_built$cum = cumsum(year_built$n)
	return(year_built)
}
year_built = data.frame()
for (ward in 1:8)
	year_built = rbind(year_built, by_year_built(ward))

# And plot.
save.plot(
	"by_year",
	ggplot(year_built, aes(year, cum))
	 + geom_area(aes(fill=ward))
	 + xlim(1925, 2016)
	 + labs(title="Cumulative Rental Units Built Through Year")
	 + xlab('Year Built')
	 + ylab('Rental Units')
	 + scale_y_continuous(labels=comma)
	 + geom_vline(xintercept=1978)
	)

# How many more units would be covered by rent stabilization by tightening
# the threshold for what is considered a small owner.
#
# Looking at units not exempt for reasons besides building the owner's
# aggregate units, how many units are owned by by owners with different
# aggregate owned units?

# Make a new data frame where the rows are the number of owned units.
#  $n = number of units built in that year
#  $cum = cumulative number of builts built in that year or any earlier year
by_aggregate_units <- function (ward) {
	ret = data.frame(
		aggregate_units=1:4,
		ward=as.character(ward)
	)
	ret$n = sapply(ret$aggregate_units, function(au)
		sum(data$weight[
			  !data$corpowned
			& data$owner_aggregate_units==au
			& data$ward==ward
			& !is_exempt(1978, 0) # exclude exempt for reasons besides aggregate units
			], na.rm=T))
	return(ret)
}
aggregate_units = data.frame()
for (ward in 1:8)
	aggregate_units = rbind(aggregate_units, by_aggregate_units(ward))

# And plot.
save.plot(
	"by_aggregate_units_owned",
	ggplot(aggregate_units, aes(aggregate_units, n))
	 + geom_bar(stat='identity', aes(fill=ward))
	 + labs(title="Exemptions by Aggregate Owned Units")
	 + xlab('Unit\'s Owner\'s Aggregate Owned Units')
	 + ylab('Rental Units')
	)

# How many units would come under rent control through different changes in policy?
print("with changes in policy # %")
changes_by_ward = rbind(
	make_df("currently stabilized", !is_exempt_actual),
	make_df("if 1976 => 1996", is_exempt_actual & !is_exempt(1998, 4)),
	make_df("if 4 => 3", is_exempt_actual & !is_exempt(1978, 3))
	#make_df("both", is_exempt_actual & is_exempt(1998, 4) & is_exempt(1978, 3) & !is_exempt(1998, 3))
)
save.plot(
	"changes_by_ward",
	ggplot.ward(changes_by_ward)
	 + labs(title="Effects of Policy Changes by Ward")
)

# Resolve the version to release and calculate next version
OPERATOR_VERSION ?= $(shell sed -rn 's/^VERSION \?= v(.*)/\1/p' Makefile | xargs)

# Determine what's the version to release, according to the RELEASE_TYPE
# NOTE: OPERATOR_VERSION_TO_RELEASE variable will only be used to update the main Makefile
# with the version string to publish. Once the main Makefile is updated, all other parts
# of this ci-Makefile should use OPERATOR_VERSION since, then, it will contain the right
# version string and the value of OPERATOR_VERSION_TO_RELEASE will be invalid.
ifeq ($(RELEASE_TYPE),patch)
  # For patch, bump the version that is present in Makefile. This will be the
  # version string to use for the release.
  OPERATOR_VERSION_TO_RELEASE ?= v$(shell $(SEMVER) bump $(RELEASE_TYPE) $(OPERATOR_VERSION))
endif
ifeq ($(findstring $(RELEASE_TYPE),major minor),$(RELEASE_TYPE))
  # For major and minor, remove the -SNAPSHOT suffix from the Makefile
  OPERATOR_VERSION_TO_RELEASE ?= v$(shell $(SEMVER) bump release $(OPERATOR_VERSION))
endif

ifeq ($(findstring snapshot,$(RELEASE_TYPE)),snapshot)
  # For end-of-week snapshot release, substitute the -SNAPSHOT prefix in the Makefile with
  # the value of $(RELEASE_TYPE) -- assuming value will be snapshot.{X}
  OPERATOR_VERSION_TO_RELEASE ?= v$(shell $(SEMVER) bump prerel $(RELEASE_TYPE) $(OPERATOR_VERSION))  
else ifeq ($(RELEASE_TYPE),edge)
  # Use 'latest' for edge releases
  OPERATOR_VERSION_TO_RELEASE ?= latest
endif

echo $OPERATOR_VERSION_TO_RELEASE
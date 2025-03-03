#!/bin/bash

# Source the environment file
if [ -f /pds/pds.env ]; then
  source /pds/pds.env
fi

# Execute pdsadmin with the provided arguments
/app/pdsadmin "$@"

#!/usr/bin/env bash

BLUE='\033[0;34m'
YELLOW='\033[0;33m'
GREEN='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m' # Show no Color

log_info() {
    echo -e "\n${GREEN}Info: ${1}${NC}"
}

log_error() {
    echo -e "\n${RED}Error: ${1}${NC}"
}

log_warn() {
    echo -e "\n${YELLOW}Warning: ${1}${NC}"
}

####### TESTS for helpers.sh
#tests
#log_info "test info"
#log_error "test error"
#log_warn "test warning"
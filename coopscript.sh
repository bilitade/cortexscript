#!/bin/bash

# Default number of lines to display if not specified by the user
DEFAULT_LINES=200

# Function to display the specified number of lines from the log file
display_lines() {
    local filename=$1
    local lines=$2

    # Use awk to filter and process the log file
    awk '
        BEGIN {
            # Set color codes
            green = "\033[0;32m"
            red = "\033[0;31m"
            reset = "\033[0m"
        }
        # Process each line of the input
        {
            # Check if the line contains INBOUND message
            if ($0 ~ /INBOUND/) {
                # Extract and print the inbound message line
                printf("%s\n", $0)
            }
            # Check if the line contains in[2:], in[3:], in[4:], or in[39:]
            else if ($0 ~ /in\[ *[234]: *\]/ || $0 ~ /in\[ *39: *\]/) {
                # Extract the value between < and > in the line
                match($0, /<[^>]+>/)
                value = substr($0, RSTART+1, RLENGTH-2)
                # Print the line with appropriate color
                if (value == "000" && $0 ~ /in\[ *39: *\]/) {
                    printf("%s%s%s\n", green, $0, reset)
                } else if (value != "000" && $0 ~ /in\[ *39: *\]/) {
                    printf("%s%s%s\n", red, $0, reset)
                } else {
                    # Print other lines normally
                    print
                }
            }
        }
    ' "$filename" | tail -n "$lines"
}

# Check if the user has provided command-line arguments
if [[ $# -eq 0 ]]; then
    # If no arguments provided, print usage message
    echo "Usage: $0 [-<lines>] <filename>"
    exit 1
fi

# Parse command-line arguments
while getopts ":f:" opt; do
    case $opt in
        f)
            # If option -f is provided, display specified number of lines
            display_lines "${@: -1}" "$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

# If no option is provided, display all lines
if [[ $OPTIND -eq 1 ]]; then
    display_lines "$1" "$DEFAULT_LINES"
fi

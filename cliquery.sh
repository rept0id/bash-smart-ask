#!/bin/bash

# Function to display usage information
function usage() {
    echo "Usage: $0 --type <input_type> [--desc <description>] [--returns <true|false>] [--positive] [--range <min|max>] [--select-options <option1|option2|...>]"
    echo ""
    echo "Arguments:"
    echo "  --type          : The expected input type: text, tf, yn, bit, int, float, select"    
    echo "  --desc          : A description for the user prompt."
    echo "  --returns       : For bool-style types like yn or tf, determine what to return (e.g. \"Y|N\")."
    echo "  --positive      : For number-style types like int or float, specify if the input must be positive (set flag to require positive values)."
    echo "  --range         : For number-style types, specify the allowed range (e.g. \"-3000|4500\")."
    echo "  --select-options: For select type, provide the options for the user to choose from (e.g. \"a|b|c\")."
    echo ""
    echo "Examples:"
    echo "  ./cliquery.sh --type \"yn\" --desc \"Are you a human ?\" --returns \"Y|N\""
    echo "  ./cliquery.sh --type \"int\" --desc \"Which year were you born ?\" --range \"1900|$(date +%Y)\""
    echo "  ./cliquery.sh --type float --desc \"What's your final grade ?\" --range \"0|10\""
    echo "  ./cliquery.sh --type int --desc \"How many hours do you spend commuting each month ?\" --positive"
    echo "  ./cliquery.sh --type select --desc \"Which learning path(s) did you follow ?:\" --select-options \"How to code : Simple data|How to code : Complex data|Both\""
    exit 1
}

# Function to validate input
function validate_input() {
    local type=$1
    local returns=$2
    local desc=$3
    local positive=$4
    local range=$5
    local select_options=$6
    local input

    # Use the description if provided, otherwise default to the type name
    local prompt="${desc:-Please enter a $type:}"

    # Parse the range if provided
    local range_min
    local range_max
    if [[ -n "$range" ]]; then
        range_min=$(echo "$range" | cut -d'|' -f1)
        range_max=$(echo "$range" | cut -d'|' -f2)
    fi

    # Parse select options if provided
    local options=()
    if [[ -n "$select_options" ]]; then
        IFS='|' read -r -a options <<< "$select_options"
    fi

    while true; do
        case $type in
            text)
                read -p "$prompt ($type) : " input

                if [[ -n "$input" ]]; then
                    echo "$input"
                    break
                fi
                ;;
            tf)
                read -p "$prompt ($type) : " input

                if [[ "$input" =~ ^[tTfF]|(true|True|TRUE|false|False|FALSE)$ ]]; then
                    if [[ "$input" =~ ^[tT]|true|True|TRUE$ ]]; then
                        echo "${returns%|*}"
                    else
                        echo "${returns#*|}"
                    fi
                    break
                fi
                ;;
            yn)
                read -p "$prompt ($type) : " input

                if [[ "$input" =~ ^[yYnN]|(yes|Yes|YES|no|No|NO)$ ]]; then
                    if [[ "$input" =~ ^[yY]|yes|Yes|YES$ ]]; then
                        echo "${returns%|*}"
                    else
                        echo "${returns#*|}"
                    fi
                    break
                fi
                ;;
            bit)
                read -p "$prompt ($type) : " input

                if [[ "$input" == "0" || "$input" == "1" ]]; then
                    echo "$input"
                    break
                fi
                ;;
            int)
                read -p "$prompt ($type) : " input

                if [[ "$input" =~ ^-?[0-9]+$ ]]; then
                    if [[ -n "$positive" && "$input" -lt 0 ]]; then
                        echo "Invalid input: must be positive."
                    elif [[ -n "$range" && ( "$input" -lt "$range_min" || "$input" -gt "$range_max" ) ]]; then
                        echo "Invalid input: must be within range $range."
                    else
                        echo "$input"
                        break
                    fi
                fi
                ;;
            float)
                read -p "$prompt ($type) : " input

                if [[ "$input" =~ ^-?[0-9]*\.?[0-9]+$ ]]; then
                    if [[ -n "$positive" && "$(echo "$input < 0" | bc)" -eq 1 ]]; then
                        echo "Invalid input: must be positive."
                    elif [[ -n "$range" && ( "$(echo "$input < $range_min" | bc)" -eq 1 || "$(echo "$input > $range_max" | bc)" -eq 1 ) ]]; then
                        echo "Invalid input: must be within range $range."
                    else
                        echo "$input"
                        break
                    fi
                fi
                ;;
            select)
                if [[ -n "$select_options" ]]; then
                    echo "Select an option:"
                    local i=1
                    for option in "${options[@]}"; do
                        echo "$i) $option"
                        ((i++))
                    done

                    while true; do
                        read -p "Choose an option (1-${#options[@]}): " choice
                        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
                            echo "${options[$((choice - 1))]}"
                            break
                        else
                            echo "Invalid choice. Please try again."
                        fi
                    done
                    break
                fi
                ;;
            *)
                echo "Unknown type: $type"
                exit 1
                ;;
        esac

        echo "Invalid input. Please try again."
    done
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --type)
            type="$2"
            shift; shift
            ;;
        --returns)
            returns="$2"
            shift; shift
            ;;
        --desc)
            desc="$2"
            shift; shift
            ;;
        --positive)
            positive="1"
            shift
            ;;
        --range)
            range="$2"
            shift; shift
            ;;
        --select-options)
            select_options="$2"
            shift; shift
            ;;
        *)
            echo "Unknown option $key"
            usage
            ;;
    esac
done

# Ensure the --type argument is provided
if [[ -z "$type" ]]; then
    echo "Error: --type argument is required."
    usage
fi

# Call the validate_input function with the parsed arguments
validate_input "$type" "$returns" "$desc" "$positive" "$range" "$select_options"
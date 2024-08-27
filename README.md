# CLIquery

```
Usage: ./cliquery.sh --type <input_type> [--desc <description>] [--returns <true|false>] [--positive] [--range <min|max>] [--select-options <option1|option2|...>]

Arguments:
  --type          : The expected input type: text, tf, yn, bit, int, float, select
  --desc          : A description for the user prompt.
  --returns       : For bool-style types like yn or tf, determine what to return (e.g. "Y|N").
  --positive      : For number-style types like int or float, specify if the input must be positive (set flag to require positive values).
  --range         : For number-style types, specify the allowed range (e.g. "-3000|4500").
  --select-options: For select type, provide the options for the user to choose from (e.g. "a|b|c").

Examples:
  ./cliquery.sh --type "yn" --desc "Are you a human ?" --returns "Y|N"
  ./cliquery.sh --type "int" --desc "Which year were you born ?" --range "1900|2024"
  ./cliquery.sh --type float --desc "What's your final grade ?" --range "0|10"
  ./cliquery.sh --type int --desc "How many hours do you spend commuting each month ?" --positive
  ./cliquery.sh --type select --desc "Which learning path(s) did you follow ?:" --select-options "How to code : Simple data|How to code : Complex data|Both"
```
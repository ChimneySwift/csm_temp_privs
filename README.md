# Temp Privs
Client-Side port of my temp_privs mod.

## Usage
Temporarily grant privs:
`.tgrant <name> <privs> <time>`

Temporarily revoke privs:
`.trevoke <name> <privs> <time>`

## Times
Each time is comprised of a number followed by a letter. The letter signifies a multiplyer to the number.

Available letters:


| Letter | Time    |
|--------|---------|
| s      | seconds |
| m      | minutes |
| h      | hours   |
| D      | days    |
| W      | weeks   |
| M      | months  |
| Y      | years   |

Examples:


10s - 10 seconds

5m - 5 minutes

1h - 1 hour

5Y - 5 years

## Limitations
Privilage string must not contain spaces (use only commas to separate)

If you are not online when the grant/revoke is set to revert, it will not revert until you log on again.

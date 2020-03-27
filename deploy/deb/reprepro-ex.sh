#!/usr/bin/expect -f
#
# script provides a wrapper around reprepro using expect to automate GPG
# signing of APT repository metadata

set timeout 20

set passphrase "$env(GPG_PASSPHRASE)"

# Call reprepro with variable length arguments, so that this script
# takes the same arguments as the original program
spawn reprepro {*}$argv

expect {
    timeout                     {send_error "\nFailed to get password prompt\n";
                                 exit 1}
    "Please enter passphrase*"  {send -- "$passphrase\r";
                                 send_user " *** entering passphrase ***";
                                 exp_continue}
}

# Get the pid, spawnid, oserr and exitcode from the spawned reprepro command
set returnvalues [wait]

# Extract the reprepro exit code
set exitcode [lindex $returnvalues 3]

# Exit with the exitcode from reprepro (0 on success)
exit $exitcode
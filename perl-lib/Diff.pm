#
# Module for comparing expected and actual output of tests.
#

package Diff;

use strict;
use warnings;

our $VERSION = '1.00';

use base 'Exporter';

our @EXPORT = qw(diff);

#
# We only need a simple diff, but we need to strip \r at the end of line.
#
sub diff {
    my ($gold, $log, $skip) = @_;
    my ($diff, $gline, $lline);
    $diff = 0;

    #
    # If we do not have a gold file then we just look for a log file line
    # with just PASSED on it to indicate that the test worked correctly.
    #
    if ($gold eq "") {
        open (LOG, "<$log") or do {
            warn "Error: unable to open $log for reading.\n";
            return 1;
        };

        $diff = 1;
        # Loop on the log file lines looking for a "passed" by it self.
        foreach $lline (<LOG>) {
            if ($lline =~ /^\s*passed\s*$/i) {
                $diff = 0;
            }
        }

        close (LOG);
    } else {
        open (GOLD, "<$gold") or do {
            warn "Error: unable to open $gold for reading.\n";
            return 1;
        };
        open (LOG, "<$log") or do {
            warn "Error: unable to open $log for reading.\n";
            return 1;
        };

        # Loop on the gold file lines.
        foreach $gline (<GOLD>) {
            if (eof LOG) {
                $diff = 1;
                last;
            }
            $lline = <LOG>;
            # Skip initial lines if needed.
            if ($skip > 0) {
                $skip--;
                next;
            }
            $lline =~ s/\r\n$/\n/;  # Strip <CR> at the end of line.
            if ($gline ne $lline) {
                $diff = 1;
                last;
            }
        }

        # Check to see if the log file has extra lines.
        $diff = 1 if (!$diff and !eof LOG);

        close (LOG);
        close (GOLD);
    }

    return $diff;
}

1;  # Module loaded OK

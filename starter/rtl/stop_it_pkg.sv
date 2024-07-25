// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

package stop_it_pkg;

typedef enum logic [4:0] {
    WAITING_TO_START,
    STARTING,
    DECREMENTING,
    CORRECT,
    WRONG,
    WON
} state_t;

endpackage

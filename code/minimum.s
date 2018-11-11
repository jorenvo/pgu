#PURPOSE:  This program finds the minimum number of a
#          set of data items.
#
#VARIABLES: The registers have the following uses:
#
# %edi - Holds the index of the data item being examined
# %ebx - Largest data item found
# %eax - Current data item
#
# The following memory locations are used:
#
# data_items - contains the item data.  A 0 is used
#              to terminate the data
#
.section .data
data_items:
        .long 3,67,34,222,45,75,54,34,44,33,22,11,66,2,0

.section .text
.globl _start
_start:
        movl $0, %edi                   # move 0 into the index register
        movl data_items, %ebx           # initialize %ebx to first element

start_loop:                             # start loop
        movl data_items(,%edi,4), %eax  # load current value
        incl %edi                       # increment index

        cmpl $0, %eax                   # check to see if we’ve hit the end
        je loop_exit
        cmpl %ebx, %eax                 # compare values
        jge start_loop                  # jump to loop beginning if the new one isn’t smaller
        movl %eax, %ebx                 # move the value as the largest
        jmp start_loop                  # jump to loop beginning

loop_exit:
        # %ebx is the status code for the exit system call
        # and it already has the minimum number
        movl $1, %eax             #1 is the exit() syscall
        int  $0x80

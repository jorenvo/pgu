.section .data                  # no data
.section .text
.globl _start

_start:
        pushl   $7              # argument for square
        call    square

exit:
        movl    %eax, %ebx      # linux exit reads return code from %ebx
        movl    $1, %eax        # linux syscall number for exit
        int     $0x80           # return control to kernel


### PURPOSE: calculate x^2
### INPUT  : x
### OUTPUT : x^2
.type square,@function
square:
        pushl   %ebp            # push %ebp before we override it
        movl    %esp, %ebp      # create stack frame
        movl    8(%ebp), %eax   # copy argument into %eax

        imul    %eax, %eax      # square the number, store result in %eax

        movl    %ebp, %esp      # %esp back original %esp - 4, not
	                        # strictly necessary because %esp wasn't moved
        popl    %ebp            # %esp back to original %esp, and set original %ebp
        ret

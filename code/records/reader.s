.include "linux.s"
.include "record_def.s"
.include "common.s"

.section .bss
.lcomm RECORD_DATA, RECORD_SIZE

.section .text
.equ ST_FD, -4
.equ O_RDONLY, 00000000
.equ PERMISSIONS, 0644
.globl _start
_start:
        movl    %esp, %ebp
        subl    $4, %esp                # make room for ST_FD

        ## open file specified in first argument
        movl    $SYS_OPEN, %eax
        movl    ST_ARGV_1(%ebp), %ebx
        movl    $O_RDONLY, %ecx
        movl    $PERMISSIONS, %edx

        int     $LINUX_SYSCALL
        movl    %eax, ST_FD(%ebp)       # store fd

        pushl   $RECORD_DATA
        pushl   ST_FD(%ebp)

        call    read_record

        addl    $8, %esp

.equ ASCII_SPACE, 32
.equ ASCII_NEWLINE, 10
print:
print_firstname:
        movl    $SYS_WRITE, %eax
        movl    $STDOUT, %ebx
        movl    $RECORD_DATA, %ecx
        movl    $RECORD_FIRSTNAME_SIZE, %edx
        int     $LINUX_SYSCALL

        pushl   $ASCII_SPACE
        call    print_char_to_stdout
        addl    $4, %esp

        movl    $SYS_WRITE, %eax
        movl    $STDOUT, %ebx
        movl    $RECORD_DATA, %ecx
        addl    $RECORD_FIRSTNAME_SIZE, %ecx
        movl    $RECORD_LASTNAME_SIZE, %edx
        int     $LINUX_SYSCALL

        pushl   $ASCII_NEWLINE
        call    print_char_to_stdout
        addl    $4, %esp

        movl    $SYS_WRITE, %eax
        movl    $STDOUT, %ebx
        movl    $RECORD_DATA, %ecx
        addl    $RECORD_FIRSTNAME_SIZE, %ecx
        addl    $RECORD_LASTNAME_SIZE, %ecx
        movl    $RECORD_ADDRESS_SIZE, %edx
        int     $LINUX_SYSCALL

        pushl   $ASCII_NEWLINE
        call    print_char_to_stdout
        addl    $4, %esp

        movl    $RECORD_DATA, %ecx
        addl    $RECORD_FIRSTNAME_SIZE, %ecx
        addl    $RECORD_LASTNAME_SIZE, %ecx
        addl    $RECORD_ADDRESS_SIZE, %ecx
        pushl   0(%ecx)
        call    print_int_as_char

cleanup:
        call    exit

.equ ST_CHAR, 8
print_char_to_stdout:   
        pushl   %ebp
        movl    %esp, %ebp

        movl    $SYS_WRITE, %eax
        movl    $STDOUT, %ebx

        movl    %ebp, %ecx
        addl    $ST_CHAR, %ecx
        
        movl    $1, %edx

        int     $LINUX_SYSCALL

        movl    %ebp, %esp
        popl    %ebp
        ret

.equ ST_NUMBER, 8        
print_int_as_char:       
        pushl   %ebp
        movl    %esp, %ebp
        
        movl    ST_NUMBER(%ebp), %eax   # number to convert
        movl    $1000000000, %ebx       # current divider, max for a 32 bit number
        movl    $10, %ecx

process_digit:  
        movl    $0, %edx                # keep highest 32 bits of division 0
        divl    %ebx

        cmp     $0, %eax
        je      prepare_next_loop
        addl    $48, %eax               # convert single digit to ascii
        pushl   %edx                    # save register
        pushl   %ecx                    # save register
        pushl   %ebx                    # save register
        pushl   %eax                    # argument for function
        call    print_char_to_stdout
        addl    $4, %esp                # throw away function argument
        popl    %ebx                    # restore register
        popl    %ecx                    # restore register
        popl    %edx                    # restore register

prepare_next_loop:      
        movl    %edx, %eax              # move remainder back to be processed again

        pushl   %eax                    # remember remainder
        movl    %ebx, %eax              # prepare dividing the divider 
        movl    $0, %edx                # make sure highest 32 bits are 0
        divl    %ecx                    # divide the divider by 10

        movl    %eax, %ebx              # move quotient back into ebx
        popl    %eax                    # restore original eax

        cmp     $0, %eax                # check if we still have to process
        jg      process_digit           # jump if %eax > 0

print_newline:  
        pushl   $ASCII_NEWLINE
        call    print_char_to_stdout
        addl    $4, %esp                # throw away function argument

        movl    %ebp, %esp
        popl    %ebp
        ret

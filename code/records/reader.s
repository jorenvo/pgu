.include "linux.s"
.include "record_def.s"
.include "common.s"

.section .bss
.lcomm RECORD_DATA, RECORD_SIZE

.section .text
.equ ST_FD, -4
.equ ST_READ_BYTES, -8
.equ O_RDONLY, 00000000
.equ PERMISSIONS, 0644
.equ ASCII_SPACE, 32
.equ ASCII_NEWLINE, 10
.globl _start
_start:
        movl    %esp, %ebp
        subl    $8, %esp                                # make room for local vars

        ## open file specified in first argument
        movl    $SYS_OPEN, %eax
        movl    ST_ARGV_1(%ebp), %ebx
        movl    $O_RDONLY, %ecx
        movl    $PERMISSIONS, %edx

        int     $LINUX_SYSCALL
        movl    %eax, ST_FD(%ebp)                       # store fd

process_record:
        pushl   $RECORD_DATA
        pushl   ST_FD(%ebp)
        call    read_record

        cmp     $0, %eax
        jle     cleanup

        addl    $8, %esp

print:
print_firstname:
        movl    $SYS_WRITE, %eax
        movl    $STDOUT, %ebx
        movl    $RECORD_DATA, %ecx
        movl    $RECORD_FIRSTNAME_SIZE, %edx
        int     $LINUX_SYSCALL

        pushl   $ASCII_SPACE
        call    print_char
        addl    $4, %esp

print_lastname:
        movl    $SYS_WRITE, %eax
        movl    $STDOUT, %ebx
        movl    $RECORD_DATA, %ecx
        addl    $RECORD_FIRSTNAME_SIZE, %ecx
        movl    $RECORD_LASTNAME_SIZE, %edx
        int     $LINUX_SYSCALL

        pushl   $ASCII_NEWLINE
        call    print_char
        addl    $4, %esp

print_address:
        movl    $SYS_WRITE, %eax
        movl    $STDOUT, %ebx
        movl    $RECORD_DATA, %ecx
        addl    $RECORD_FIRSTNAME_SIZE, %ecx
        addl    $RECORD_LASTNAME_SIZE, %ecx
        movl    $RECORD_ADDRESS_SIZE, %edx
        int     $LINUX_SYSCALL

        pushl   $ASCII_NEWLINE
        call    print_char
        addl    $4, %esp

print_age:
        movl    $RECORD_DATA, %ecx
        addl    $RECORD_FIRSTNAME_SIZE, %ecx
        addl    $RECORD_LASTNAME_SIZE, %ecx
        addl    $RECORD_ADDRESS_SIZE, %ecx
        pushl   0(%ecx)
        call    print_int_as_char

        jmp     process_record

cleanup:
        call    exit

.equ ST_CHAR, 8
.type print_char, @function
print_char:
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

.equ MAX_DIVIDER, 1000000000            # for a 32 bit unsigned int
.equ ST_NUMBER, 8
.equ ST_PRINTED, -4
.type print_int_as_char, @function
print_int_as_char:
        pushl   %ebp
        movl    %esp, %ebp
        subl    $4, %esp                # make room for ST_PRINTED

        movl    $0, ST_PRINTED(%ebp)    # initialize printed flag to false

        movl    ST_NUMBER(%ebp), %eax   # number to convert
        movl    $MAX_DIVIDER, %ebx      # current divider, max for a 32 bit number
        movl    $10, %ecx

process_digit:
        movl    $0, %edx                # keep highest 32 bits of division 0
        divl    %ebx

        cmp     $1, ST_PRINTED(%ebp)
        je      print_current_char

        cmp     $0, %eax
        je      prepare_next_loop

print_current_char:
        movl    $1, ST_PRINTED(%ebp)    # set printed flag
        addl    $48, %eax               # convert single digit to ascii
        pushl   %edx                    # save register
        pushl   %ecx                    # save register
        pushl   %ebx                    # save register
        pushl   %eax                    # argument for function
        call    print_char
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

        cmp     $0, %ebx                # check if divider is 0 yet
        jg      process_digit           # jump if divider > 0

print_newline:
        pushl   $ASCII_NEWLINE
        call    print_char
        addl    $4, %esp                # throw away function argument

        movl    %ebp, %esp
        popl    %ebp
        ret

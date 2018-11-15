.include "linux.s"
.include "record_def.s"
.include "common.s"

.section .bss
        .lcomm  RECORD_DATA, RECORD_SIZE

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

print:
        movl    $SYS_WRITE, %eax
        movl    $STDOUT, %ebx
        movl    $RECORD_DATA, %ecx
        movl    $RECORD_SIZE, %edx

        int     $LINUX_SYSCALL

        call    exit

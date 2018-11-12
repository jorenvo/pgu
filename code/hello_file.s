### PURPOSE:
### Write a file to file specified by first argument containing "Hello world!"
### 1/ open output file
### 2/ write contents to file
### 3/ close file
.section .data
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1
.equ LINUX_SYSCALL, 0x80
.equ ST_ARGC, 0
.equ ST_ARGV_0, 4       ## name of program
.equ ST_ARGV_1, 8       ## input file name
.equ ST_FD, -4

### from /usr/include/asm-generic/fcntl.h
.equ CREAT_WRONLY_TRUNCATE, 00000100 | 00000001 | 00001000
.equ PERMISSIONS, 0644

.equ STRING_LENGTH, 13
string:
        .byte 'H', 'e', 'l', 'l', 'o', ' ', 'w', 'o', 'r', 'l', 'd', '!', '\n'

.section .text
.globl _start
_start:
        movl    %esp, %ebp
        addl    $4, %esp                        # reserve space for fd
open:
        movl    $SYS_OPEN, %eax                 # prepare open
        movl    ST_ARGV_1(%ebp), %ebx           # read filename into %ebx
        movl    $CREAT_WRONLY_TRUNCATE, %ecx    # set read options
        movl    $PERMISSIONS, %edx              # set permissions
        int     $LINUX_SYSCALL                  # execute syscall
        movl    %eax, ST_FD(%ebp)               # store fd on stack

write:
        movl    $SYS_WRITE, %eax                # prepare open
        movl    ST_FD(%ebp), %ebx               # set fd
        movl    $string, %ecx                   # set buffer start
        movl    $STRING_LENGTH, %edx            # set buffer size
        int     $LINUX_SYSCALL                  # execute write

close:
        movl    $SYS_CLOSE, %eax                # prepare close
        movl    ST_FD(%ebp), %ebx               # set fd
        int     $LINUX_SYSCALL                  # execute close

exit:
        movl    $SYS_EXIT, %eax
        movl    $0, %ebx                        # return 0
        int     $LINUX_SYSCALL

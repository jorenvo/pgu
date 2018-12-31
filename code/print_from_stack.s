.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2
.equ LINUX_SYSCALL, 0x80
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

.section .text
.globl _start
_start:
        # (10 << 24) | (99 << 16) | (98 << 8) | 97
        push $174285409

        # prepare write
        movl $4, %eax
        movl $STDOUT, %ebx

        movl %esp, %ecx
        movl $4, %edx

        int $LINUX_SYSCALL
        
exit:
        movl  $SYS_EXIT, %eax
	movl  $0, %ebx
	int   $LINUX_SYSCALL


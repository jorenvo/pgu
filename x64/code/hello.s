.data
str:
  .ascii "Hello world!\n"
  len = . - str                  # length = start - end.   . = current position

.text
.globl _main
_main:
    movl   $0x2000004, %eax
    movl   $1, %edi
    leaq   str(%rip), %rsi  
    movq   $len, %rdx          
    syscall                       # write(1, str, len)

    movl   $0x2000001, %eax 
    movl   $12, %edi
    syscall                       # _exit(0)

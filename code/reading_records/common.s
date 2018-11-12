### This defines a read and write function for our records
.include "linux.s"
.include "record_def.s"

.equ ST_FD, 8
.equ ST_BUFFER, 12

.section .text

### Reading function
### INPUT : - file descriptor
###         - buffer to read a single record into
### OUTPUT: record will be in buffer
.globl read_record
.type read_record, @function
read_record:
        pushl   %ebp                    # save caller's ebp
        movl    %esp, %ebp              # set ebp

        movl    $SYS_READ, %eax         # prepare read
        movl    ST_FD(%ebp), %ebx       # set fd
        movl    ST_BUFFER(%ebp), %ecx   # set buffer to read into
        movl    $RECORD_SIZE, %edx      # set size to read

        int     $LINUX_SYSCALL          # do read

        movl    %ebp, %esp              # restore original esp - 4 in case it changed
                                        # (it didn't here)
        popl    %ebp                    # restore original ebp
        ret                             # this will return what syscall returned (%eax)

### Writing function
### INPUT : - file descriptor
###         - buffer containing a record that should be written
### OUTPUT: record is written to file
.globl write_record
.type write_record, @function
write_record:
        pushl   %ebp
        movl    %esp, %ebp

        movl    $SYS_WRITE, %eax
        movl    ST_FD(%ebp), %ebx       # set fd
        movl    ST_BUFFER(%ebp), %ecx   # set buffer to read from
        movl    $RECORD_SIZE, %edx      # set size to write

        int     $LINUX_SYSCALL          # do write

        movl    %ebp, %esp
        popl    %ebp
        ret

.include "linux.s"
.include "record_def.s"
.include "common.s"

.section .data
nr_records:
        .long   3
records:
joren:
        .ascii  "Joren"
        .rept   40 - 5
        .byte   0
        .endr

        .ascii  "Van Onder"
        .rept   40 - 9
        .byte   0
        .endr

        .ascii  "250 Executive Park Blvd #3400\nSan Francisco\nCA 94134"
        .rept   320 - 80 - 52
        .byte   0
        .endr

        .long   18

bart:
        .ascii  "Bart"
        .rept   40 - 4
        .byte   0
        .endr

        .ascii  "Simpson"
        .rept   40 - 7
        .byte   0
        .endr

        .ascii  "742 Evergreen Terrace"
        .rept   320 - 80 - 21
        .byte   0
        .endr

        .long   10

marilyn:
        .ascii  "Marilyn"
        .rept   40 - 7
        .byte   0
        .endr

        .ascii  "Taylor"
        .rept   40 - 6
        .byte   0
        .endr

        .ascii  "2224 S Johannan St\nChicago, IL 12345"
        .rept   320 - 80 - 36
        .byte   0
        .endr

        .long   29

.equ ST_FD, -4
.equ O_CREAT_WRONLY_TRUNC, 00000100 | 00000001 | 00001000
.equ PERMISSIONS, 0644

.section .text
.globl _start
_start:
        movl    %esp, %ebp                              # save stack pointer
        subl    $4, %esp                                # make room for ST_FD
open:
        movl    $SYS_OPEN, %eax                         # prepare open
        movl    ST_ARGV_1(%ebp), %ebx                   # set filename
        movl    $O_CREAT_WRONLY_TRUNC, %ecx             # set options
        movl    $PERMISSIONS, %edx                      # set permissions

        int     $LINUX_SYSCALL                          # execute open
        movl    %eax, ST_FD(%ebp)                       # save fd

init:
        movl    $0, %ebx                                # initialize number of records written

write_one_record:
        cmp     nr_records, %ebx                        # check if we're done
        je      clean_up                                # clean up if we're done

        pushl   %ebx                                    # save %ebx

        imul    $RECORD_SIZE, %ebx                      # calculate offset at which current records starts
        addl    $records, %ebx                          # add this to the start of the records

        ## NOTE:
        ## Don't try to use a memory reference e.g.:
        ##
        ## pushl records(%ebx)
        ##
        ## Manually calculate the address like above.
        ## When using a memory reference the memory
        ## always gets dereferenced. i.e. the memory
        ## is calculated and *value at that address*
        ## is returned. In this case we just want to
        ## pass the address.
        pushl   %ebx                                    # push second argument: address to read from
        pushl   ST_FD(%ebp)                             # push first argument: fd to write to
        call    write_record

        addl    $8, %esp                                # drop fd and %ecb
        popl    %ebx                                    # put records written back in %ebx
                                                        # this also resets esp to before function call
        incl    %ebx                                    # increment records written
        jmp     write_one_record                        # loop

clean_up:
        movl    $SYS_CLOSE, %eax                        # prepare close
        movl    ST_FD(%ebp), %ebx                       # set fd
        int     $LINUX_SYSCALL                          # do close

exit:
        movl    $SYS_EXIT, %eax                         # prepare exit
        movl    $0, %ebx                                # return 0
        int     $0x80                                   # execute syscall

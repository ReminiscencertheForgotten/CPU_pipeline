.data
    str:.asciiz "aaa is not aaaa is not aa"
    .align 9
    pattern:.asciiz "aa"
    .align 9

.text
main:
    li $s0, 25
    li $s1, 2
    move $a0, $s0
    la $a1, str
    move $a2, $s1
    la $a3, pattern
    jal kmp
    sll $0, $0, 0
    j endkmp
    sll $0, $0, 0

kmp:
    # push params and register into stack
    addi $sp, $sp, -20
    sw $a0, 0($sp)      # store len_str
    sw $a1, 4($sp)      # store the address of str
    sw $a2, 8($sp)      # store len_pattern
    sw $a3, 12($sp)     # store address of pattern
    sw $ra, 16($sp)     # store register

    li $s1, 0           # i = 0
    li $s2, 0           # j = 0
    li $s3, 0           # cnt = 0

    # # dynamic memory allocation  
    # sll $a0, $a2, 4     # offset for len_pattern * 4
    # li $v0, 9
    # syscall

    li $v0, 0x10010400

    move $a0, $v0       # put *next in $a0
    move $a1, $a2       # put len_pattern in $a1
    move $a2, $a3       # put *pattern in $a2

    jal genNext
    sll $0, $0, 0

    move $s0, $a0       # put *next in $s0
    lw $a0, 0($sp)      # reload len_str
    lw $a1, 4($sp)      # reload *str
    lw $a2, 8($sp)      # reload len_pattern
    lw $a3, 12($sp)     # reload *pattern

while_k:
    # i >= len_str, return
    bge $s1, $a0, return_k
    sll $0, $0, 0

    add $t1, $a3, $s2   # addr of pattern[j]
    lb $t1, ($t1)       # value of pattern[j]

    add $t2, $a1, $s1   # addr of str[i]
    lb $t2, ($t2)       # value of str[i]

    sll $0, $0, 0
    # pattern[j] != str[i], else
    bne $t1, $t2, else1        
    sll $0, $0, 0
    addi $t1, $a2, -1   # len_pattern - 1

    # j != len_pattern - 1, else
    bne $t1, $s2, else2
    sll $0, $0, 0

    addi $s3, $s3, 1    # cnt++    
    sll $t0, $t1, 2     # offset
    add $t0, $t0, $s0   # addr of next[len_pattern - 1]
    lw $s2, ($t0)       # j = next[len_pattern - 1]
    addi $s1, $s1, 1
    j while_k
    sll $0, $0, 0

else2:
    addi $s1, $s1, 1    # i++
    addi $s2, $s2, 1    # j++
    j while_k
    sll $0, $0, 0

else1:
    # j > 0
    bgt $s2, $zero, update
    sll $0, $0, 0
    j not_update
    sll $0, $0, 0

update:
    addi $t1, $s2, -1   # j - 1
    sll $t0, $t1, 2
    add $t0, $s0, $t0   # addr of next[j - 1]
    lw $s2, ($t0)       # j = next[j - 1]
    j while_k
    sll $0, $0, 0

not_update:
    addi $s1, $s1, 1    # i++
    j while_k
    sll $0, $0, 0

return_k:
    move $v0, $s3       # return cnt
    lw $a0, 0($sp)      # load len_str
    lw $a1, 4($sp)      # load the address of str
    lw $a2, 8($sp)      # load len_pattern
    lw $a3, 12($sp)     # load address of pattern
    lw $ra, 16($sp)     # load register

    jr $ra
    sll $0, $0, 0

genNext:
    addi $sp, $sp, -24
    sw $a0, 0($sp)      # store *next
    sw $a1, 4($sp)      # store len_pattern
    sw $a2, 8($sp)      # store *pattern
    sw $s1, 12($sp)     # store i
    sw $s2, 16($sp)     # store j
    sw $ra, 20($sp)     # store register

    li $s1, 1           # i = 1
    li $s2, 0           # j = 0
    beqz $a1, final
    sll $0, $0, 0

    sw $zero, 0($a0)    # next[0] = 0

while:
    # i >= len_pattern, jump to end
    bge $s1, $a1, end
    sll $0, $0, 0
    
    add $t1, $a2, $s1   # addr of pattern[i]
    lb $t1, ($t1)       # value of pattern[i]

    add $t2, $a2, $s2   # addr of pattern[j]
    lb $t2, ($t2)       # value of pattern[j]

    sll $0, $0, 0
    bne $t1, $t2, elseif  
    sll $0, $0, 0
    sll $t0, $s1, 2     # offset
    add $t0, $a0, $t0   # addr of next[i]
    addi $t1, $s2, 1    # j + 1
    sw $t1, ($t0)       # next[i] = j + 1
    addi $s1, $s1, 1    # i++
    addi $s2, $s2, 1    # j++
    j while
    sll $0, $0, 0

elseif:
    # j <= 0, jump to else 
    ble $s2, $zero, else    
    sll $0, $0, 0
    subi $t0, $s2, 1    # j - 1    
    sll $t0, $t0, 2     # offset
    add $t0, $a0, $t0   # addr of next[j - 1]
    lw $s2, ($t0)       # j = next[j - 1]
    j while
    sll $0, $0, 0

else:
    sll $t0, $s1, 2
    add $t0, $a0, $t0   # the addr of next[i]
    addi $s1, $s1, 1    # i++
    j while   
    sll $0, $0, 0

end:
    li $v0, 0           # return 0
    j return
    sll $0, $0, 0

final:
    li $v0, 1           # return 1

return:
    lw $a0, 0($sp)      # load *next
    lw $a1, 4($sp)      # load len_pattern
    lw $a2, 8($sp)      # load *pattern
    lw $s1, 12($sp)     # load i
    lw $s2, 16($sp)     # load j
    lw $ra, 20($sp)     # load register

    addi $sp, $sp, 24
    jr $ra
    sll $0, $0, 0

endkmp:

lw $t0, 0($zero)
lw $t1, 4($zero)
lw $t2, 8($zero)
lw $t3, 12($zero)

compare_01:
slt $t4, $t0, $t1
beq $t4, $zero,  xchg_01
j compare_23
xchg_01:
add $t4, $t0, $zero
add $t0, $t1, $zero
add $t1, $t4, $zero

compare_23:
slt $t4, $t2, $t3
beq $t4, $zero,  xchg_23
j compare_13
xchg_23:
add $t4, $t2, $zero
add $t2, $t3, $zero
add $t3, $t4, $zero

compare_13:
slt $t4, $t1, $t3
beq $t4, $zero,  xchg_13
j compare_02
xchg_13:
add $t4, $t1, $zero
add $t1, $t3, $zero
add $t3, $t4, $zero

compare_02:
slt $t4, $t0, $t2
beq $t4, $zero,  xchg_02
j compare_12
xchg_02:
add $t4, $t0, $zero
add $t0, $t2, $zero
add $t2, $t4, $zero

compare_12:
slt $t4, $t1, $t2
beq $t4, $zero,  xchg_12
j write_to_mem
xchg_12:
add $t4, $t1, $zero
add $t1, $t2, $zero
add $t2, $t4, $zero

write_to_mem:
sw $t0, 0($zero)
sw $t1, 4($zero)
sw $t2, 8($zero)
sw $t3, 12($zero)

#######################################
# check basic set of commands
#######################################
__main:
__next0:
	lw $t0, 12($0) # load 3
	lw $t1, 8($0) # load 2
	add $t2, $t0, $t1
	sw $t2, 20($0)
	lw $t3, 20($0)
__next1:
	beq $t2, $t3, __next2 # taken
	j __next1
__next2:
	beq $t0, $t3, __next2 # not taken
	sub $t2, $t2, $t0
__next3:
	beq $t1, $t2, __next4 # taken
	j __next3
__next4:
	lw $t0, 4($0) # load 1
	lw $t1, 8($0) # load 2
	or $t2, $t0, $t1
	lw $t3, 12($0) # load 3
	beq $t3, $t2, __next6 # taken
__next5:
	j __next5
__next6:
	and $t4, $t2, $t1
	beq $t1, $t4, __next7 #taken
	j __next6
__next7:
	lw $t0,8($0)	# big number - 0x00000002
	lw $t1,4($0)	# small number - 0x00000001
	slt $t2,$t0,$t1 	# $t2 should be 0
	beq $t2,$0, __next9 # taken
__next8:
	j __next8
	


	beq $t2,$t1,__next9
__next9:
	j __next9 # stopping adress is 0x00000068

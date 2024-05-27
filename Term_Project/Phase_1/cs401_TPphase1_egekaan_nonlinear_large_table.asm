.data
# 1 S-Box Containing all other S-boxes:
S0: .byte 0x2, 0xF, 0xC, 0x1, 0x5, 0x6, 0xA, 0xD, 0xE, 0x8, 0x3, 0x4, 0x0, 0xB, 0x9, 0x7, 0xF, 0x4, 0x5, 0x8, 0x9, 0x7, 0x2, 0x1, 0xA, 0x3, 0x0, 0xE, 0x6, 0xC, 0xD, 0xB, 0x4, 0xA, 0x1, 0x6, 0x8, 0xF, 0x7, 0xC, 0x3, 0x0, 0xE, 0xD, 0x5, 0x9, 0xB, 0x2, 0x7, 0xC, 0xE, 0x9, 0x2, 0x1, 0x5, 0xF, 0xB, 0x6, 0xD, 0x0, 0x4, 0x8, 0xA, 0x3

# 100 randomly generated 16-bit numbers:
X: .word 0x1F74, 0xB380, 0x7571, 0xF851, 0x143B, 0x4A7A, 0xA3CD, 0x0835, 0xFF2E, 0x9406, 0x5287, 0xA676, 0x9AED, 0xA271, 0x2C75, 0x94BC, 0x15F5, 0xE136, 0xC342, 0x6F16, 0xD182, 0xEC5F, 0x876A, 0x3D84, 0xD17B, 0x37CF, 0xB157, 0x35B3, 0xEA8A, 0xFD1E, 0x704B, 0x2CE0, 0x4363, 0x507B, 0xE440, 0x88E5, 0xB787, 0xF3FD, 0x85AB, 0xA6EB, 0x1273, 0x43BD, 0x2F3E, 0xE694, 0x9C68, 0xD5BE, 0x2367, 0xC2A3, 0x24B1, 0xFE63, 0x109E, 0xFBB7, 0x5F79, 0x857B, 0x0EA1, 0x8F99, 0x0F1E, 0xA4A5, 0xE72E, 0xF209, 0xE124, 0x1680, 0xB846, 0xFB3A, 0x9587, 0x9C23, 0x1DEB, 0xA34E, 0xFD21, 0x685F, 0xD03E, 0x762C, 0x9893, 0xBDB0, 0xE93D, 0x749D, 0xD2ED, 0x49C5, 0xB3CD, 0xF487, 0x6A1F, 0x9FD3, 0x5890, 0x739D, 0x69C4, 0xF173, 0xA717, 0xD53A, 0x439C, 0xCEBB, 0xAA81, 0x8D73, 0xE7D6, 0x1A4C, 0x229B, 0x7CF8, 0x0F41, 0xA9C6, 0x9356, 0xEFA2

# Output message for the result of each iteration.
Message: .asciiz "The value gathered from the S-Boxes: "
Termination: .asciiz "The void S(X) function is returned."

.text
main:
	la $a0, X           # The address of X[0] is in $a0.
	jal S               # Execute the S(X) function. This function assumes that len(X) is 100.
	la $a0, Termination # Load the termination message into $a0.
	li $v0, 4           # Put the system call code for printing a string into $v0.
	syscall             # Make the system call.
	li $v0, 10          # Put the system call code for exit into $v0.
    	syscall             # Make the system call to exit the program.

S:
	add $t0, $t0, $zero # $t0 = i = 0. $t0 is the loop counter.
	add $t1, $a0, $zero # The address of X[0] is in $t1.
	j S_Loop            # Jump to the loop part of the method.
	
S_Loop:
	# Loop condition (while loop counter < 100):
	addi $t2, $zero, 100
	beq $t0, $t2, S_End
	
	# Access to the 16-bit number for the current iteration:
	add $t2, $t0, $t0   # $t2 = 2*$t0.
	add $t2, $t2, $t2   # $t2 = 4*$t0.
	add $t2, $t1, $t2   # $t2 = &X[i] = &X[$t0].
	lw $t2, 0($t2)      # $t2 = X[i] = X[$t0].
	
	# Parse the 16-bit number into 4 4-bit numbers:
	# $t2[15:12]:
	andi $t3, $t2, 0xF000 # Isolate the [15:12] bits of the number.
        srl  $t3, $t3, 12     # Shift it right to place it to the lower 4 bit.
        la $t4, S0            # Load &S0[0] to $t4.
        add $t4, $t4, $t3     # Find the address of S0[$t2[15:12]].
        lb $t3, 0($t4)        # $t3 = S0[$t2[15:12]]
        
        # $t2[11:8]:
        andi $t4, $t2, 0x0F00 # Isolate the [11:8] bits of the number.
        srl  $t4, $t4, 8      # Shift it right to place it to the lower 4 bit.
        la $t5, S0            # Load &S0[0] to $t5.
        addi $t5, $t5, 16     # $t5 = &S1[0] now.
        add $t5, $t5, $t4     # Find the address of S1[$t2[11:8]].
        lb $t4, 0($t5)        # $t4 = S1[$t2[11:8]]
        
        # $t2[7:4]:
        andi $t5, $t2, 0x00F0 # Isolate the [7:4] bits of the number.
        srl  $t5, $t5, 4      # Shift it right to place it to the lower 4 bit.
        la $t6, S0            # Load &S0[0] to $t6.
        addi $t6, $t6, 32     # $t6 = &S2[0] now.
        add $t6, $t6, $t5     # Find the address of S2[$t2[7:4]].
        lb $t5, 0($t6)        # $t5 = S2[$t2[7:4]]
        
        # $t2[3:0]:
        andi $t6, $t2, 0x000F # Isolate the [3:0] bits of the number.
        la $t7, S0            # Load &S0[0] to $t7.
        addi $t7, $t7, 48     # $t7 = &S3[0] now.
        add $t7, $t7, $t6     # Find the address of S3[$t2[3:0]].
        lb $t6, 0($t7)        # $t6 = S3[$t2[3:0]]
        
        # Concatenate $t3 || $t4 || $t5 || $t6:
	sll $t3, $t3, 12      # Shift $t3 left by 12 bits to place it in [15-12].
	sll $t4, $t4, 8       # Shift $t4 left by 8 bits to place it in [11-8].
	sll $t5, $t5, 4       # Shift $t5 left by 4 bits to place it in [7-4].
	                      # No shifting for $t6 since it is in the correct place.
	or $t3, $t3, $t4      # $t3 = $t3 || $t4.
	or $t3, $t3, $t5      # $t3 = $t3 || $t4 || $t5.
	or $t3, $t3, $t6      # $t3 = $t3 || $t4 || $t5 || $t6.
	
	# Print out the result to the console.
	add $t4, $a0, $zero   # Preserve the address of X[0] which is in $a0.
	la $a0, Message       # Load address of the Message into $a0.
	li $v0, 4             # Put the system call code for printing a string into $v0.
	syscall               # Make the system call.
	
	add $a0, $t3, $zero   # Load concatenated integer $t3 into $a0.
	li $v0, 34            # Put the system call code for printing an integer into $v0.
	syscall               # Make the system call.
	
	li $a0, 10            # Load the ASCII code for newline into $a0.
	li $v0, 11            # Put the system call code for printing a character into $v0.
	syscall               # Make the system call.
	
	# Increase the loop counter by 1 (i++) and recover the original value of $a0:
	addi $t0, $t0, 1      # Increase the loop counter.
	add $a0, $t4, $zero   # Recover the original value of $a0.
	j S_Loop
	
S_End:
	jr $ra
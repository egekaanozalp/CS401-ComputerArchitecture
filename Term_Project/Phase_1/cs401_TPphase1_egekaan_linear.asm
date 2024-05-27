.data
# A random 16-bit X value:
X: .word 0xbbaa
Result_Message: .asciiz "The result is: "

.text
main:
	lw $a0, X             # $a0 = X
	jal L
	add $t0, $v0, $zero
	
	# Print the result message:
	la $a0, Result_Message
	li $v0, 4
	syscall
	
	# Print the result itself:
	add $a0, $t0, $zero
	li $v0, 34
	syscall
	
	# Terminate the program:
	li $v0, 10
    	syscall
	
L:
	add $t0, $a0, $zero   # $t0 = $a0 = X
	
	# <<< (Circular Left):
	andi $t1, $t0, 0xFC00 # Find the first 6 bits by masking.
	srl $t1, $t1, 10      # Send them to the end.
	andi $t2, $t0, 0x03FF # Find the last 10 bits.
	sll $t2, $t2, 6       # Send them to the start.
	or $t3, $t1, $t2      # Find the circular left result.
	
	# >>> (Circular right):
	andi $t1, $t0, 0x003F # Find the last 6 bits.
	sll $t1, $t1, 10      # Send them to the start.
	andi $t2, $t0, 0xFFC0 # Find the first 10 bits.
	srl $t2, $t2, 6       # Send them to the end.
	or $t4, $t1, $t2      # Find the circular right result.
	
	# XOR Operations:
	xor $t0, $t0, $t3     # $t0 = X ⊕ (X <<< 6).
	xor $t0, $t0, $t4     # $t0 = X ⊕ (X <<< 6) ⊕ (X >>> 6).
	
	# Return the value:
	add $v0, $t0, $zero   # Return $t0.
	jr $ra

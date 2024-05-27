.data
# Random Number (8-bit):
Num: .word 0xD6

# Result Message:
Result_Message: .asciiz "The result is: "

.text
main:
	#Load Num1:
	lw $a0, Num
	jal P
	
	# Store the result of p(x) for Num1:
	add $t0, $v0, $zero
	
	# Print "The result is: ":
	la $a0, Result_Message
	li $v0, 4
	syscall

	# Print the result:
	add $a0, $t0, $zero  # Recover the result of p(x)
	li $v0, 34
	syscall
	
	# Exit from the program.
	li $v0, 10
    	syscall
	
P:
	add $t0, $a0, $zero  # Assign $a0 to $t0.
	
	# Access to the 0th bit of the "Num":
	andi $t1, $t0, 0x80  # Access to the 0th bit.
	srl $t1, $t1, 5      # Send the 0th bit to the 5th bit.
	
	# Access to the 1st bit of the "Num":
	andi $t2, $t0, 0x40  # Access to the 1st bit.
	srl $t2, $t2, 6      # Send the 1st bit to the 7th bit.
	
	# Access to the 2nd bit of the "Num":
	andi $t3, $t0, 0x20  # Access to the 2nd bit.
	srl $t3, $t3, 1      # Send the 2nd bit to the 3rd bit.
	
	# Access to the 3rd bit of the "Num":
	andi $t4, $t0, 0x10  # Access to the 3rd bit.
	srl $t4, $t4, 1      # Send the 3rd bit to the 4th bit.		
	
	# Access to the 4th bit of the "Num":
	andi $t5, $t0, 0x08  # Access to the 4th bit.
	sll $t5, $t5, 2      # Send the 4th bit to the 2nd bit.
	
	# Access to the 5th bit of the "Num":
	andi $t6, $t0, 0x04  # Access to the 5th bit.
	srl $t6, $t6, 1      # Send the 5th bit to the 6th bit.
	
	# Access to the 6th bit of the "Num":
	andi $t7, $t0, 0x02  # Access to the 6th bit.
	sll $t7, $t7, 5      # Send the 6th bit to the 1st bit.		
	
	# Access to the 7th bit of the "Num":
	andi $t8, $t0, 0x01  # Access to the 7th bit.
	sll $t8, $t8, 7      # Send the 7th bit to the 0th bit.
	
	or $v0, $t1, $t2
	or $v0, $v0, $t3
	or $v0, $v0, $t4
	or $v0, $v0, $t5
	or $v0, $v0, $t6
	or $v0, $v0, $t7
	or $v0, $v0, $t8
	
	jr $ra